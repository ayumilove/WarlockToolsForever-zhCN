local _, WTF = ...

-- Warnings: the target or focus row flashes 3 seconds before a DoT you cast
-- runs out, and the Control bar flashes 3 seconds before your Banish ends.
-- Forever hides enemy auras from AddOn code in combat, so both count from your
-- own cast time and the Toolkit's spell durations, not from the aura: a
-- dispel, an early break, or a resist can make one wrong. The frames are WTF's
-- own overlays on the sections the toolkit names, so no toolkit file changes.

local WARN_SECONDS = 3
local TICK = 0.2
local PENDING_SECONDS = 30
local SOUND = "Sound\\Interface\\RaidWarning.wav"
-- A DoT family that a warning can follow: the slots with a fixed duration in
-- the Warlock's `ranks` table. The curse slot lasts minutes and is left out.
local WARNABLE = {corruption = true, immolate = true, bane = true, siphon = true}
-- Banish: rank 1 (learned 28) 20 s, rank 2 (learned 48) 30 s; one at a time.
local BANISH_SECONDS = {[710] = 20, [18647] = 30}
local FLASH_COLOR = {1, 0.55, 0.1}

local warnings = {timers = {}, pending = {}, banish = nil}
local flashes = {}
local durations, slotOf

local function CreateFlash(parent)
    local glow = CreateFrame("Frame", nil, parent)
    glow:SetAllPoints(parent)
    glow:SetFrameLevel(parent:GetFrameLevel() + 30)
    local texture = glow:CreateTexture(nil, "OVERLAY")
    texture:SetAllPoints()
    texture:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    texture:SetBlendMode("ADD")
    texture:SetVertexColor(FLASH_COLOR[1], FLASH_COLOR[2], FLASH_COLOR[3])
    local group = glow:CreateAnimationGroup()
    local fadeIn = group:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(0.9)
    fadeIn:SetDuration(0.25)
    local fadeOut = group:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(0.9)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.75)
    fadeOut:SetStartDelay(0.2)
    group:SetScript("OnPlay", function() glow:Show() end)
    group:SetScript("OnFinished", function() glow:Hide() end)
    glow.group = group
    glow:Hide()
    return glow
end

-- Only when the section is on screen: another AddOn may hold the tracker's
-- or the bar's place, and a chime without a flash would confuse.
local function Pulse(token)
    local glow = flashes[token]
    if not glow or not glow:GetParent():IsVisible() then
        return false
    end
    glow.group:Stop()
    glow.group:Play()
    return true
end

local function Chime()
    if WTF.db.tracker.warnSound == true then
        pcall(PlaySoundFile, SOUND)
    end
end

local function BuildSpells()
    durations, slotOf = {}, {}
    local classData = type(WTF.toolkit) == "table" and type(WTF.toolkit.ClassSpells) == "function"
        and WTF.toolkit.ClassSpells("WARLOCK")
    if type(classData) ~= "table" then
        return
    end
    for id, record in pairs(classData.ranks or {}) do
        local duration = type(record) == "table" and record[3]
        if type(id) == "number" and type(duration) == "number" then
            durations[id] = duration
        end
    end
    -- Curse of Doom, in the Bane slot but not in the ranks table.
    durations[603] = 60
    for _, slot in ipairs(classData.dots or {}) do
        for _, id in ipairs(slot.ids or {}) do
            if slotOf[id] == nil then
                slotOf[id] = slot.key
            end
        end
    end
end

-- The pinned row a cast went to. A cast on a nameplate mob, or on anything
-- that is not your target or focus, gets no warning.
local function MatchToken(castName)
    if not castName or WTF.IsSecret(castName) then
        -- In combat the client can withhold the cast's target name; the target
        -- row is the likelier one (a cast on the focus can flash it wrongly).
        return "target"
    end
    local targetName = UnitName("target")
    if not WTF.IsSecret(targetName) and targetName == castName then
        return "target"
    end
    local focusName = UnitName("focus")
    if not WTF.IsSecret(focusName) and focusName == castName then
        return "focus"
    end
    return nil
end

local ticker, elapsed = CreateFrame("Frame", nil, UIParent), 0
warnings.ticker = ticker

local function Tick()
    local now = GetTime()
    local any = false
    for token, spells in pairs(warnings.timers) do
        local live = UnitExists(token) and not UnitIsDead(token)
        local guid = live and UnitGUID(token) or nil
        if guid and WTF.IsSecret(guid) then
            guid = nil
        end
        for slot, timer in pairs(spells) do
            if not live or (timer.guid and guid and timer.guid ~= guid) or now >= timer.expires then
                spells[slot] = nil
            else
                any = true
                if not timer.fired and timer.expires - now <= WARN_SECONDS then
                    timer.fired = true
                    if WTF.db.tracker.dotWarn ~= false and Pulse(token) then
                        Chime()
                    end
                end
            end
        end
        if next(spells) == nil then
            warnings.timers[token] = nil
        end
    end
    local banish = warnings.banish
    if banish then
        if now >= banish.expires then
            warnings.banish = nil
        else
            any = true
            if not banish.fired and banish.expires - now <= WARN_SECONDS then
                banish.fired = true
                if WTF.db.control.banishWarn ~= false and Pulse("control") then
                    Chime()
                end
            end
        end
    end
    if not any then
        ticker:SetScript("OnUpdate", nil)
        ticker:Hide()
    end
end

local function StartTicking()
    if ticker:GetScript("OnUpdate") then
        return
    end
    elapsed = 0
    ticker:SetScript("OnUpdate", function(_, update)
        elapsed = elapsed + update
        if elapsed >= TICK then
            elapsed = 0
            Tick()
        end
    end)
    ticker:Show()
end

local function OnSent(target, castGUID, spellID)
    if type(castGUID) ~= "string" or WTF.IsSecret(castGUID)
        or WTF.IsSecret(spellID) or type(spellID) ~= "number" then
        return
    end
    if WTF.db.tracker.enabled == false or WTF.db.tracker.dotWarn == false then
        return
    end
    if not durations[spellID] or not WARNABLE[slotOf[spellID]] then
        return
    end
    -- A cast that ends without SUCCEEDED or FAILED (a stop) leaves an entry:
    -- drop old ones so a long session never grows this table.
    local now = GetTime()
    for guid, cast in pairs(warnings.pending) do
        if now - cast.time > PENDING_SECONDS then
            warnings.pending[guid] = nil
        end
    end
    warnings.pending[castGUID] = {spellID = spellID, token = MatchToken(target), time = now}
end

local function OnSucceeded(castGUID, spellID)
    if type(castGUID) ~= "string" or WTF.IsSecret(castGUID)
        or WTF.IsSecret(spellID) or type(spellID) ~= "number" then
        return
    end
    local pending = warnings.pending[castGUID]
    warnings.pending[castGUID] = nil
    if pending and pending.spellID == spellID and pending.token then
        local slot = slotOf[spellID]
        local spells = warnings.timers[pending.token]
        if not spells then
            spells = {}
            warnings.timers[pending.token] = spells
        end
        local timer = spells[slot]
        if not timer then
            timer = {}
            spells[slot] = timer
        end
        local guid = UnitGUID(pending.token)
        timer.guid = (guid and not WTF.IsSecret(guid)) and guid or nil
        timer.expires = GetTime() + durations[spellID]
        timer.fired = false
        StartTicking()
    end
    if BANISH_SECONDS[spellID] and WTF.db.control.enabled ~= false and WTF.db.control.banishWarn ~= false then
        warnings.banish = {expires = GetTime() + BANISH_SECONDS[spellID], fired = false}
        StartTicking()
    end
end

local events = CreateFrame("Frame", nil, UIParent)
warnings.events = events

function WTF.InitializeWarnings()
    BuildSpells()
    -- The sections exist even while their feature is switched off: the overlay
    -- is made anyway, and Pulse only flashes a section that is on screen.
    local target = rawget(_G, "WarlockToolsForeverTracker")
    local focus = rawget(_G, "WarlockToolsForeverTrackerFocus")
    if target then
        flashes.target = CreateFlash(target)
    end
    if focus then
        flashes.focus = CreateFlash(focus)
    end
    local control = rawget(_G, "WarlockToolsForeverControl")
    if control then
        flashes.control = CreateFlash(control)
    end
    events:RegisterUnitEvent("UNIT_SPELLCAST_SENT", "player")
    events:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    events:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
    events:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
    -- This client's cast events lead with the unit (Announce.lua reads them
    -- the same way): SENT is unit, target, castGUID, spellID; SUCCEEDED and the
    -- failures are unit, castGUID, spellID.
    events:SetScript("OnEvent", function(_, event, unit, first, second, third)
        if event == "UNIT_SPELLCAST_SENT" then
            OnSent(first, second, third)
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            OnSucceeded(first, second)
        elseif type(first) == "string" and not WTF.IsSecret(first) then
            warnings.pending[first] = nil
        end
    end)
end
