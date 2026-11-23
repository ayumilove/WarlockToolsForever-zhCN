local _, DDT = ...

-- Fork (1.5.0-fork.1): warnings shortly before a DoT or Banish ends. The
-- target or focus panel flashes 3 seconds before a DoT you cast runs out, and
-- the crowd-control bar flashes 3 seconds before your Banish ends, each with
-- an optional chime. Forever hides enemy auras from AddOn code in combat, so
-- both count from your own cast time and the Toolkit's spell durations, not
-- from the aura: a dispel, an early break, or a resist can make one wrong.
-- The overlays sit on the frames the Toolkit names, so no Toolkit change.

local WARN_SECONDS = 3
local TICK = 0.2
local PENDING_SECONDS = 30
local SOUND = "Sound\\Interface\\RaidWarning.wav"
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

-- Only when the frame is on screen: another AddOn may hold the tracker's
-- place, and a chime without a flash would confuse.
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
    if DDT.db.dots.warnSound == true then
        pcall(PlaySoundFile, SOUND)
    end
end

local function Secret(value)
    return type(DDT.toolkit) == "table" and DDT.toolkit.IsSecret(value) == true
end

-- Every rank's duration, and which slot each of its spell IDs belongs to.
local function BuildSpells()
    durations, slotOf = {}, {}
    local classData = DDT.classData
    if type(classData) ~= "table" then
        return
    end
    for id, record in pairs(classData.ranks or {}) do
        local duration = type(record) == "table" and record[3]
        if type(id) == "number" and type(duration) == "number" then
            durations[id] = duration
        end
    end
    -- Curse of Doom, in the Warlock's Bane slot but not in the ranks table.
    durations[603] = 60
    local families = classData.families or {}
    for _, slot in ipairs(classData.dots or {}) do
        -- A trap lands where you aim, maybe on no mob at all: no warning.
        local family = families[slot.key]
        if not (type(family) == "table" and family.ground == true) then
            for _, id in ipairs(slot.ids or {}) do
                if slotOf[id] == nil then
                    slotOf[id] = slot.key
                end
            end
        end
    end
end

-- The pinned row a cast went to. A cast on a nameplate mob, or on anything
-- that is not your target or focus, gets no warning.
local function MatchToken(castName)
    if not castName or Secret(castName) then
        -- In combat the client can withhold the cast's target name; the target
        -- row is the likelier one (a cast on the focus can flash it wrongly).
        return "target"
    end
    local targetName = UnitName("target")
    if not Secret(targetName) and targetName == castName then
        return "target"
    end
    local focusName = UnitName("focus")
    if not Secret(focusName) and focusName == castName then
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
        if guid and Secret(guid) then
            guid = nil
        end
        for slot, timer in pairs(spells) do
            if not live or (timer.guid and guid and timer.guid ~= guid) or now >= timer.expires then
                spells[slot] = nil
            else
                any = true
                if not timer.fired and timer.expires - now <= WARN_SECONDS then
                    timer.fired = true
                    if DDT.db.dots.dotWarn ~= false and Pulse(token) then
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
                if DDT.db.control.banishWarn ~= false and Pulse("control") then
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
    if type(castGUID) ~= "string" or Secret(castGUID)
        or Secret(spellID) or type(spellID) ~= "number" then
        return
    end
    local dots = DDT.db.dots
    if not DDT.dotTracker or dots.enabled == false or dots.dotWarn == false then
        return
    end
    if not durations[spellID] or not slotOf[spellID] then
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
    if type(castGUID) ~= "string" or Secret(castGUID)
        or Secret(spellID) or type(spellID) ~= "number" then
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
        timer.guid = (guid and not Secret(guid)) and guid or nil
        timer.expires = GetTime() + durations[spellID]
        timer.fired = false
        StartTicking()
    end
    if BANISH_SECONDS[spellID] and DDT.db.control.enabled ~= false
        and DDT.db.control.banishWarn ~= false then
        warnings.banish = {expires = GetTime() + BANISH_SECONDS[spellID], fired = false}
        StartTicking()
    end
end

local events = CreateFrame("Frame")
warnings.events = events

function DDT.InitializeWarnings()
    BuildSpells()
    -- The frames exist whether their feature is on or off: the overlay is made
    -- anyway, and Pulse only flashes one that is on screen.
    for _, token in ipairs({"target", "focus"}) do
        local frame = rawget(_G, DDT.NAMES.dots[token])
        if frame then
            flashes[token] = CreateFlash(frame)
        end
    end
    local control = rawget(_G, DDT.NAMES.control)
    if control then
        flashes.control = CreateFlash(control)
    end
    for _, event in ipairs({"UNIT_SPELLCAST_SENT", "UNIT_SPELLCAST_SUCCEEDED",
        "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED"}) do
        events:RegisterEvent(event)
    end
    -- This client's cast events lead with the unit (Announce.lua reads them
    -- the same way): SENT is unit, target, castGUID, spellID; SUCCEEDED and the
    -- failures are unit, castGUID, spellID.
    events:SetScript("OnEvent", function(_, event, unit, first, second, third)
        if unit ~= "player" then
            return
        end
        if event == "UNIT_SPELLCAST_SENT" then
            OnSent(first, second, third)
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            OnSucceeded(first, second)
        elseif type(first) == "string" and not Secret(first) then
            warnings.pending[first] = nil
        end
    end)
end
