local _, DDT = ...

-- Settings (stage E): a page under Dyre's Toolkit's "Dyre's AddOns", with one
-- page per settings section (DoT Tracker, DoTs, Crowd Control, Debuff Cues;
-- John, 2026-10-29/30 and 2026-11-27). Proxy settings read and write DyresDebuffTrackerDB
-- directly. Where a class Tools AddOn has a kind, its page says which one and
-- its settings are greyed (they apply once that AddOn's feature is off).

-- One name per section, the same on our own page, a host's page, and a host's
-- top-page switch (John, 2026-11-27: "let's have the same name used
-- consistently ... Make the others consistent too").
local TITLES = {tracker = DDT.T("DoT Tracker"), dots = DDT.T("DoTs"), control = DDT.T("Crowd Control"),
    cues = DDT.T("Debuff Cues")}
local REQUIRED_SETTINGS = {"RegisterProxySetting", "CreateCheckbox", "RegisterVerticalLayoutSubcategory"}
local NO_CLASS = DDT.T("Dyre's Debuff Tracker has nothing for your class.")
local NO_DOTS = DDT.T("Your class has no DoTs here yet.")
local NO_CONTROL = DDT.T("Your class has no crowd control here yet.")
local THEMES = {{"compact", DDT.T("Compact")}, {"bars", DDT.T("Bars")}}
local GROW_CHOICES = {{"down", DDT.T("Down")}, {"up", DDT.T("Up")}}
local HEALTH_TEXTS = {{"none", DDT.T("None")}, {"number", DDT.T("Number")}, {"percent", DDT.T("Percent")},
    {"both", DDT.T("Number and percent")}}
-- Warlock Tools Forever's tracker settings, moved here (John, via the lead,
-- 2026-11-20: "This includes DoT Colors, tracker panels, etc."), with WTF's
-- labels, so a WTF player finds them by the same names.
local PANEL_NAMES = {{"target", DDT.T("Target")}, {"focus", DDT.T("Focus")}, {"list", DDT.T("Others")}}
local PANEL_KEYS = {target = DDT.T("target"), focus = DDT.T("focus"), list = DDT.T("list")}
local SIZE_LABELS = {iconSize = DDT.T("Icon size"), nameWidth = DDT.T("Name width"),
    textScale = DDT.T("Text size"), barWidth = DDT.T("Bar width"), lineHeight = DDT.T("Line height")}
local SIZE_TIPS = {nameWidth = DDT.T("The room for the mob's name beside the icons.")}
local NAME_POSITION_LABELS = {left = DDT.T("Left"), right = DDT.T("Right"), above = DDT.T("Above"),
    below = DDT.T("Below")}
local FILLS = {{"stripes", DDT.T("Stripes")}, {"solid", DDT.T("Solid")}, {"bar", DDT.T("Bar texture")}}
local OUTLINES = {{"none", DDT.T("None")}, {"solid", DDT.T("Solid")}}
local CURSE_MODES = {{"last", DDT.T("Last used")}, {"smart", DDT.T("Smart curse")}}
local SMART_CURSE_HELP = DDT.T("Shift casts Weakness, Ctrl Tongues, Alt Recklessness.")

-- A slider's value as whole-number text.
function DDT.WholeLabel(value)
    return string.format("%d", math.floor((tonumber(value) or 0) + 0.5))
end

local function HasSettingsAPI()
    if type(Settings) ~= "table" or type(Settings.VarType) ~= "table" then
        return false
    end
    for _, name in ipairs(REQUIRED_SETTINGS) do
        if type(Settings[name]) ~= "function" then
            return false
        end
    end
    return true
end

-- Settings sections (Dyre's Toolkit 2.17.0; John, 2026-11-26: a class AddOn
-- "should surface every setting in the wrapped addon's settings, and just
-- pass-through the setting to the wrapped addon"). One builder per section
-- draws its rows on our own page and on a host's page (Warlock Tools Forever,
-- Mage Tools Forever); both read and write DDT.db live. `building` is the
-- section context while a builder runs: every setting variable goes through
-- its variable(name) (the host's prefix; Blizzard refuses a variable
-- registered twice), and the name as is on our own page.
local building

local function Var(name)
    return building and building.variable(name) or name
end

local function Register(category, variable, ...)
    return Settings.RegisterProxySetting(category, Var(variable), ...)
end

local function Heading(layout, text)
    if type(CreateSettingsListSectionHeaderInitializer) == "function" and type(layout) == "table"
            and type(layout.AddInitializer) == "function" then
        layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(text))
    end
end

-- Greyed while this AddOn does not have the kind.
local function OnlyWhenOurs(initializer, kind)
    if initializer and type(initializer.AddModifyPredicate) == "function" then
        initializer:AddModifyPredicate(function() return DDT.Owns(kind) end)
    end
    return initializer
end

-- Under parent (indented) when the parent is on this page, and greyed while
-- predicate is false. Every predicate checks the whole chain of switches above
-- the row (John, 2026-11-27: "when the top-level is off, the settings that are
-- controlling a disabled feature should be disabled too"): the client greys a
-- child only by its own parent, so a grandchild stayed active, and a host's
-- sub-page has no top switch at all.
--
-- The client evaluates a row's greying again only when its DIRECT parent's
-- setting changes (Blizzard_SettingControls.lua 297-302), so a row also
-- watches every switch in its chain (Dyre's Toolkit WatchSettings: the
-- initializer's own AddEvaluateStateCVar), and greys live. `rowVariable`:
-- a switch row's setting variable; `chains`: the variables above a row. A
-- parent may be a Virtual switch: one drawn on another page (a host's top
-- page), watched by its variable but not nested under.
local rowVariable = setmetatable({}, {__mode = "k"})
local chains = setmetatable({}, {__mode = "k"})
local VIRTUAL = {}

local function Virtual(variable)
    return {[VIRTUAL] = true, variable = Var(variable)}
end

local function Chain(parent)
    local chain = {}
    if parent == nil then
        return chain
    end
    for _, variable in ipairs(chains[parent] or {}) do
        chain[#chain + 1] = variable
    end
    local own = parent[VIRTUAL] and parent.variable or rowVariable[parent]
    if own then
        chain[#chain + 1] = own
    end
    return chain
end

local function Watch(initializer, chain)
    local toolkit = DDT.toolkit
    if initializer and #chain > 0 and toolkit and type(toolkit.WatchSettings) == "function" then
        toolkit.WatchSettings(initializer, chain)
    end
end

-- also: more switch variables the predicate reads (not in the parent chain).
local function Nest(child, parent, predicate, also)
    if not child then
        return child
    end
    if parent ~= nil and not parent[VIRTUAL] and type(child.SetParentInitializer) == "function" then
        child:SetParentInitializer(parent, predicate)
    end
    if predicate and type(child.AddModifyPredicate) == "function" then
        child:AddModifyPredicate(predicate)
    end
    local chain = Chain(parent)
    chains[child] = chain
    local watched = {unpack(chain)}
    for _, variable in ipairs(also or {}) do
        watched[#watched + 1] = Var(variable)
    end
    Watch(child, watched)
    return child
end

-- A button row that can be greyed: its label greys with its button (John,
-- 2026-11-27: "the inconsistent label enable/disable"; on WoW: Forever a
-- button row greys only its button). Dyre's Toolkit GreyButtonLabel,
-- feature-tested.
local function GreyLabel(initializer)
    local toolkit = DDT.toolkit
    if initializer and toolkit and type(toolkit.GreyButtonLabel) == "function" then
        toolkit.GreyButtonLabel(initializer)
    end
    return initializer
end

-- A button row greyed while predicate is false (a Reset of a feature that is
-- off), watching the chain from parent down.
local function Greyed(initializer, predicate, parent)
    GreyLabel(initializer)
    if initializer and type(initializer.AddModifyPredicate) == "function" then
        initializer:AddModifyPredicate(predicate)
    end
    Watch(initializer, Chain(parent))
    return initializer
end

-- A switch row: its variable, for the rows nested under it.
local function Switch(initializer, variable)
    if initializer then
        rowVariable[initializer] = Var(variable)
    end
    return initializer
end

-- Shown only while the chosen look is this one (the list checks it again on
-- each setting change).
local function ShowFor(initializer, predicate)
    if initializer and type(initializer.AddShownPredicate) == "function" then
        initializer:AddShownPredicate(predicate)
    end
    return initializer
end

-- A color swatch (AARRGGBB, as WTF's), where the client has one.
local function Swatch(category, variable, name, table, key, default, tooltip, onChange)
    if type(Settings.CreateColorSwatch) ~= "function" then
        return nil
    end
    local setting = Register(category, variable, Settings.VarType.String, name, default,
        function() return table()[key] end,
        function(value)
            table()[key] = DDT.SanitizeColor(value, default)
            onChange()
        end)
    return Settings.CreateColorSwatch(category, setting, tooltip)
end

-- A button row (pinned Blizzard_SettingControls.lua: CreateSettingsButtonInitializer).
local function Button(layout, name, text, onClick, tooltip)
    if type(CreateSettingsButtonInitializer) == "function" and type(layout) == "table"
            and type(layout.AddInitializer) == "function" then
        local initializer = CreateSettingsButtonInitializer(name, text, onClick, tooltip, true)
        layout:AddInitializer(initializer)
        return initializer
    end
end

-- A checkbox for table()[key]; onChange runs after the value is stored.
local function Flag(category, variable, name, table, key, default, tooltip, onChange)
    local setting = Register(category, variable, Settings.VarType.Boolean, name, default,
        function() return table()[key] end,
        function(value)
            table()[key] = value == true
            onChange()
        end)
    return Switch(Settings.CreateCheckbox(category, setting, tooltip), variable)
end

-- A dropdown of {value, label} choices, where the client has one.
local function Choice(category, variable, name, table, key, default, choices, tooltip, onChange)
    if type(Settings.CreateDropdown) ~= "function" or type(Settings.CreateControlTextContainer) ~= "function" then
        return nil
    end
    local kind = type(default) == "number" and Settings.VarType.Number or Settings.VarType.String
    local setting = Register(category, variable, kind, name, default,
        function() return table()[key] end,
        function(value)
            table()[key] = value
            onChange()
        end)
    local function Options()
        local container = Settings.CreateControlTextContainer()
        for _, choice in ipairs(choices) do
            container:Add(choice[1], choice[2])
        end
        return container:GetData()
    end
    return Switch(Settings.CreateDropdown(category, setting, Options, tooltip), variable)
end

-- The Toolkit's gold mark at the slider's default (John, 2026-11-21: "set
-- notches on the sliders default values"). range = {min, max, default}.
local function DefaultTick(initializer, range)
    if initializer and DDT.toolkit and type(DDT.toolkit.AddDefaultTick) == "function" then
        DDT.toolkit.AddDefaultTick(initializer, range)
    end
    return initializer
end

-- A slider for table()[key], whole numbers from low to high, with the gold
-- default mark. label: how the number shows (DDT.WholeLabel when nil).
local function Slider(category, variable, name, table, key, default, low, high, tooltip, onChange, label)
    if type(Settings.CreateSlider) ~= "function" or type(Settings.CreateSliderOptions) ~= "function" then
        return nil
    end
    local setting = Register(category, variable, Settings.VarType.Number, name, default,
        function() return table()[key] end,
        function(value)
            if type(value) == "number" then
                table()[key] = math.max(low, math.min(high, math.floor(value + 0.5)))
                onChange()
            end
        end)
    local options = Settings.CreateSliderOptions(low, high, 1)
    if type(MinimalSliderWithSteppersMixin) == "table" and type(options.SetLabelFormatter) == "function" then
        -- Always a number: with no formatter the slider shows no value, and a
        -- thumb at 3 of 0-20 reads as 0 (John's Outline width, 2026-11-21).
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, label or DDT.WholeLabel)
    end
    return DefaultTick(Settings.CreateSlider(category, setting, options, tooltip),
        {min = low, max = high, step = 1, default = default})
end

-- "Tracker size": a percent slider on steps of 5, with the gold default mark.
local function TrackerSize(category, tooltip, onChange)
    if type(Settings.CreateSlider) ~= "function" or type(Settings.CreateSliderOptions) ~= "function" then
        return nil
    end
    local spec = DDT.TRACKER_SIZE
    local setting = Register(category, "DDT_DOTS_TRACKER_SIZE", Settings.VarType.Number,
        DDT.T("Tracker size"), spec.default,
        function()
            local dots = DDT.db.dots
            if dots.trackerSize ~= false then
                return dots.trackerSize
            end
            -- Sizes set one by one: the nearest percent of the chosen look.
            local theme = dots.theme == "bars" and "bars" or "compact"
            local key = theme == "bars" and "barWidth" or "iconSize"
            return DDT.SanitizeTrackerSize(dots.sizes[theme][key] * 100 / DDT.SizeDefault(theme, key))
        end,
        function(value)
            if type(value) == "number" then
                DDT.db.dots.trackerSize = DDT.SanitizeTrackerSize(value)
                DDT.ApplyTrackerSize(DDT.db.dots)
                onChange()
            end
        end)
    local options = Settings.CreateSliderOptions(spec.min, spec.max, spec.step)
    if type(MinimalSliderWithSteppersMixin) == "table" and type(options.SetLabelFormatter) == "function" then
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
            return string.format("%d%%", value)
        end)
    end
    return DefaultTick(Settings.CreateSlider(category, setting, options, tooltip), spec)
end

-- The line at the top of a page: who has this kind for your class.
local function Status(layout, kind, none)
    if not DDT.classData then
        Heading(layout, NO_CLASS)
        return false
    end
    local status = DDT.KindStatus(kind)
    if status == "none" then
        Heading(layout, none)
        return false
    end
    if status ~= "ours" then
        Heading(layout, string.format(DDT.T("%s shows these for you now, so these settings are greyed. Turn "
            .. "that feature off in %s to use these."), status, status))
    end
    return true
end

local function Dots() return DDT.db.dots end
local function Frost() return DDT.db.frost end
local function Brand() return DDT.db.brand end
local function Chill() return DDT.db.wintersChill end
local function Predict() return DDT.db.predict end
local function Control() return DDT.db.control end

-- The Mage's frozen and chilled arcs (Frost.lua; John, 2026-11-18). This
-- AddOn's own: never greyed for a Tools AddOn, which has none.
local function FrostSection(category, layout)
    if DDT.class ~= "MAGE" or not DDT.frostArcs then
        return
    end
    Heading(layout, DDT.T("Frozen and chilled"))
    local master = Flag(category, "DDT_FROST", DDT.T("Show frozen and chilled arcs"), Frost, "enabled", true,
        DDT.T("Shows an ice arc above each enemy nameplate while the mob is Frozen, and a thin frost arc "
            .. "while your Chill is on it."), DDT.RefreshFrost)
    local function On() return DDT.db.frost.enabled end
    local offset, size = DDT.FROST_OFFSET, DDT.FROST_SIZE
    Nest(Slider(category, "DDT_FROST_OFFSET", DDT.T("Arc height"), Frost, "offset", offset.default, offset.min,
        offset.max, DDT.T("How far above the nameplate the arcs sit."), DDT.RefreshFrost), master, On)
    Nest(Slider(category, "DDT_FROST_SIZE", DDT.T("Arc size"), Frost, "size", size.default, size.min, size.max,
        DDT.T("The size of the arcs."), DDT.RefreshFrost), master, On)
end

-- Cues the player has not learned (John, 2026-11-27: "I expect to see every
-- setting available for warlocks, but only enabled if I have it. Not a
-- generic banner"): every row stays, greyed while known() is false, its
-- tooltip ending as the Toolkit's proc rows do. The tooltip is a function, so
-- it reads the talent as the row shows.
local function Learned(text, label, known)
    return function()
        return text .. (known() and "" or string.format(DDT.T(" Greyed out: you have not learned %s yet."),
            label))
    end
end

local function NeedsKnown(initializer, known)
    if initializer and type(initializer.AddModifyPredicate) == "function" then
        initializer:AddModifyPredicate(known)
    end
    return initializer
end

-- The Mage's Winter's Chill arc (Frost.lua; John, 2026-11-22: "add a
-- similar halo above the nameplate ... with up to 5 cells (one per charge)").
-- Greyed without the Winter's Chill talent (John, 2026-11-23: "make sure this
-- only shows if the player has the talent for it"). Every change applies at
-- once.
local function ChillSection(category, layout)
    if DDT.class ~= "MAGE" or not DDT.chillArcs then
        return
    end
    local known, name = DDT.ChillTalentKnown, DDT.T("Winter's Chill")
    local function Tip(text) return Learned(text, name, known) end
    Heading(layout, name)
    local master = NeedsKnown(Flag(category, "DDT_CHILL", DDT.T("Show"), Chill, "enabled", true,
        Tip(DDT.T("Shows a five-part ice arc above an enemy's nameplate, one part turning white for each stack "
            .. "of your Winter's Chill.")), DDT.RefreshChill), known)
    local function On() return DDT.db.wintersChill.enabled end
    local offset, size = DDT.CHILL_OFFSET, DDT.CHILL_SIZE
    NeedsKnown(Nest(Slider(category, "DDT_CHILL_SIZE", DDT.T("Size"), Chill, "size", size.default, size.min,
        size.max, Tip(DDT.T("The size of the arc.")), DDT.RefreshChill,
        function(value) return string.format("%d%%", value) end), master, On), known)
    NeedsKnown(Nest(Slider(category, "DDT_CHILL_OFFSET", DDT.T("Height above nameplate"), Chill, "offset",
        offset.default, offset.min, offset.max, Tip(DDT.T("How far above the nameplate the arc sits.")),
        DDT.RefreshChill), master, On), known)
    NeedsKnown(GreyLabel(Button(layout, DDT.T("Preview Winter's Chill"), DDT.T("Preview"), DDT.PreviewChill,
        Tip(DDT.T("Shows the arc on your target's nameplate so you can set its size and height. Press again to "
            .. "hide it.")))),
        known)
    -- The stack chime (Chime.lua): the combat log (Classic Era) or the game's
    -- aura sounds (WoW: Forever).
    local chimeMode = DDT.ChillChimeMode()
    if chimeMode then
        local about = chimeMode == "aura"
            and DDT.T("Plays a note when Winter's Chill goes on your target and as each stack is added. "
                .. "Needs Dyre's Sounds.")
            or DDT.T("Plays a rising note as each stack of your Winter's Chill goes on your target. "
                .. "Needs Dyre's Sounds.")
        NeedsKnown(Flag(category, "DDT_CHILL_CHIME", DDT.T("Stack chime"), Chill, "chime", true, Tip(about),
            DDT.RefreshChillChime), known)
        local function ChimeOn() return DDT.db.wintersChill.chime end
        local sets = {}
        for _, key in ipairs(DDT.CHILL_CHIME_ORDER) do
            sets[#sets + 1] = {key, DDT.T(DDT.CHILL_CHIME_SETS[key].label)}
        end
        local noteSet = Choice(category, "DDT_CHILL_NOTESET", DDT.T("Note set"), Chill, "noteSet",
            DDT.CHILL_CHIME_DEFAULT, sets, Tip(DDT.T("The instrument the chime plays.")), function()
                DDT.RefreshChillChime()
                DDT.PlayChillNote(DDT.ChillChimeNote(DDT.CHILL_MOST, DDT.db.wintersChill.noteSet, chimeMode),
                    "Winter's Chill")
            end)
        if noteSet and type(noteSet.AddModifyPredicate) == "function" then
            noteSet:AddModifyPredicate(ChimeOn)
            Watch(noteSet, {Var("DDT_CHILL_CHIME")})
        end
        NeedsKnown(noteSet, known)
        NeedsKnown(GreyLabel(Button(layout, DDT.T("Test the stack chime"), DDT.T("Test"), DDT.TestChillChime,
            Tip(string.format(DDT.T("Plays the chime for stacks 1 to %d."), DDT.CHILL_MOST)))), known)
    end
    NeedsKnown(GreyLabel(Button(layout, DDT.T("Reset Winter's Chill"), DDT.T("Reset"), DDT.ResetChill,
        Tip(DDT.T("Puts the Winter's Chill settings back to their defaults.")))), known)
end

-- The Warlock's Demonic Brand pentagram (Frost.lua; John, via the lead,
-- 2026-11-21: "Make it a glowing red pentagram that renders above the
-- nameplate, and make it so the size and height can be adjusted"). Only
-- where the client knows the debuff (Forever); greyed without the talent
-- (DDT.BrandTalentKnown, read as the page draws). Every change applies at
-- once.
local function BrandSection(category, layout)
    if DDT.class ~= "WARLOCK" or not DDT.brandArcs then
        return
    end
    local known, name = DDT.BrandTalentKnown, DDT.T("Demonic Brand")
    local function Tip(text) return Learned(text, name, known) end
    Heading(layout, name)
    local master = NeedsKnown(Flag(category, "DDT_BRAND", DDT.T("Show"), Brand, "enabled", true,
        Tip(DDT.T("Shows a glowing red pentagram above an enemy's nameplate while your Demonic Brand is on "
            .. "it.")), DDT.RefreshBrand), known)
    local function On() return DDT.db.brand.enabled end
    local offset, size = DDT.BRAND_OFFSET, DDT.BRAND_SIZE
    NeedsKnown(Nest(Slider(category, "DDT_BRAND_SIZE", DDT.T("Size"), Brand, "size", size.default, size.min,
        size.max, Tip(DDT.T("The size of the pentagram.")), DDT.RefreshBrand,
        function(value) return string.format("%d%%", value) end), master, On), known)
    NeedsKnown(Nest(Slider(category, "DDT_BRAND_OFFSET", DDT.T("Height above nameplate"), Brand, "offset",
        offset.default, offset.min, offset.max, Tip(DDT.T("How far above the nameplate the pentagram sits.")),
        DDT.RefreshBrand), master, On), known)
    NeedsKnown(GreyLabel(Button(layout, DDT.T("Preview Demonic Brand"), DDT.T("Preview"), DDT.PreviewBrand,
        Tip(DDT.T("Shows the pentagram on your target's nameplate so you can set its size and height. Press "
            .. "again to hide it.")))),
        known)
    NeedsKnown(GreyLabel(Button(layout, DDT.T("Reset Demonic Brand"), DDT.T("Reset"), DDT.ResetBrand,
        Tip(DDT.T("Puts the Demonic Brand settings back to their defaults.")))), known)
end

-- A percent slider for a panel's Tracker size (DDT.TRACKER_SIZE); false
-- (sizes set one by one) shows the nearest percent of the chosen look.
local function PanelTrackerSize(category, variable, panel, tooltip, onChange)
    if type(Settings.CreateSlider) ~= "function" or type(Settings.CreateSliderOptions) ~= "function" then
        return nil
    end
    local spec = DDT.TRACKER_SIZE
    local setting = Register(category, variable, Settings.VarType.Number, DDT.T("Tracker size"),
        spec.default,
        function()
            local own = panel()
            if own.trackerSize ~= false then
                return own.trackerSize
            end
            local theme = DDT.db.dots.theme == "bars" and "bars" or "compact"
            local key = theme == "bars" and "barWidth" or "iconSize"
            return DDT.SanitizeTrackerSize(own.sizes[theme][key] * 100 / DDT.SizeDefault(theme, key))
        end,
        function(value)
            if type(value) == "number" then
                local own = panel()
                own.trackerSize = DDT.SanitizeTrackerSize(value)
                DDT.ApplyTrackerSize(own)
                onChange()
            end
        end)
    local options = Settings.CreateSliderOptions(spec.min, spec.max, spec.step)
    if type(MinimalSliderWithSteppersMixin) == "table" and type(options.SetLabelFormatter) == "function" then
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
            return string.format("%d%%", value)
        end)
    end
    return DefaultTick(Settings.CreateSlider(category, setting, options, tooltip), spec)
end

-- The Panels section (the Toolkit's TRACKER_PANEL_OPTIONS; John, 2026-11-21:
-- "The panel settings need to be organized by the panel they control, and
-- each needs it's own config (size, border width, etc.) In the "Panels"
-- section, with a sub-section heading for Target, Focus, and Other"; "The
-- show mob health checkbox, and text config ... are missing from the
-- Target/Focus/Others boxes"). One sub-section per panel, each with its own
-- switch, health, frame, outline (Target and Focus: the list has none),
-- grow, sizes, color, opacity, and Reset.
local function PanelSections(category, layout, master, On, Changed, Rebuilt)
    local toolkit = DDT.toolkit
    Heading(layout, DDT.T("Panels"))
    for _, entry in ipairs(PANEL_NAMES) do
        local key, name = entry[1], entry[2]
        local id = "DDT_PANEL_" .. key:upper() .. "_"
        local function Panel() return DDT.db.dots.panels[key] end
        local function PanelOn() return DDT.db.dots.enabled end
        Heading(layout, string.format(DDT.T("%s panel"), name))
        if type(toolkit.TRACKER_PANELS) == "table" then
            local function Show() return DDT.db.dots.show end
            Nest(OnlyWhenOurs(Flag(category, "DDT_DOTS_SHOW_" .. key:upper(),
                string.format(DDT.T("Show %s panel"), name), Show, key, true,
                key == "list" and DDT.T("Shows the panel for the other mobs you DoT.")
                    or string.format(DDT.T("Shows the panel for your %s's DoTs."), DDT.T(key)), Changed), "dots"),
                master, On)
        end
        local health = Nest(OnlyWhenOurs(Flag(category, id .. "HEALTH", DDT.T("Show mob health"), Panel, "health",
            false, DDT.T("Turns the line with the mob's name into its health bar."), Rebuilt), "dots"), master, On)
        Nest(OnlyWhenOurs(Choice(category, id .. "HEALTH_TEXT", DDT.T("Health text"), Panel, "healthText", "none",
            HEALTH_TEXTS, DDT.T("Shows the mob's health after its name, as a number, a percent, or both."),
            Rebuilt), "dots"), health, function() return PanelOn() and Panel().health end)
        if toolkit.TRACKER_FRAME == true then
            Nest(OnlyWhenOurs(Flag(category, id .. "FRAME", DDT.T("Show panel frame"), Panel, "frame", true,
                DDT.T("Shows the background and border behind each mob's name and DoTs."), Changed), "dots"),
                master, On)
        end
        if key ~= "list" and type(toolkit.TRACKER_OUTLINE) == "table" then
            local outline = DDT.OUTLINE_WIDTH
            Nest(OnlyWhenOurs(Slider(category, id .. "OUTLINE", DDT.T("Outline width"), Panel, "outlineWidth",
                outline.default, outline.min, outline.max,
                string.format(DDT.T("The width of the colored outline around the %s panel; 0 hides it."), name),
                Rebuilt), "dots"), master, On)
        end
        if type(toolkit.TRACKER_GROW) == "table" then
            local function Grow() return DDT.db.dots.grow end
            Nest(OnlyWhenOurs(Choice(category, "DDT_DOTS_GROW_" .. key:upper(), DDT.T("Grow"), Grow, key, "down",
                GROW_CHOICES, key == "list"
                    and DDT.T("Whether new DoTs and new mobs are added above or below the first one.")
                    or DDT.T("Whether new DoTs are added above or below the first one."), Rebuilt), "dots"),
                master, On)
        end
        Nest(OnlyWhenOurs(PanelTrackerSize(category, id .. "TRACKER_SIZE", Panel,
            DDT.T("The length of this panel's DoT bars, or the size of its icons in the Compact look."), Rebuilt),
            "dots"), master, On)
        for _, theme in ipairs({"compact", "bars"}) do
            local function ThisLook() return DDT.db.dots.theme == theme end
            local function Sizes() return Panel().sizes[theme] end
            local look = theme == "bars" and DDT.T("Bars") or DDT.T("Compact")
            for _, spec in ipairs(DDT.SIZE_SPECS[theme]) do
                local label = SIZE_LABELS[spec.key]
                local setting = Register(category, id .. theme:upper() .. "_" .. spec.key:upper(),
                    Settings.VarType.Number, label, spec.default,
                    function() return Sizes()[spec.key] end,
                    function(value)
                        if type(value) == "number" then
                            local saved = {}
                            for each, current in pairs(Sizes()) do
                                saved[each] = current
                            end
                            saved[spec.key] = value
                            Panel().sizes[theme] = DDT.SanitizeSizes(theme, saved)
                            Panel().trackerSize = false
                            Rebuilt()
                        end
                    end)
                if type(Settings.CreateSlider) == "function" and type(Settings.CreateSliderOptions) == "function" then
                    local options = Settings.CreateSliderOptions(spec.min, spec.max, spec.step)
                    if type(MinimalSliderWithSteppersMixin) == "table"
                            and type(options.SetLabelFormatter) == "function" then
                        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, spec.key == "textScale"
                            and function(value) return string.format("%d%%", value) end or DDT.WholeLabel)
                    end
                    Nest(ShowFor(OnlyWhenOurs(DefaultTick(Settings.CreateSlider(category, setting, options,
                        SIZE_TIPS[spec.key] or string.format(DDT.T("In the %s look, this panel's %s."), look,
                            label:lower())), spec), "dots"), ThisLook), master, On)
                end
            end
            local positions = {}
            for _, position in ipairs(DDT.NAME_POSITIONS[theme]) do
                positions[#positions + 1] = {position, NAME_POSITION_LABELS[position]}
            end
            Nest(ShowFor(OnlyWhenOurs(Choice(category, id .. theme:upper() .. "_NAMEPOSITION",
                DDT.T("Name position"), Sizes, "namePosition", DDT.DEFAULT_NAME_POSITION[theme], positions,
                DDT.T("Where the mob's name sits in this panel's rows."), Rebuilt), "dots"), ThisLook), master, On)
        end
        local function PanelColors() return DDT.db.dots.panelColors end
        local function PanelOpacity() return DDT.db.dots.panelOpacity end
        Nest(OnlyWhenOurs(Swatch(category, "DDT_DOTS_PANEL_COLOR_" .. key:upper(), DDT.T("Panel color"),
            PanelColors, key, DDT.PANEL_COLORS[key], key == "list"
                and DDT.T("The color of the other mobs' row borders and health bars.")
                or string.format(DDT.T("The color of the %s panel's outline and health bar."), name),
            Changed), "dots"), master, On)
        Nest(OnlyWhenOurs(Slider(category, "DDT_DOTS_PANEL_OPACITY_" .. key:upper(), DDT.T("Panel opacity"),
            PanelOpacity, key, 100, 10, 100,
            string.format(DDT.T("How solid the %s panel is."), name), DDT.RefreshPanelOpacity), "dots"),
            master, On)
        Greyed(Button(layout, string.format(DDT.T("%s panel"), name),
            string.format(DDT.T("Reset %s panel"), name), function()
            DDT.ResetPanel(key)
        end, DDT.T("Puts this panel's settings back to their defaults.")), On, master)
    end
end

-- The DoT tracker's Enable row, per layout: the "dots" section nests its rows
-- under it when "tracker" drew it on the same page (our own DoTs page).
local masters = setmetatable({}, {__mode = "k"})

-- Which part of a section to draw (SETTINGS_SECTIONS_VERSION 3; John,
-- 2026-11-27: "the top-level disable for each section should be on the
-- top-level MTF panel"): "master" only the section's top switch (a host's top
-- page), "rest" everything else (the host's sub-page), "all" both (our own
-- page, and any host before version 3).
local function Part(ctx)
    local toolkit = DDT.toolkit
    if not toolkit or (tonumber(toolkit.SETTINGS_SECTIONS_VERSION) or 0) < 3 then
        return "all"
    end
    return (ctx.part == "master" or ctx.part == "rest") and ctx.part or "all"
end

-- Whether a section of this kind has anything for the player's class. On a
-- host page, nothing is drawn when not (the builder returns false, and the
-- host shows its link).
local function HasKind(ctx, kind)
    if not DDT.classData or (ctx.class ~= nil and ctx.class ~= DDT.class) then
        return false
    end
    return DDT.KindStatus(kind) ~= "none"
end

-- "tracker": the DoT tracker, its panels, the smart curse, and the damage to
-- come (Warlock Tools Forever's "DoT Tracker" page).
local function TrackerSection(category, layout, ctx)
    local part = Part(ctx)
    if not ctx.own and not HasKind(ctx, "dots") then
        return false
    end
    local function Changed() DDT.RefreshDots(false) end
    local function Rebuilt() DDT.RefreshDots(true) end
    -- On a host's top page the switches of several AddOns sit together, so
    -- there it names its feature and points to the sub-page (Toolkit lead,
    -- 2026-11-27).
    local function EnableRow()
        local about = DDT.T("Shows timer bars for your DoTs on your target, your focus, and other mobs.")
        if part == "master" then
            return OnlyWhenOurs(Flag(category, "DDT_DOTS", TITLES.tracker, Dots, "enabled", true, about, Changed),
                "dots")
        end
        return OnlyWhenOurs(Flag(category, "DDT_DOTS", DDT.T("Enable DoT tracker"), Dots, "enabled", true, about,
            Changed), "dots")
    end
    -- A host's top page: the top switch alone.
    if part == "master" then
        if not HasKind(ctx, "dots") then
            return false
        end
        EnableRow()
        return true
    end
    if not Status(layout, "dots", NO_DOTS) then
        return true
    end
    -- A host's sub-page ("rest") has no Enable row: its rows are greyed by
    -- the chain alone.
    local master = part == "all" and EnableRow() or nil
    masters[layout] = master
    master = master or Virtual("DDT_DOTS")
    local function On() return DDT.db.dots.enabled end
    -- Per-panel settings (TRACKER_PANEL_OPTIONS): the size, health, frame,
    -- outline, switch, and grow rows move into each panel's sub-section.
    -- With an older Toolkit the tracker-wide rows stay as they were.
    local perPanel = DDT.PerPanel()
    Nest(OnlyWhenOurs(Choice(category, "DDT_DOTS_THEME", DDT.T("Theme"), Dots, "theme", "bars", THEMES,
        DDT.T("Compact shows an icon per DoT; Bars shows a timer bar per DoT."), Rebuilt), "dots"),
        master, On)
    if not perPanel then
    Nest(OnlyWhenOurs(TrackerSize(category, DDT.T("The length of the DoT bars, or the size of the icons in the "
        .. "Compact look."), Rebuilt), "dots"), master, On)
    -- Each look's own sizes and name place (WTF's, moved here). A change here
    -- sets the sizes one by one: Tracker size then shows the nearest percent.
    for _, theme in ipairs({"compact", "bars"}) do
        local function ThisLook() return DDT.db.dots.theme == theme end
        local function Sizes() return DDT.db.dots.sizes[theme] end
        local look = theme == "bars" and DDT.T("Bars") or DDT.T("Compact")
        for _, spec in ipairs(DDT.SIZE_SPECS[theme]) do
            local label = SIZE_LABELS[spec.key]
            local setting = Register(category, "DDT_DOTS_" .. theme:upper() .. "_"
                .. spec.key:upper(), Settings.VarType.Number, label, spec.default,
                function() return Sizes()[spec.key] end,
                function(value)
                    if type(value) == "number" then
                        local saved = {}
                        for name, current in pairs(Sizes()) do
                            saved[name] = current
                        end
                        saved[spec.key] = value
                        DDT.db.dots.sizes[theme] = DDT.SanitizeSizes(theme, saved)
                        DDT.db.dots.trackerSize = false
                        Rebuilt()
                    end
                end)
            if type(Settings.CreateSlider) == "function" and type(Settings.CreateSliderOptions) == "function" then
                local options = Settings.CreateSliderOptions(spec.min, spec.max, spec.step)
                if type(MinimalSliderWithSteppersMixin) == "table" and type(options.SetLabelFormatter) == "function" then
                    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, spec.key == "textScale"
                        and function(value) return string.format("%d%%", value) end or DDT.WholeLabel)
                end
                Nest(ShowFor(OnlyWhenOurs(DefaultTick(Settings.CreateSlider(category, setting, options,
                    SIZE_TIPS[spec.key] or string.format(DDT.T("In the %s look, the DoT tracker's %s."), look,
                        label:lower())), spec), "dots"), ThisLook), master, On)
            end
        end
        local positions = {}
        for _, key in ipairs(DDT.NAME_POSITIONS[theme]) do
            positions[#positions + 1] = {key, NAME_POSITION_LABELS[key]}
        end
        Nest(ShowFor(OnlyWhenOurs(Choice(category, "DDT_DOTS_" .. theme:upper() .. "_NAMEPOSITION",
            DDT.T("Name position"), Sizes, "namePosition", DDT.DEFAULT_NAME_POSITION[theme], positions,
            DDT.T("Where the mob's name sits in each row."), Rebuilt), "dots"), ThisLook), master, On)
    end
    Greyed(Button(layout, DDT.T("Tracker size"), DDT.T("Reset size"), function()
        local dots = DDT.db.dots
        dots.sizes[dots.theme] = DDT.SanitizeSizes(dots.theme, nil)
        dots.trackerSize = false
        Rebuilt()
    end, DDT.T("Puts this look's sizes and name position back to their defaults.")), On, master)
    end
    -- Hide empty DoT slots (treadpool, a player, 2026-11-17: "Would be cleaner
    -- if it only showed the DoTs that are actively ticking"; John: "Yes, build
    -- it"): only with a Toolkit that has it (TRACKER_HIDE_EMPTY).
    if DDT.toolkit and DDT.toolkit.TRACKER_HIDE_EMPTY == true then
        Nest(OnlyWhenOurs(Flag(category, "DDT_DOTS_HIDE_EMPTY", DDT.T("Hide empty DoT slots"), Dots, "hideEmpty",
            false, DDT.T("Shows a DoT only while it is on the mob. A click on the target or focus row then "
                .. "recasts nothing."), Rebuilt), "dots"), master, On)
    end
    if not perPanel then
    -- Show or hide each panel (a player, 2026-11-19: "Is there a way to
    -- disable the target dot window or hide it?"; John: "a 3 panels toggle
    -- show/off, default to show. A checkbox is fine for now."): only with a
    -- Toolkit that has it (TRACKER_PANELS). The tracker reads it live.
    if DDT.toolkit and type(DDT.toolkit.TRACKER_PANELS) == "table" then
        local function Show() return DDT.db.dots.show end
        for _, panel in ipairs(PANEL_NAMES) do
            Nest(OnlyWhenOurs(Flag(category, "DDT_DOTS_SHOW_" .. panel[1]:upper(),
                string.format(DDT.T("Show %s panel"), panel[2]), Show, panel[1], true, panel[1] == "list"
                    and DDT.T("Shows the panel for the other mobs you DoT.")
                    or string.format(DDT.T("Shows the panel for your %s's DoTs."), PANEL_KEYS[panel[1]]),
                Changed), "dots"), master, On)
        end
    end
    -- GitHub issue 1 (a player, 2026-11-20: "When a target is selected, a
    -- frame appears with a purple border. I'd like to hide all of that and only
    -- show the debuff bars."; John: "Build parts 1 and 2"). The frame: only
    -- with a Toolkit that has it (TRACKER_FRAME). The outline: TRACKER_OUTLINE.
    if DDT.toolkit and DDT.toolkit.TRACKER_FRAME == true then
        Nest(OnlyWhenOurs(Flag(category, "DDT_DOTS_FRAME", DDT.T("Show panel frame"), Dots, "frame", true,
            DDT.T("Shows the background and border behind each mob's name and DoTs."), Changed), "dots"), master,
            On)
    end
    if DDT.toolkit and type(DDT.toolkit.TRACKER_OUTLINE) == "table" then
        local outline = DDT.OUTLINE_WIDTH
        Nest(OnlyWhenOurs(Slider(category, "DDT_DOTS_OUTLINE", DDT.T("Outline width"), Dots, "outlineWidth",
            outline.default, outline.min, outline.max,
            string.format(DDT.T("The width of the colored outline around the %s and %s panels; 0 hides it."),
                DDT.T("Target"), DDT.T("Focus")), Rebuilt), "dots"), master, On)
    end
    -- Grow direction per panel: only with a Toolkit that has it (TRACKER_GROW).
    if DDT.toolkit and type(DDT.toolkit.TRACKER_GROW) == "table" then
        local function Grow() return DDT.db.dots.grow end
        for _, panel in ipairs(PANEL_NAMES) do
            Nest(OnlyWhenOurs(Choice(category, "DDT_DOTS_GROW_" .. panel[1]:upper(),
                string.format(DDT.T("Grow: %s"), panel[2]), Grow, panel[1], "down", GROW_CHOICES,
                panel[1] == "list"
                    and DDT.T("Whether new DoTs and new mobs are added above or below the first one.")
                    or DDT.T("Whether new DoTs are added above or below the first one."), Rebuilt), "dots"),
                master, On)
        end
    end
    local health = Nest(OnlyWhenOurs(Flag(category, "DDT_DOTS_HEALTH", DDT.T("Show mob health"), Dots, "health",
        false, DDT.T("Turns the line with the mob's name into its health bar."), Rebuilt), "dots"),
        master, On)
    Nest(OnlyWhenOurs(Choice(category, "DDT_DOTS_HEALTH_TEXT", DDT.T("Health text"), Dots, "healthText", "none",
        HEALTH_TEXTS, DDT.T("Shows the mob's health after its name, as a number, a percent, or both."), Rebuilt),
        "dots"), health,
        function() return DDT.db.dots.enabled and DDT.db.dots.health end)
    end
    if perPanel then
        PanelSections(category, layout, master, On, Changed, Rebuilt)
    else
    -- Each panel's color and opacity (WTF's, moved here).
    Heading(layout, DDT.T("Panels"))
    local function PanelColors() return DDT.db.dots.panelColors end
    local function PanelOpacity() return DDT.db.dots.panelOpacity end
    for _, panel in ipairs(PANEL_NAMES) do
        local key, name = panel[1], panel[2]
        Nest(OnlyWhenOurs(Swatch(category, "DDT_DOTS_PANEL_COLOR_" .. key:upper(),
            string.format(DDT.T("%s panel color"), name), PanelColors, key, DDT.PANEL_COLORS[key],
            key == "list" and DDT.T("The color of the other mobs' row borders and health bars.")
                or string.format(DDT.T("The color of the %s panel's outline and health bar."), name),
            Changed), "dots"), master, On)
        Nest(OnlyWhenOurs(Slider(category, "DDT_DOTS_PANEL_OPACITY_" .. key:upper(),
            string.format(DDT.T("%s panel opacity"), name), PanelOpacity, key, 100, 10, 100,
            string.format(DDT.T("How solid the %s panel is."), name), DDT.RefreshPanelOpacity), "dots"),
            master, On)
    end
    end
    -- The Warlock's smart curse (WTF's, moved here; Toolkit 2.7.0).
    if DDT.class == "WARLOCK" and DDT.dotTracker and type(DDT.dotTracker.ApplySmartCurse) == "function" then
        Heading(layout, DDT.T("Curse slot"))
        local mode = Nest(OnlyWhenOurs(Choice(category, "DDT_DOTS_CURSE_MODE", DDT.T("Curse slot click"), Dots,
            "curseMode", "last", CURSE_MODES,
            string.format(DDT.T("What a click on the Curse slot casts: the curse you cast last, or the best "
                .. "curse for that mob. %s"), SMART_CURSE_HELP), DDT.ApplySmartCurse), "dots"), master, On)
        Nest(OnlyWhenOurs(Flag(category, "DDT_DOTS_CURSE_MARKER", DDT.T("Show the smart curse letter"), Dots,
            "curseMarker", true, DDT.T("Shows a letter on the Curse slot for that mob's best curse: T Tongues, E "
                .. "Elements, W Weakness."), DDT.ApplySmartCurse), "dots"),
            mode, function() return DDT.db.dots.enabled and DDT.db.dots.curseMode == "smart" end)
        -- "! Curse": the DoT tracker's, not crowd control's (John, 2026-11-27:
        -- "Keep ! Curse separate").
        Nest(OnlyWhenOurs(Flag(category, "DDT_DOTS_CURSE_MACRO", DDT.T("Keep the \"! Curse\" macro"), Dots,
            "curseMacro", true, DDT.T("Keeps a \"! Curse\" macro that casts the smart curse. Off deletes it."),
            DDT.ApplyCurseMacro), "dots"), master, On)
    end
    if DDT.predictor then
        Heading(layout, DDT.T("Damage to come"))
        local predict = OnlyWhenOurs(Flag(category, "DDT_PREDICT", DDT.T("Show Predictive DoT Damage"), Predict,
            "enabled", true,
            DDT.T("Shows a striped block on the mob's health bar for the damage your DoTs still have to deal."),
            Changed), "dots")
        local function PredictOn() return DDT.db.predict.enabled end
        Nest(OnlyWhenOurs(Flag(category, "DDT_PREDICT_PLATES", DDT.T("Also on nameplates"), Predict, "plates",
            true, DDT.T("Shows the block on enemy nameplates too."), Changed), "dots"), predict, PredictOn)
        Nest(OnlyWhenOurs(Flag(category, "DDT_PREDICT_DIES", DDT.T("Show DIES"), Predict, "dies", true,
            DDT.T("Shows a red skull and DIES when your DoTs will kill the mob."), Changed), "dots"),
            predict, PredictOn)
        local colors = {}
        for _, preset in ipairs(DDT.PREDICT_COLORS) do
            colors[#colors + 1] = {preset.key, preset.label}
        end
        Nest(OnlyWhenOurs(Choice(category, "DDT_PREDICT_FILL", DDT.T("Block fill"), Predict, "fill", "stripes",
            FILLS, DDT.T("How the block is drawn: stripes, one solid color, or the texture of the bar it sits "
                .. "on."), Changed), "dots"), predict, PredictOn)
        Nest(OnlyWhenOurs(Choice(category, "DDT_PREDICT_COLOR", DDT.T("Block color"), Predict, "color", "purple",
            colors, DDT.T("The block's color."), Changed), "dots"), predict, PredictOn)
        Nest(OnlyWhenOurs(Slider(category, "DDT_PREDICT_OPACITY", DDT.T("Block opacity"), Predict, "opacity", 70,
            20, 100, DDT.T("How solid the block is, in percent."), Changed), "dots"), predict, PredictOn)
        Nest(OnlyWhenOurs(Choice(category, "DDT_PREDICT_OUTLINE", DDT.T("Block outline"), Predict, "outline",
            "solid", OUTLINES, DDT.T("Draws a thin line around the block."), Changed), "dots"),
            predict, PredictOn)
        -- Where DIES goes (John, 2026-11-09): target and focus frames, then nameplates.
        local function DiesOn() return DDT.db.predict.enabled and DDT.db.predict.dies end
        local function PlateDiesOn() return DiesOn() and DDT.db.predict.plates end
        local range = DDT.DIES_OFFSET
        for _, part in ipairs({{"DIES", "dies", DDT.T("target and focus"), DDT.T("your target and focus frames"),
                    DiesOn, {"DDT_PREDICT_DIES"}},
                {"PLATE_DIES", "plateDies", DDT.T("nameplates"), DDT.T("nameplates"), PlateDiesOn,
                    {"DDT_PREDICT_DIES", "DDT_PREDICT_PLATES"}}}) do
            local id, key, short, long, on, also = part[1], part[2], part[3], part[4], part[5], part[6]
            Nest(OnlyWhenOurs(Choice(category, "DDT_PREDICT_" .. id .. "_PLACE",
                string.format(DDT.T("DIES place: %s"), short), Predict, key .. "Place", "auto", DDT.DIES_PLACES,
                string.format(DDT.T("Where DIES shows on %s."), long), Changed), "dots"), predict, on, also)
            Nest(OnlyWhenOurs(Slider(category, "DDT_PREDICT_" .. id .. "_X",
                string.format(DDT.T("DIES left/right: %s"), short), Predict, key .. "X", 0, -range, range,
                string.format(DDT.T("Moves DIES left or right on %s."), long), Changed), "dots"),
                predict, on, also)
            Nest(OnlyWhenOurs(Slider(category, "DDT_PREDICT_" .. id .. "_Y",
                string.format(DDT.T("DIES down/up: %s"), short), Predict, key .. "Y", 0, -range, range,
                string.format(DDT.T("Moves DIES down or up on %s."), long), Changed), "dots"),
                predict, on, also)
        end
    end
    return true
end

-- "dots": the nameplate DoT dots and each DoT's place and color (Warlock
-- Tools Forever's "DoTs" page).
local function DotsSection(category, layout, ctx)
    -- No top switch of its own: its rows hang on the tracker's Enable (the
    -- "tracker" section's).
    if Part(ctx) == "master" then
        return false
    end
    local dots = HasKind(ctx, "dots") and #(DDT.classData.dots or {}) > 0
    if not ctx.own and not dots then
        return false
    end
    -- Our own DoTs page: under the tracker's Enable. On a page of its own, the
    -- rows are greyed while the tracker is off.
    local own = masters[layout]
    local master = own or Virtual("DDT_DOTS")
    local function On() return DDT.db.dots.enabled end
    local function Changed() DDT.RefreshDots(false) end
    local function Rebuilt() DDT.RefreshDots(true) end
    if dots and (own or Status(layout, "dots", NO_DOTS)) then
    local plates = Nest(OnlyWhenOurs(Flag(category, "DDT_DOTS_PLATES", DDT.T("Show DoT dots on nameplates"),
        Dots, "plateDots", false, DDT.T("Shows a dot above each enemy nameplate for each of your DoTs, lit while "
            .. "it is up."), Changed), "dots"), master, On)
    local function PlatesOn() return DDT.db.dots.enabled and DDT.db.dots.plateDots end
    Nest(OnlyWhenOurs(Slider(category, "DDT_DOTS_PLATES_OFFSET", DDT.T("Dot height above nameplates"), Dots,
        "plateDotsOffset", 50, 0, 120, DDT.T("How far above the nameplate the dots sit."), Changed), "dots"),
        plates, PlatesOn)
    Nest(OnlyWhenOurs(Slider(category, "DDT_DOTS_PLATES_OPACITY", DDT.T("Nameplate dot opacity"), Dots,
        "plateDotsOpacity", 100, 10, 100, DDT.T("How solid the nameplate dots are."),
        DDT.RefreshPlateDotsOpacity), "dots"), plates, PlatesOn)
    -- Fork 1.7.0-fork.1: the hover line (Toolkit 2.14.1-fork.1) and a warning
    -- shortly before a DoT ends (Warnings.lua).
    Nest(OnlyWhenOurs(Flag(category, "DDT_DOTS_HOVER_LINE", DDT.T("Gold line on hover"), Dots, "hoverLine",
        true, DDT.T("With the mouse on a row, or on a DoT icon of the target or focus row, gold sparks flow "
            .. "from the row to that mob's nameplate (else its target or focus frame). A locked tracker works "
            .. "on the icons; an unlocked one, on the whole row."), nil), "dots"), master, On)
    local dotWarn = Nest(OnlyWhenOurs(Flag(category, "DDT_DOTS_DOT_WARN",
        DDT.T("Flash a panel before a DoT ends"), Dots, "dotWarn", true,
        DDT.T("The target or focus panel flashes shortly before one of your DoTs on that mob runs out. "
            .. "It counts from your cast, so a dispel or a resist can make it early or late."), nil), "dots"),
        master, On)
    Nest(OnlyWhenOurs(Flag(category, "DDT_DOTS_WARN_SOUND", DDT.T("Chime with the DoT warning"), Dots,
        "warnSound", true, DDT.T("Play a sound with the flash."), nil), "dots"), dotWarn,
        function() return DDT.db.dots.enabled and DDT.db.dots.dotWarn end)
    -- Each DoT's place, color, and nameplate dot (WTF's DoTs page, moved here).
    local slots = DDT.classData.dots or {}
    if #slots > 0 then
        Heading(layout, DDT.T("Each DoT"))
        local choices = {}
        for _, slot in ipairs(slots) do
            choices[#choices + 1] = {slot.key, slot.label}
        end
        for index = 1, #slots do
            -- A slot picked here swaps places with the one that was there.
            local setting = Register(category, "DDT_DOTS_ORDER_" .. index,
                Settings.VarType.String, string.format(DDT.T("DoT %d"), index), slots[index].key,
                function() return DDT.db.dots.order[index] end,
                function(value)
                    local order = DDT.db.dots.order
                    for other, key in ipairs(order) do
                        if key == value and other ~= index then
                            order[other], order[index] = order[index], value
                            break
                        end
                    end
                    Rebuilt()
                end)
            if type(Settings.CreateDropdown) == "function"
                    and type(Settings.CreateControlTextContainer) == "function" then
                Nest(OnlyWhenOurs(Settings.CreateDropdown(category, setting, function()
                    local container = Settings.CreateControlTextContainer()
                    for _, choice in ipairs(choices) do
                        container:Add(choice[1], choice[2])
                    end
                    return container:GetData()
                end, string.format(DDT.T("The DoT in place %d on each row; picking another swaps the two."),
                    index)), "dots"), master, On)
            end
        end
        local function Colors() return DDT.db.dots.colors end
        local function OnPlates() return DDT.db.dots.onPlates end
        for _, slot in ipairs(slots) do
            Nest(OnlyWhenOurs(Swatch(category, "DDT_DOTS_COLOR_" .. slot.key:upper(),
                string.format(DDT.T("%s color"), DDT.T(slot.label)), Colors, slot.key,
                DDT.SanitizeColor(slot.color, "ffffffff"),
                string.format(DDT.T("The color of %s on the tracker's bars and nameplate dots."),
                    DDT.T(slot.label)), DDT.RefreshDotColors), "dots"), master, On)
            Nest(OnlyWhenOurs(Flag(category, "DDT_DOTS_ONPLATE_" .. slot.key:upper(),
                string.format(DDT.T("%s dot on nameplates"), DDT.T(slot.label)), OnPlates, slot.key,
                slot.dot ~= false, string.format(DDT.T("Shows a %s dot above nameplates."), DDT.T(slot.label)),
                Changed), "dots"), plates, PlatesOn)
        end
        Greyed(Button(layout, DDT.T("Each DoT"), DDT.T("Reset order and colors"), function()
            local dots = DDT.db.dots
            local clean = DDT.SanitizeDB({}, DDT.classData).dots
            dots.order, dots.colors = clean.order, clean.colors
            DDT.RefreshDotColors()
        end, DDT.T("Puts the DoTs' order and colors back to their defaults.")), On, master)
    end
    end
    return true
end

-- Whether the player's class has any debuff cue in this client.
local function HasCues()
    return (DDT.class == "MAGE" and (DDT.frostArcs ~= nil or DDT.chillArcs ~= nil))
        or (DDT.class == "WARLOCK" and DDT.brandArcs ~= nil)
end

-- "cues": this AddOn's own marks on enemy nameplates for a debuff (the
-- Mage's frozen, chilled, and Winter's Chill arcs; the Warlock's Demonic
-- Brand). Hosts draw it on their "Procs" page (John, 2026-11-27: "add all
-- the Warlock procs/alerts"), so it starts with its heading there. No single
-- top switch: each cue has its own Show.
local function CuesSection(category, layout, ctx)
    if Part(ctx) == "master" or (ctx.class ~= nil and ctx.class ~= DDT.class) or not HasCues() then
        return false
    end
    if not ctx.own then
        Heading(layout, TITLES.cues)
    end
    FrostSection(category, layout)
    ChillSection(category, layout)
    BrandSection(category, layout)
    return true
end

-- The control bar's size rows (the Toolkit's AddWidgetSettings, which names
-- its own variables). On a host page only with SETTINGS_SECTIONS_VERSION 2,
-- which maps them through opts.variable (the sliders and Reset's
-- NotifyUpdate); with version 1 they stay on our own page, so no variable is
-- registered twice.
local function WidgetRows(category, layout, widget, ctx, modify, parent)
    local toolkit = DDT.toolkit
    -- modify (SETTINGS_SECTIONS_VERSION 3): greyed while the bar is off.
    local opts = {labels = {scale = DDT.T("Bar size")}, modify = modify}
    -- opts.watch: the switches above, so the rows grey live.
    local chain = Chain(parent)
    if #chain > 0 and type(toolkit.WatchSettings) == "function" then
        opts.watch = chain
    end
    if not ctx.own then
        if (tonumber(toolkit.SETTINGS_SECTIONS_VERSION) or 0) < 2 then
            return
        end
        opts.variable = ctx.variable
    end
    toolkit.AddWidgetSettings(category, layout, widget, opts)
end

-- "control": the Control bar, its macros, and the announcements for the
-- player's class (Warlock Tools Forever's "Control" page: Fear, Banish,
-- Seduction; Mage Tools Forever's "Polymorph" page).
local function ControlSection(category, layout, ctx)
    local part = Part(ctx)
    if not ctx.own and not HasKind(ctx, "control") then
        return false
    end
    local function Changed() DDT.RefreshControl() end
    local function EnableRow()
        local off = DDT.T(" Off also stops the group messages and removes the \"!\" macros from your action "
            .. "bars.")
        local about = DDT.T("Shows a bar for each mob you control with its time left.") .. off
        if part == "master" then
            return OnlyWhenOurs(Flag(category, "DDT_CONTROL", TITLES.control, Control, "enabled", true, about,
                Changed), "control")
        end
        return OnlyWhenOurs(Flag(category, "DDT_CONTROL", DDT.T("Enable crowd control"), Control, "enabled",
            true, about, Changed), "control")
    end
    if part == "master" then
        EnableRow()
        return true
    end
    if not Status(layout, "control", NO_CONTROL) then
        return true
    end
    local spells = DDT.classData.control
    local master = part == "all" and EnableRow() or Virtual("DDT_CONTROL")
    local function On() return DDT.db.control.enabled end
    -- Everything follows the switch (John, 2026-11-27: "if the polymorph
    -- bar/macro master switch is off, disable all the functionality, not just
    -- the bar"; Toolkit 2.17.0 Control.lua: off sends no messages and deletes
    -- the macros), so every row is under it; the markers are the macros'.
    local macros = Nest(OnlyWhenOurs(Flag(category, "DDT_CONTROL_MACROS", DDT.T("Keep the control macros"),
        Control, "macros", true,
        DDT.T("Keeps a macro for each crowd-control spell you know (\"! Fear\", \"! Polymorph\", ...) that "
            .. "marks and casts on the mob under your mouse. Off deletes them."), Changed), "control"), master, On)
    local function MacrosOn() return DDT.db.control.enabled and DDT.db.control.macros end
    for _, spell in ipairs(spells) do
        if spell.plateTimer then
            Nest(OnlyWhenOurs(Flag(category, "DDT_CONTROL_PLATES", DDT.T("Timers on nameplates"), Control,
                "plateTimers", true, DDT.T("Shows a thin bar under each controlled mob's nameplate with its time "
                    .. "left."), Changed), "control"),
                master, On)
            break
        end
    end
    local markers = {}
    for _, marker in ipairs(DDT.toolkit.RAID_MARKERS) do
        markers[#markers + 1] = {marker.index, marker.label}
    end
    local function Markers() return DDT.db.control.markers end
    for _, spell in ipairs(spells) do
        if spell.marker then
            Nest(OnlyWhenOurs(Choice(category, "DDT_CONTROL_MARKER_" .. spell.key:upper(),
                string.format(DDT.T("%s marker"), DDT.T(spell.label)), Markers, spell.key, spell.marker, markers,
                string.format(DDT.T("The raid marker the macro puts on your %s target."), DDT.T(spell.label)),
                Changed), "control"), macros, MacrosOn)
        end
    end
    Heading(layout, DDT.T("Tell your group"))
    local function Announce() return DDT.db.control.announce end
    for _, spell in ipairs(spells) do
        Nest(OnlyWhenOurs(Flag(category, "DDT_ANNOUNCE_" .. spell.key:upper(), DDT.T(spell.label), Announce,
            spell.key, false, string.format(DDT.T("Tells your party or raid as you cast it: %s"),
                DDT.db.control.texts[spell.key]), Changed), "control"),
            master, On)
    end
    Nest(OnlyWhenOurs(Flag(category, "DDT_ANNOUNCE_SAY", DDT.T("Say instead of party or raid"), Control, "say",
        false, DDT.T("Sends the messages to Say instead, also when you are alone."), Changed), "control"),
        master, On)
    -- Fork 1.7.0-fork.1: flash the bar shortly before Banish ends (Warnings.lua).
    Nest(OnlyWhenOurs(Flag(category, "DDT_CONTROL_BANISH_WARN",
        DDT.T("Flash the bar before Banish ends"), Control, "banishWarn", true,
        DDT.T("The crowd-control bar flashes shortly before your Banish ends. It counts from your cast, "
            .. "so an early break can make it wrong."), nil), "control"), master, On)
    if DDT.controlWidget then
        WidgetRows(category, layout, DDT.controlWidget, ctx, On, master)
    end
    return true
end

-- The sections, by key (the contract with the host AddOns).
local SECTIONS = {
    {key = "tracker", title = TITLES.tracker, build = TrackerSection},
    {key = "dots", title = TITLES.dots, build = DotsSection},
    {key = "control", title = TITLES.control, build = ControlSection},
    {key = "cues", title = TITLES.cues, build = CuesSection},
}
local BUILDERS = {}
for _, section in ipairs(SECTIONS) do
    BUILDERS[section.key] = section.build
end

-- Runs one builder with ctx as the context its rows use.
local function Build(key, category, layout, ctx)
    local previous = building
    building = ctx
    local ok, added = pcall(BUILDERS[key], category, layout, ctx)
    building = previous
    if not ok then
        error(added, 0)
    end
    return added
end

-- The context for our own page: the Toolkit's (2.17.0), else the same shape
-- with the names as they are.
local function OwnContext(key)
    local toolkit = DDT.toolkit
    if toolkit and type(toolkit.OwnSettingsContext) == "function" then
        local ctx = toolkit.OwnSettingsContext("DyresDebuffTracker", key)
        if type(ctx) == "table" and type(ctx.variable) == "function" then
            return ctx
        end
    end
    return {host = "DyresDebuffTracker", owner = "DyresDebuffTracker", key = key, class = DDT.class, own = true,
        variable = function(name) return name end}
end

-- For tests and debug: a section's builder, as a host calls it.
function DDT.BuildSettingsSection(key, category, layout, ctx)
    if not BUILDERS[key] or type(ctx) ~= "table" or type(ctx.variable) ~= "function" or not HasSettingsAPI() then
        return false
    end
    -- A host may build before our PLAYER_LOGIN: start the engines now.
    if not DDT.EnsureStarted() then
        return false
    end
    return Build(key, category, layout, ctx) == true
end

-- At ADDON_LOADED (Core.lua): only with a Toolkit that has sections
-- (SETTINGS_SECTIONS_VERSION 1 or later); without one, the hosts keep their
-- links.
function DDT.RegisterSettingsSections()
    local toolkit = DyresToolkit
    if type(toolkit) ~= "table" or (tonumber(toolkit.SETTINGS_SECTIONS_VERSION) or 0) < 1
            or type(toolkit.RegisterSettingsSection) ~= "function" then
        return false
    end
    local all = true
    for _, section in ipairs(SECTIONS) do
        local key = section.key
        local ok = toolkit.RegisterSettingsSection({addon = "DyresDebuffTracker", key = key, title = section.title,
            build = function(category, layout, ctx)
                return DDT.BuildSettingsSection(key, category, layout, ctx)
            end})
        all = all and ok == true
    end
    DDT.sectionsRegistered = all
    return all
end

-- One page per section, named by its title.
local function Page(parent, key)
    local category, layout = Settings.RegisterVerticalLayoutSubcategory(parent, TITLES[key])
    Build(key, category, layout, OwnContext(key))
    return category
end

function DDT.InitializeOptions()
    if not HasSettingsAPI() then
        return
    end
    local category, layout = DDT.toolkit.RegisterSettingsCategory(DDT.TITLE)
    if not category then
        return
    end
    DDT.category = category
    if not DDT.classData then
        Heading(layout, NO_CLASS)
    elseif DDT.yieldsTo then
        Heading(layout, string.format(DDT.T("%s shows your DoTs and crowd control now. Turn it off, or update "
            .. "it, to use Dyre's Debuff Tracker for them."), DDT.yieldsTo.title))
    else
        Heading(layout, DDT.T("DoTs, crowd control, and debuff cues for your class; each has its own page "
            .. "below."))
    end
    DDT.dotsCategory = Page(category, "tracker")
    if DDT.classData and #(DDT.classData.dots or {}) > 0 then
        Page(category, "dots")
    end
    DDT.controlCategory = Page(category, "control")
    if HasCues() then
        Page(category, "cues")
    end
end
