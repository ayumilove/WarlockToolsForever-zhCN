local _, WTF = ...

-- DoT tracker. Two pinned rows, your target (purple outline) and your focus
-- (red outline), each shown only while that unit is a live hostile; then a
-- list of the other mobs you DoTed, with a slot per spell family in its own
-- color, in the Compact or Bars theme (author-approved). Since 1.5.0 the
-- engine is Dyre's Toolkit's (DotTracker.lua's CreateDotTracker, 2.5.0, moved
-- from here; its header holds the rules) with ClassData.WARLOCK's slots. WTF
-- keeps its settings (db.tracker, repaired in Core), its three frame names,
-- the default place, its colors, and its Options page, and claims the
-- Warlock's DoTs at priority 10.

local TRACKER_PRIORITY = 10
local DEFAULT_POINT = {"CENTER", "CENTER", -260, 120}
local NAMES = {target = "WarlockToolsForeverTracker", focus = "WarlockToolsForeverTrackerFocus",
    list = "WarlockToolsForeverTrackerList"}

-- The smart curse (John, 2026-11-10, from a player comment; Toolkit 2.7.0):
-- the engine's hidden secure button for a key binding (Bindings.xml), and
-- the "! Curse" macro with the same text.
local SMART_CURSE_BUTTON = "WarlockToolsForeverSmartCurse"
local CURSE_MACRO = "! Curse"
BINDING_HEADER_WARLOCKTOOLSFOREVER = "Warlock Tools Forever"
_G["BINDING_NAME_CLICK " .. SMART_CURSE_BUTTON .. ":LeftButton"] = WTF.T("Smart curse")

local tracker = {available = false}

function WTF.CheckTrackerCapabilities()
    -- Forever's engine aura slots, else the Toolkit's plain-Lua ones (Auras.lua).
    if not WTF.AuraEngineKind() then
        return false, WTF.AURA_ENGINE_MISSING
    end
    for _, name in ipairs({"RegisterStateDriver", "UnregisterStateDriver"}) do
        if type(_G[name]) ~= "function" then
            return false, name
        end
    end
    if type(C_Timer) ~= "table" or type(C_Timer.After) ~= "function" then
        return false, "C_Timer.After"
    end
    return true
end

-- The engine's tracker, once made; Dots.lua and Predict.lua use it too.
function WTF.DotTracker()
    return tracker.available and tracker.engine or nil
end

function WTF.TrackerCandidateFilters(key)
    return tracker.available and tracker.engine:CandidateFilters(key) or nil
end

function WTF.TrackerKnowsSlot(key)
    return tracker.available and tracker.engine:KnowsSlot(key) or false
end

function WTF.TrackerSlotIcon(key)
    return tracker.available and tracker.engine:SlotIcon(key) or nil
end

-- The gold line ----------------------------------------------------------------
-- Hovering a row draws a line on screen from that row to the mob's nameplate.
-- The client gives a nameplate's place, never the mob's, so the line needs the
-- plate shown and on screen; it is a UI overlay, not a line in the world.

local LINE_COLOR = {1, 0.84, 0.35}
local LINE_UPDATE = 0.1
local NAMEPLATE_UNITS = 40

local hoveredRow, line

local updateLine

local function LineFrame()
    if line then
        return line
    end
    line = CreateFrame("Frame", nil, UIParent)
    line:SetAllPoints(UIParent)
    line:SetFrameStrata("HIGH")
    line:EnableMouse(false)
    local glow = line:CreateTexture(nil, "OVERLAY")
    glow:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    glow:SetVertexColor(LINE_COLOR[1], LINE_COLOR[2], LINE_COLOR[3], 0.35)
    glow:SetBlendMode("ADD")
    glow:SetHeight(14)
    local core = line:CreateTexture(nil, "OVERLAY")
    core:SetTexture("Interface\\Buttons\\WHITE8X8")
    core:SetVertexColor(LINE_COLOR[1], LINE_COLOR[2], LINE_COLOR[3], 0.9)
    core:SetHeight(2)
    local tip = line:CreateTexture(nil, "OVERLAY")
    tip:SetTexture("Interface\\Buttons\\WHITE8X8")
    tip:SetVertexColor(LINE_COLOR[1], LINE_COLOR[2], LINE_COLOR[3], 0.95)
    tip:SetSize(5, 5)
    line.textures = {glow, core}
    line.tip = tip
    line:Hide()
    line:SetScript("OnUpdate", function(self, update)
        self.elapsed = (self.elapsed or 0) + update
        if self.elapsed < LINE_UPDATE then
            return
        end
        self.elapsed = 0
        updateLine()
    end)
    return line
end

local function HideLineTextures()
    for _, texture in ipairs(line.textures) do
        texture:Hide()
    end
    line.tip:Hide()
end

-- The unit token a row shows: the pinned key, else the mob found by its GUID.
local function RowUnit(row)
    if row.wtfKey then
        return row.wtfKey
    end
    local unit = row.guid and WTF.toolkit and type(WTF.toolkit.FindUnit) == "function"
        and WTF.toolkit.FindUnit(row.guid) or nil
    if not unit or unit == "none" then
        unit = row.boundUnit
    end
    if type(unit) ~= "string" or unit == "none" then
        return nil
    end
    return unit
end

local function PlateOf(unit)
    if type(unit) ~= "string" or type(C_NamePlate) ~= "table"
        or type(C_NamePlate.GetNamePlateForUnit) ~= "function" then
        return nil
    end
    local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
    if ok and plate then
        return plate
    end
    if unit ~= "target" and unit ~= "focus" then
        return nil
    end
    -- The client may not answer for "target"/"focus": take the plate of that mob.
    for index = 1, NAMEPLATE_UNITS do
        local token = "nameplate" .. index
        if UnitExists(token) then
            local same = UnitIsUnit(unit, token)
            if not WTF.IsSecret(same) and same == true then
                local found, plateForToken = pcall(C_NamePlate.GetNamePlateForUnit, token)
                return found and plateForToken or nil
            end
        end
    end
    return nil
end

local function ShowLine(row)
    hoveredRow = row
    LineFrame():Show()
    updateLine()
end

local function HideLine()
    hoveredRow = nil
    if line then
        line:Hide()
    end
end

updateLine = function()
    local row = hoveredRow
    if not row or not line then
        return
    end
    if not row:IsShown() then
        GameTooltip:Hide()
        HideLine()
        return
    end
    local unit = RowUnit(row)
    local plate = unit and PlateOf(unit) or nil
    if plate and (type(plate.GetCenter) ~= "function"
        or (type(plate.IsShown) == "function" and not plate:IsShown())) then
        plate = nil
    end
    local rowScale = row:GetEffectiveScale() / UIParent:GetEffectiveScale()
    local rx, ry = row:GetCenter()
    local plateScale = plate and plate:GetEffectiveScale() / UIParent:GetEffectiveScale()
    local px, py = plate and plate:GetCenter()
    if not plate or not rx or not ry or not px or not py then
        HideLineTextures()
        return
    end
    rx, ry = rx * rowScale, ry * rowScale
    px, py = px * plateScale, py * plateScale
    -- Start at the row's edge facing the plate.
    local sx = rx
    local left, right = row:GetLeft(), row:GetRight()
    if left and right then
        left, right = left * rowScale, right * rowScale
        sx = math.abs(left - px) <= math.abs(right - px) and left or right
    end
    local dx, dy = px - sx, py - ry
    local length = math.sqrt(dx * dx + dy * dy)
    if length <= 18 then
        HideLineTextures()
        return
    end
    local startGap, endGap = 6, 10
    local span = length - startGap - endGap
    if span <= 8 then
        HideLineTextures()
        return
    end
    local ux, uy = dx / length, dy / length
    local x1, y1 = sx + ux * startGap, ry + uy * startGap
    local x2, y2 = px - ux * endGap, py - uy * endGap
    local angle = math.atan2(y2 - y1, x2 - x1)
    for _, texture in ipairs(line.textures) do
        texture:ClearAllPoints()
        texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", (x1 + x2) / 2, (y1 + y2) / 2)
        texture:SetWidth(span)
        if texture.SetRotation then
            pcall(texture.SetRotation, texture, angle)
        end
        texture:Show()
    end
    line.tip:ClearAllPoints()
    line.tip:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x2, y2)
    line.tip:Show()
end

-- Row names and name clicks -----------------------------------------------------
-- The engine draws the rows; these are WTF's own labels and click areas on
-- them, so no toolkit file changes. Forever can hold a mob's name back from
-- AddOn code in combat, while a FontString still shows it: the pinned rows
-- read their name with UnitName (their engine name line yields to it), and a
-- list row's name is the one the engine took from the cast. A list row's name
-- strip selects its mob, out of combat only: in combat the client does not
-- let an AddOn change your target. Rows are rebuilt on settings changes and
-- new spells, so every refresh reattaches whatever is missing.

local ROW_STRIP_HEIGHT = 20
local SELECT_HINT_GAP = 5
local lastSelectHint = 0

local function SelectHint()
    local now = GetTime()
    if now - lastSelectHint > SELECT_HINT_GAP then
        lastSelectHint = now
        WTF.Report(WTF.T("In combat the game does not let an AddOn change your target; click the mob's "
            .. "nameplate."))
    end
end

local function SelectUnit(unit)
    if InCombatLockdown() then
        SelectHint()
        return
    end
    if type(unit) == "string" and unit ~= "none" and UnitExists(unit) and type(TargetUnit) == "function" then
        pcall(TargetUnit, unit)
    end
end

local function PinnedLabel(engine, key)
    local row = type(engine.pinned) == "table" and engine.pinned[key]
    if not row or not row.name then
        return
    end
    if not row.wtfTag then
        local color = {WTF.PanelColor(key)}
        local tag = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        -- The name area's right edge: the full width in Bars, the left block
        -- in Compact.
        tag:SetPoint("TOPRIGHT", row.name, "TOPRIGHT", 0, 0)
        tag:SetText(key == "target" and WTF.T("Target") or WTF.T("Focus"))
        tag:SetTextColor(color[1], color[2], color[3])
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("TOPLEFT", row.name, "TOPLEFT")
        name:SetPoint("TOPRIGHT", tag, "TOPLEFT", -4, 0)
        name:SetJustifyH("LEFT")
        -- Hovering the name draws the gold line to the mob's nameplate; a
        -- click targets it (out of combat, where the client allows it).
        local hover = CreateFrame("Frame", nil, row)
        hover:SetPoint("TOPLEFT", name, "TOPLEFT", 0, 0)
        hover:SetPoint("TOPRIGHT", name, "TOPRIGHT", 0, 0)
        hover:SetHeight(ROW_STRIP_HEIGHT)
        hover:SetFrameLevel(row:GetFrameLevel() + 6)
        hover:SetScript("OnEnter", function(self)
            ShowLine(row)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            if InCombatLockdown() then
                GameTooltip:SetText(WTF.T("In combat the game does not let an AddOn change your target; click "
                    .. "the mob's nameplate."), 0.7, 0.7, 0.7, true)
            else
                GameTooltip:SetText(WTF.T("Click to select this mob."), 1, 1, 1)
            end
            GameTooltip:Show()
        end)
        hover:SetScript("OnLeave", function()
            HideLine()
            GameTooltip:Hide()
        end)
        hover:SetScript("OnMouseUp", function(_, button)
            if button == "LeftButton" then
                SelectUnit(key)
            end
        end)
        row.wtfHover = hover
        row.wtfTag, row.wtfName = tag, name
        row.name:SetAlpha(0)
    end
    row.wtfKey = key
    if UnitExists(key) then
        row.wtfName:SetText(UnitName(key))
    elseif WTF.db.locked == false then
        -- Unlocked, the engine's sample rows carry sample names.
        row.wtfName:SetText(row.name:GetText() or "")
    else
        row.wtfName:SetText("")
    end
end

local function SelectRow(row)
    if InCombatLockdown() then
        SelectHint()
        return
    end
    -- The GUID is exact; a nameplate token can be handed to another mob.
    local unit = row.guid and WTF.toolkit and type(WTF.toolkit.FindUnit) == "function"
        and WTF.toolkit.FindUnit(row.guid) or nil
    if not unit or not UnitExists(unit) then
        unit = row.boundUnit
    end
    if unit and unit ~= "none" and UnitExists(unit) and type(TargetUnit) == "function" then
        pcall(TargetUnit, unit)
    end
end

local function ListRow(row)
    if row.wtfStrip or not row.name then
        return
    end
    local font, size, flags = row.name:GetFont()
    if font and size then
        row.name:SetFont(font, size + 2, flags)
    end
    local strip = CreateFrame("Frame", nil, row)
    strip:SetPoint("TOPLEFT", row, "TOPLEFT", 2, 0)
    strip:SetPoint("TOPRIGHT", row, "TOPRIGHT", -2, 0)
    strip:SetHeight(ROW_STRIP_HEIGHT)
    strip:SetFrameLevel(row:GetFrameLevel() + 6)
    -- Unlocked, the rows are dragged, and the strip would hold the drag back.
    strip:EnableMouse(WTF.db.locked ~= false)
    strip:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            SelectRow(row)
        end
    end)
    strip:SetScript("OnEnter", function(self)
        ShowLine(row)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        if InCombatLockdown() then
            GameTooltip:SetText(WTF.T("In combat the game does not let an AddOn change your target; click "
                .. "the mob's nameplate."), 0.7, 0.7, 0.7, true)
        else
            GameTooltip:SetText(WTF.T("Click to select this mob."), 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    strip:SetScript("OnLeave", function()
        HideLine()
        GameTooltip:Hide()
    end)
    row.wtfStrip = strip
end

-- Locked, the strips take the mouse; while Ctrl is held they belong to the
-- panel's drag instead (the engine hands Ctrl-drags of a locked panel).
local function StripsTakeMouse()
    local take = WTF.db.locked ~= false
    if take and type(IsControlKeyDown) == "function" and IsControlKeyDown() then
        take = false
    end
    return take
end

local function RefreshRows()
    local engine = WTF.DotTracker()
    if not engine then
        return
    end
    PinnedLabel(engine, "target")
    PinnedLabel(engine, "focus")
    local take = StripsTakeMouse()
    if not take then
        -- Turning the strips off may not deliver OnLeave: drop their tooltip.
        if hoveredRow then
            GameTooltip:Hide()
        end
        HideLine()
    end
    for _, key in ipairs({"target", "focus"}) do
        local row = type(engine.pinned) == "table" and engine.pinned[key]
        if row and row.wtfHover then
            row.wtfHover:EnableMouse(take)
        end
    end
    for _, row in ipairs(engine.rows or {}) do
        ListRow(row)
        if row.wtfStrip then
            row.wtfStrip:EnableMouse(take)
        end
    end
end

local function InitializeRows()
    RefreshRows()
    local events = CreateFrame("Frame", nil, UIParent)
    tracker.rowEvents = events
    events:RegisterEvent("PLAYER_TARGET_CHANGED")
    events:RegisterEvent("PLAYER_FOCUS_CHANGED")
    events:RegisterEvent("PLAYER_REGEN_ENABLED")
    events:RegisterEvent("SPELLS_CHANGED")
    events:RegisterEvent("MODIFIER_STATE_CHANGED")
    events:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED"
            or event == "MODIFIER_STATE_CHANGED" then
            RefreshRows()
        else
            -- A rebuild held off by combat lands now; a new spell rebuilds at once.
            C_Timer.After(0.5, function()
                if tracker.available then
                    RefreshRows()
                end
            end)
        end
    end)
end

local function Rebuild()
    if tracker.available then
        tracker.engine:Rebuild()
        RefreshRows()
    end
end

WTF.ApplyDotOrder = Rebuild
WTF.ApplyTrackerColors = Rebuild

function WTF.ApplyPanelColors()
    if tracker.available then
        tracker.engine:ApplyPanelColors()
    end
end

function WTF.RefreshTrackerPrediction(guid)
    if tracker.available then
        tracker.engine:RefreshPrediction(guid)
    end
end

function WTF.SetTrackerHealth(key, value)
    local settings = WTF.db.tracker
    if key == "health" then
        settings.health = value == true
    elseif key == "healthText" then
        settings.healthText = WTF.SanitizeHealthText(value)
    end
    Rebuild()
end

function WTF.SetTrackerSize(theme, key, value)
    local sizes = WTF.db.tracker.sizes
    if key then
        local saved = {}
        for name, current in pairs(sizes[theme]) do
            saved[name] = current
        end
        saved[key] = value
        sizes[theme] = WTF.SanitizeTrackerSizes(theme, saved)
    else
        sizes[theme] = WTF.SanitizeTrackerSizes(theme, nil)
    end
    Rebuild()
end

function WTF.SetTrackerTheme(theme)
    WTF.db.tracker.theme = theme == "bars" and "bars" or "compact"
    Rebuild()
end

function WTF.SetTrackerPanelOpacity(key, percent)
    WTF.db.tracker.panelOpacity[key] = WTF.SanitizeWhole(percent, WTF.PANEL_OPACITY_MIN, WTF.PANEL_OPACITY_MAX,
        WTF.DEFAULT_PANEL_OPACITY)
    if tracker.available then
        tracker.engine:ApplyPanelOpacity()
    end
end

-- Whether the Toolkit has the smart curse (2.7.0 or later).
function WTF.SmartCurseAvailable()
    return tracker.available and type(tracker.engine.ApplySmartCurse) == "function"
end

-- "! Curse": written while the control macros are on and you know Curse of
-- Weakness; deleted when they are off, and when you lose Weakness (only one
-- this session wrote). Out of combat (in combat, when it ends).
local function WriteCurseMacro(body)
    local keeper = tracker.keeper
    if not keeper then
        return
    end
    WTF.shared.OutOfCombat(keeper, function()
        if WTF.db.control.macros == false then
            keeper:Delete(CURSE_MACRO)
        elseif body then
            keeper:Write(CURSE_MACRO, body)
        elseif keeper.written[CURSE_MACRO] then
            keeper:Delete(CURSE_MACRO)
        end
    end)
end

function WTF.ApplyCurseMacro()
    if WTF.SmartCurseAvailable() then
        WriteCurseMacro(tracker.engine:SmartCurseBody())
    end
end

function WTF.SetCurseMode(mode)
    WTF.db.tracker.curseMode = mode == "smart" and "smart" or "last"
    if WTF.SmartCurseAvailable() then
        tracker.engine:ApplySmartCurse()
    end
end

function WTF.SetCurseMarker(on)
    WTF.db.tracker.curseMarker = on ~= false
    if WTF.SmartCurseAvailable() then
        tracker.engine:ApplySmartCurse()
    end
end

-- Whether the Toolkit draws the outline at a set width (2.8.0 or later).
function WTF.TrackerOutlineAvailable()
    local toolkit = rawget(_G, "DyresToolkit")
    return type(toolkit) == "table" and type(toolkit.TRACKER_OUTLINE) == "table"
end

-- Whether the Toolkit can hide empty DoT slots (TRACKER_HIDE_EMPTY).
function WTF.TrackerHideEmptyAvailable()
    local toolkit = rawget(_G, "DyresToolkit")
    return type(toolkit) == "table" and toolkit.TRACKER_HIDE_EMPTY == true
end

-- The rows are rebuilt (out of combat; in combat, when it ends).
function WTF.SetTrackerHideEmpty(on)
    WTF.db.tracker.hideEmpty = on == true
    Rebuild()
end

-- Whether the Toolkit can show or hide each panel (TRACKER_PANELS).
function WTF.TrackerPanelsAvailable()
    local toolkit = rawget(_G, "DyresToolkit")
    return type(toolkit) == "table" and type(toolkit.TRACKER_PANELS) == "table"
end

-- A panel ("target", "focus", or "list") shown or hidden; the engine reads
-- the store live, and its pinned sections change out of combat.
function WTF.SetTrackerPanelShown(key, on)
    WTF.db.tracker.show[key] = on ~= false
    WTF.RefreshTracker()
end

-- Out of combat; in combat the engine rebuilds when combat ends.
function WTF.SetTrackerOutlineWidth(width)
    WTF.db.tracker.outlineWidth = WTF.SanitizeWhole(width, WTF.OUTLINE_WIDTH_MIN, WTF.OUTLINE_WIDTH_MAX,
        WTF.DEFAULT_OUTLINE_WIDTH)
    Rebuild()
end

function WTF.ResetTrackerPosition()
    WTF.db.tracker.position = nil
    WTF.db.tracker.sections = {}
    if tracker.available then
        tracker.engine:ResetPosition()
    end
end

-- A profile copy or import (Core's ApplyProfile): the engine reads its store
-- (WTF.db.tracker, written in place) again: the switch, the sections' saved
-- places (ResetPosition places them from the store, out of combat), the rows,
-- the panel colors, the smart curse, and "! Curse".
function WTF.ApplyTrackerProfile()
    if not tracker.available then
        return
    end
    tracker.engine:Refresh()
    tracker.engine:ResetPosition()
    tracker.engine:Rebuild()
    RefreshRows()
    tracker.engine:ApplyPanelColors()
    if WTF.SmartCurseAvailable() then
        tracker.engine:ApplySmartCurse()
    end
    WTF.ApplyCurseMacro()
end

function WTF.RefreshTracker()
    if tracker.available then
        tracker.engine:Refresh()
        RefreshRows()
    end
end

-- The toolkit's Warlock DoT slots with their labels in the client's language;
-- IDs and matching rules stay the toolkit's own.
local function LocalizedSlots()
    local classData = type(WTF.toolkit) == "table" and type(WTF.toolkit.ClassSpells) == "function"
        and WTF.toolkit.ClassSpells("WARLOCK")
    local slots = classData and classData.dots
    if type(slots) ~= "table" then
        return nil
    end
    local localized = {}
    for index, slot in ipairs(slots) do
        local copy = {}
        for key, value in pairs(slot) do
            copy[key] = value
        end
        copy.label = WTF.T(slot.label)
        localized[index] = copy
    end
    return localized
end

function WTF.InitializeTracker()
    local available, missing = WTF.CheckTrackerCapabilities()
    if not available then
        WTF.Report(string.format(WTF.T("The DoT tracker stays off: this client lacks %s."), missing))
        return
    end
    local engine, why = WTF.shared.CreateDotTracker({
        addon = "WarlockToolsForever",
        priority = TRACKER_PRIORITY,
        class = "WARLOCK",
        slots = LocalizedSlots(),
        store = WTF.db.tracker,
        names = {target = NAMES.target, focus = NAMES.focus, list = NAMES.list, smartCurse = SMART_CURSE_BUTTON},
        point = DEFAULT_POINT,
        slotColor = WTF.SlotColor,
        panelColor = WTF.PanelColor,
        movable = {register = WTF.RegisterMovable, beginDrag = WTF.BeginDrag, endDrag = WTF.EndDrag},
        locked = function() return WTF.db.locked ~= false end,
        -- The toolkit's Ctrl-drag of a locked frame (Layout.lua has none).
        ctrlMove = WTF.toolkit ~= nil,
        predictor = WTF.predictor,
        onSpellsChanged = function() WTF.RefreshPlateDots() end,
        onSmartCurse = function(body) WriteCurseMacro(body) end,
    })
    if not engine then
        WTF.Report(string.format(WTF.T("The DoT tracker stays off: this client lacks %s."), tostring(why)))
        return
    end
    tracker.engine = engine
    tracker.available = true
    InitializeRows()
    if WTF.SmartCurseAvailable() then
        tracker.keeper = WTF.shared.CreateMacroKeeper({warn = WTF.Warn})
        WTF.ApplyCurseMacro()
    end
end

function WTF.ReportTrackerDebug()
    local available, missing = WTF.CheckTrackerCapabilities()
    WTF.Report(string.format("debug_tracker available=%s%s", tostring(available and tracker.available),
        missing and (" missing=" .. missing) or ""))
    if not tracker.available then
        return
    end
    for _, line in ipairs(tracker.engine:DebugLines()) do
        WTF.Report("debug_tracker " .. line)
    end
end
