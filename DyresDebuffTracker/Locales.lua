local _, DDT = ...

-- Text chosen by the client's language, as Warlock Tools Forever's Locales.lua:
-- GetLocale returns the locale code ("enUS", "zhCN", ...); a client without it,
-- or one whose language has no table here, uses English. DDT.L is this
-- client's table (the default announce texts), and DDT.T looks a line up in
-- the zhCN table; a line missing there still shows, in English. Spell and
-- item names never come through here: the Toolkit takes them from the client,
-- so they match its language exactly.

local enUS = {
    announce = {
        untargeted = "%s! - via Dyre's Debuff Tracker",
        targeted = "%s on >> %T <<%s - via Dyre's Debuff Tracker",
    },
}

-- Chinese: Snow White's fairy-tale voice (apples, the forest, the dwarfs),
-- without the credit line: MIT asks for no attribution in chat messages.
-- Settings copy stays plain, as the client's own.
local zhCN = {
    announce = {
        untargeted = "%s！",
        targeted = "%s：>> %T <<%s",
    },
}

DDT.LOCALES = {enUS = enUS, zhCN = zhCN}
DDT.L = DDT.LOCALES[type(GetLocale) == "function" and GetLocale() or "enUS"] or enUS

-- English UI text -> zhCN, keyed by the English line; a second argument picks
-- a context where one English word needs two Chinese ones.
local zhText = {
    -- Shared
    ["Enable"] = "启用",
    ["Show"] = "显示",
    ["Size"] = "大小",
    ["Theme"] = "主题",
    ["Panels"] = "框体",
    ["Auto"] = "自动",
    ["None"] = "无",
    ["Left"] = "左",
    ["Right"] = "右",
    ["Above"] = "上",
    ["Below"] = "下",
    ["Down"] = "向下",
    ["Up"] = "向上",
    ["Compact"] = "紧凑",
    ["Bars"] = "条形",
    ["Stripes"] = "条纹",
    ["Solid"] = "实心",
    ["fill|Solid"] = "实心",
    ["outline|Solid"] = "实线",
    ["Bar texture"] = "条材质",
    ["Number"] = "数字",
    ["Percent"] = "百分比",
    ["Number and percent"] = "数字和百分比",
    ["Last used"] = "上次使用",
    ["Smart curse"] = "智能诅咒",
    ["Target"] = "目标",
    ["Focus"] = "焦点",
    ["Others"] = "其他",
    ["Icon size"] = "图标大小",
    ["Name width"] = "名字宽度",
    ["Text size"] = "文字大小",
    ["Bar width"] = "条形宽度",
    ["Bar height"] = "条形高度",
    ["Line height"] = "行高",
    ["Name position"] = "名字位置",
    ["Tracker size"] = "追踪器大小",
    ["Reset size"] = "重置大小",
    ["Grow"] = "增长方向",
    ["Health text"] = "生命值文字",
    ["Show mob health"] = "显示怪物生命值",
    ["Show panel frame"] = "显示框体边框",
    ["Outline width"] = "边框宽度",
    ["Panel color"] = "框体颜色",
    ["Panel opacity"] = "框体不透明度",
    ["Show DoT dots on nameplates"] = "在姓名板上显示持续伤害圆点",
    ["Hide empty DoT slots"] = "隐藏空的持续伤害栏位",
    ["Dot height above nameplates"] = "姓名板上方圆点高度",
    ["Nameplate dot opacity"] = "姓名板圆点不透明度",
    ["Damage to come"] = "预计伤害",
    ["Show Predictive DoT Damage"] = "显示持续伤害预测",
    ["Also on nameplates"] = "也显示在姓名板上",
    ["Show DIES"] = "显示“死亡”",
    ["Block fill"] = "区块填充",
    ["Block color"] = "区块颜色",
    ["Block opacity"] = "区块不透明度",
    ["Block outline"] = "区块描边",
    ["Curse slot"] = "诅咒栏位",
    ["Curse slot click"] = "诅咒栏位点击",
    ["Show the smart curse letter"] = "显示智能诅咒字母",
    ["Tell your group"] = "通知团队",
    ["Keep the control macros"] = "保留控制宏",
    ["Timers on nameplates"] = "姓名板计时",
    ["Say instead of party or raid"] = "改用“说”频道",
    ["Bar size"] = "控制条大小",
    ["Frozen and chilled"] = "冰冻与寒冷",
    ["Arc height"] = "弧线高度",
    ["Arc size"] = "弧线大小",
    ["Height above nameplate"] = "姓名板上方高度",
    ["Preview"] = "预览",
    ["Purple"] = "紫色",
    ["Red"] = "红色",
    ["Orange"] = "橙色",
    ["White"] = "白色",
    ["Green"] = "绿色",
    ["Left of the bar"] = "生命条左侧",
    ["Right of the bar"] = "生命条右侧",
    ["Center of the bar"] = "生命条中央",
    ["Above the bar"] = "生命条上方",
    ["Below the bar"] = "生命条下方",
    ["Inside the bar's right end"] = "生命条右端内侧",
    ["target and focus"] = "目标与焦点",
    ["nameplates"] = "姓名板",
    ["your target and focus frames"] = "目标与焦点框体",

    -- Core
    ["Dyre's Debuff Tracker needs Dyre's Toolkit 2.9.1 or later. Install or update it from CurseForge."] =
        "Dyre's Debuff Tracker 需要 Dyre's Toolkit 2.9.1 或更高版本。请从 CurseForge 安装或更新。",
    ["Dyre's Debuff Tracker"] = "Dyre's Debuff Tracker",
    ["DoT tracker, damage prediction, and crowd-control"] = "持续伤害追踪、伤害预测与控制",
    ["Polymorph bar"] = "变形术控制条",
    ["Copied your %s settings from %s. Change them here, under Dyre's Debuff Tracker."] =
        "已复制你的 %s 设置（来自 %s）。请在这里的 Dyre's Debuff Tracker 下修改。",
    ["Your Smart curse key (%s) now casts Dyre's Debuff Tracker's smart curse."] =
        "你的智能诅咒按键（%s）现在施放 Dyre's Debuff Tracker 的智能诅咒。",
    ["/ddt opens the settings; /ddt reset puts the frames back; /ddt reset_focus checks the focus again; "
        .. "/ddt debug shows what the trackers see; /ddt preview brand shows the Demonic Brand pentagram on your "
        .. "target (Warlocks, WoW: Forever); /ddt preview chill shows the Winter's Chill arc on your target (Mages)."] =
        "/ddt 打开设置；/ddt reset 恢复框体默认位置；/ddt reset_focus 重新检测焦点；/ddt debug 显示追踪器当前状态；"
            .. "/ddt preview brand 在目标姓名板上预览 Demonic Brand 五角星（术士，魔兽世界：无限）；"
            .. "/ddt preview chill 在目标姓名板上预览深冬之寒冰弧（法师）。",
    ["Focus check reset for every Dyre's AddOn. The macros try your focus, then the mob under the "
        .. "mouse, then your target, until a focus is seen to work."] =
        "已为所有 Dyre 插件重置焦点检测。宏会依次尝试你的焦点、鼠标指向的怪物、当前目标，直到检测到可用的焦点。",
    ["Demonic Brand preview: on your target's nameplate. Change Size and Height to see them. Press "
        .. "Preview again, or change target, to end it."] =
        "Demonic Brand 预览：已显示在目标姓名板上。调整“大小”和“高度”可实时查看。再次按“预览”或切换目标即可结束。",
    ["Demonic Brand preview: off."] = "Demonic Brand 预览：已关闭。",
    ["Demonic Brand preview: target a mob with its nameplate showing first."] =
        "Demonic Brand 预览：请先选中一个姓名板正在显示的怪物。",
    ["Demonic Brand preview: this client has no Demonic Brand (%s)."] =
        "Demonic Brand 预览：此客户端没有 Demonic Brand（%s）。",
    ["Demonic Brand preview: Warlocks only."] = "Demonic Brand 预览：仅限术士。",

    -- Engines
    ["Smart curse (Warlock)"] = "智能诅咒（术士）",
    ["Dyre's Debuff Tracker keeps your \"%s\" macro now."] = "Dyre's Debuff Tracker 现在接管你的“%s”宏。",
    ["The DoT tracker stays off: this client lacks %s."] = "持续伤害追踪保持关闭：此客户端缺少 %s。",
    ["Crowd control"] = "控制",
    ["The crowd-control bar stays off: this client lacks %s."] = "控制条保持关闭：此客户端缺少 %s。",
    ["The frozen and chilled arcs stay off: this client lacks %s."] =
        "冰冻与寒冷弧线保持关闭：此客户端缺少 %s。",
    ["The Demonic Brand pentagram stays off: this client lacks %s."] =
        "Demonic Brand 五角星保持关闭：此客户端缺少 %s。",
    ["Frames are back in their default places."] = "框体已恢复默认位置。",

    -- Options: pages and status
    ["DoTs"] = "持续伤害",
    ["Dyre's Debuff Tracker has nothing for your class yet: more classes are coming."] =
        "Dyre's Debuff Tracker 暂时还没有你职业的内容，后续会加入更多职业。",
    ["Your class has no DoTs here yet."] = "你的职业暂时没有持续伤害内容。",
    ["Your class has no crowd control here yet."] = "你的职业暂时没有控制内容。",
    ["%s has this for your class. These settings apply when it is off."] =
        "%s为你的职业提供了这些功能。关闭它后，这些设置才会生效。",
    ["%s has your DoTs and crowd control. Turn it off, or update it, to use Dyre's Debuff Tracker for them."] =
        "%s掌管你的持续伤害与控制。关闭它或更新它，才能让 Dyre's Debuff Tracker 接管。",
    ["DoTs and crowd control for your class; each has its own page below."] =
        "你职业的持续伤害与控制；各自有独立页面。",

    -- Options: size tips and the smart curse
    ["The room the name has beside the icons (name Left or Right): the row grows or "
        .. "shrinks with it. A longer name is cut with \"...\". Above or below the icons, the name spans the row."] =
        "名字在图标旁边可用的空间（名字在左或右时）：整行会随之变宽或变窄。更长的名字会用“...”截断。"
            .. "名字在上或下时，会横跨整行。",
    ["Smart curse: with no modifier, Curse of Tongues on a mob with mana, else Curse of the "
        .. "Elements, else Curse of Weakness, chosen out of combat as your target changes. Shift casts Weakness, Ctrl "
        .. "Tongues (Weakness if you do not know Tongues), Alt Recklessness. The \"! Curse\" macro and the Smart curse "
        .. "key binding (Key Bindings, Dyre's Debuff Tracker) cast it too."] =
        "智能诅咒：不加修饰键时，对有法力的怪物施放语言诅咒，否则施放元素诅咒，再否则施放虚弱诅咒，"
            .. "在你切换目标时于脱战状态下选定。按住 Shift 施放虚弱诅咒，按住 Ctrl 施放语言诅咒"
            .. "（未学会语言诅咒时为虚弱诅咒），按住 Alt 施放鲁莽诅咒。“! Curse”宏和“智能诅咒”按键绑定"
            .. "（按键设置中的 Dyre's Debuff Tracker）也会施放它。",
    ["What a click on the target or focus row's Curse slot casts. Last used: the curse you cast last. "] =
        "点击目标或焦点行的诅咒栏位时施放什么。上次使用：你上一次施放的诅咒。",
    [" A change in combat applies when combat ends."] = " 战斗中的修改会在战斗结束后生效。",
    ["With Smart curse, a letter on the Curse slot's icon for that mob's best curse: "
        .. "T Tongues, E Elements, W Weakness. It changes also in combat."] =
        "使用智能诅咒时，在诅咒栏位图标上显示该怪物最合适诅咒的字母：T 语言、E 元素、W 虚弱。"
            .. "战斗中也会变化。",

    -- Options: frozen and chilled, Demonic Brand
    ["Show frozen and chilled arcs"] = "显示冰冻与寒冷弧线",
    ["Above each enemy nameplate: an arc of ice crystals while the mob is Frozen (Shatter works on it), and a "
        .. "thin arc of frost and snowflakes while your Chill is on it (Frostbite and Fingers of Frost can proc). A mob that is both "
        .. "shows both, Frozen above."] =
        "在每个敌对姓名板上方：怪物处于冰冻状态时显示一圈冰晶弧线（可以打出碎裂），你的寒冷效果在它身上时"
            .. "显示一圈淡淡的霜雪弧线（可触发霜寒刺骨和寒冰指）。同时具备两者时两条弧线都显示，冰冻在上。",
    ["How far above the nameplate's health bar the arcs sit, in pixels: %d to %d."] =
        "弧线位于姓名板生命条上方的高度，单位为像素：%d 到 %d。",
    ["The arcs' size, in percent: %d to %d."] = "弧线的大小，以百分比表示：%d 到 %d。",
    ["A glowing red pentagram above an enemy's nameplate while your Demonic Brand is on it (your Searing Pain "
        .. "puts it there; your demon's next attacks on it deal extra damage). Recast Searing Pain when it goes."] =
        "你的 Demonic Brand 在敌人身上时，在其姓名板上方显示发光的红色五角星（由你的灼热之痛施加；"
            .. "你的恶魔接下来对它的攻击会造成额外伤害）。烙印消失后重新施放灼热之痛。",
    ["The pentagram's size, in percent: %d to %d."] = "五角星的大小，以百分比表示：%d 到 %d。",
    ["How far above the nameplate's health bar the pentagram's glow starts, in pixels: %d to %d."] =
        "五角星的光晕从姓名板生命条上方多高开始显示，单位为像素：%d 到 %d。",
    ["Shows the pentagram on your target's nameplate with no Demonic Brand on it, so you can set Size and "
        .. "Height. Press again, or change target, to end it."] =
        "在目标姓名板上显示五角星（无需目标身上有 Demonic Brand），方便调整“大小”和“高度”。"
            .. "再次按下或切换目标即可结束。",
    ["Reset Demonic Brand"] = "重置 Demonic Brand",
    ["Show, Size, and Height back to their defaults: on, %d%%, %d pixels."] =
        "将“显示”“大小”和“高度”恢复默认：开启、%d%%、%d 像素。",

    -- Options: Winter's Chill (Mage)
    ["Winter's Chill"] = "深冬之寒",
    [" Needs the Winter's Chill talent (Frost)."] = " 需要天赋“深冬之寒”（冰霜）。",
    ["A blue ice arc of five segments above an enemy's nameplate while your Winter's Chill is on it: one more "
        .. "segment turns white with each stack, up to %d, as combo points. Your Frost spells add the stacks."] =
        "你的深冬之寒在敌人身上时，其姓名板上方显示由五段组成的蓝色冰弧：每叠一层就多一段变白，"
            .. "最多 %d 层，像连击点一样。你的冰霜法术会叠加层数。",
    ["The arc's size, in percent: %d to %d."] = "冰弧的大小，以百分比表示：%d 到 %d。",
    ["How far above the nameplate's health bar the arc sits, in pixels: %d to %d. The default sits above "
        .. "the frozen and chilled arcs."] =
        "冰弧位于姓名板生命条上方的高度，单位为像素：%d 到 %d。默认在冰冻与寒冷弧线的上方。",
    ["Shows the arc on your target's nameplate with no Winter's Chill on it (%d of %d white), so you can "
        .. "set Size and Height. Press again, or change target, to end it."] =
        "在目标姓名板上显示冰弧（无需目标身上有深冬之寒，%d/%d 段为白色），方便调整“大小”和“高度”。"
            .. "再次按下或切换目标即可结束。",
    ["A note when Winter's Chill goes on your target, and another note as each stack after it goes on "
        .. "(this client cannot count the stacks, so the notes do not rise). A stack that drops, or the "
        .. "debuff ending, plays nothing. Another Mage's Winter's Chill on your target may chime too. "
        .. "Needs Dyre's Sounds."] =
        "深冬之寒落到你的目标身上时响一个音，之后每叠一层再响一个（此客户端数不出层数，所以音调不会上升）。"
            .. "掉层或效果结束时不会响。其他法师放在你目标身上的深冬之寒也可能响。需要 Dyre's Sounds。",
    ["A note as each stack of your Winter's Chill goes on a mob: rising from 1 to 4, and a held high note at 5. "
        .. "A stack that drops, or the debuff ending, plays nothing. Only your target's stacks chime; another "
        .. "Mage's Winter's Chill does not. Needs Dyre's Sounds."] =
        "你的深冬之寒每在怪物身上叠一层响一个音：从 1 到 4 逐层升高，第 5 层是一个延长的高音。"
            .. "掉层或效果结束时不会响。只对当前目标的层数生效，其他法师的深冬之寒不会响。需要 Dyre's Sounds。",
    ["Stack chime"] = "层数音阶",
    ["Note set"] = "音色",
    ["The chime's instrument, from Dyre's Sounds."] = "音阶使用的乐器音色，来自 Dyre's Sounds。",
    ["Test chime"] = "试听音阶",
    ["Plays the chime for stacks 1 to %d, one after another."] = "依次播放第 1 层到第 %d 层的音阶。",
    ["Reset Winter's Chill"] = "重置深冬之寒",
    ["Show, Size, Height, and the chime back to their defaults: on, %d%%, %d pixels, chime on, %s."] =
        "将“显示”“大小”“高度”和音阶恢复默认：开启、%d%%、%d 像素、音阶开启、%s。",
    ["Bassoon"] = "巴松管",
    ["Sax"] = "萨克斯",

    -- Core: Winter's Chill
    ["Copied your Winter's Chill chime settings from Dyre's Buff Reminders. Change them here, under Dyre's "
        .. "Debuff Tracker, Winter's Chill."] =
        "已从 Dyre's Buff Reminders 复制你的深冬之寒音阶设置。请在这里的 Dyre's Debuff Tracker → 深冬之寒 下修改。",
    ["The Winter's Chill arc stays off: this client lacks %s."] = "深冬之寒冰弧保持关闭：此客户端缺少 %s。",
    ["Winter's Chill preview: on your target's nameplate. Change Size and Height to see them. Press "
        .. "Preview again, or change target, to end it."] =
        "深冬之寒预览：已显示在目标姓名板上。调整“大小”和“高度”可实时查看。再次按“预览”或切换目标即可结束。",
    ["Winter's Chill preview: off."] = "深冬之寒预览：已关闭。",
    ["Winter's Chill preview: target a mob with its nameplate showing first."] =
        "深冬之寒预览：请先选中一个姓名板正在显示的怪物。",
    ["Winter's Chill preview: this client lacks %s."] = "深冬之寒预览：此客户端缺少 %s。",
    ["Winter's Chill preview: Mages only."] = "深冬之寒预览：仅限法师。",
    ["Winter's Chill chime: install Dyre's Sounds to hear it."] = "深冬之寒音阶：安装 Dyre's Sounds 后才能听到。",
    ["The Winter's Chill chime waits: %s %s still plays its own. Update it to %s or later to hear this one."] =
        "深冬之寒音阶暂不启用：%s %s 仍在播放它自己的音阶。把它更新到 %s 或更高版本，就能听到这里的音阶。",

    -- Options: tracker-wide and per-panel rows
    ["%s panel"] = "%s框体",
    ["Show %s panel"] = "显示%s框体",
    ["Reset %s panel"] = "重置%s框体",
    ["The panel for the other mobs you DoT. Your target and focus stay out of it."] =
        "显示其他被你施加持续伤害的怪物。目标与焦点不会出现在这里。",
    ["The panel for your %s's DoTs."] = "你的%s框体的持续伤害。",
    ["The line with the mob's name is its health bar, with the damage to come drawn on it. This panel only. "
        .. "A change in combat applies when combat ends."] =
        "怪物名字那一行就是它的生命条，并在上面显示预计伤害。仅限此框体。"
            .. "战斗中的修改会在战斗结束后生效。",
    ["Text after the mob's name: its health as a number, a percent, or both. This panel only."] =
        "怪物名字后显示的生命值：数值、百分比或两者。仅限此框体。",
    ["The background and border behind each mob's name and DoTs in this panel. Turn it off to see only "
        .. "the name and the DoTs. Applies at once, also in combat."] =
        "此框体中每只怪物名字和持续伤害后面的背景与边框。关闭后只显示名字和持续伤害。"
            .. "立即生效，战斗中也会改变。",
    ["The colored outline around the %s panel, "
        .. "in pixels: %d to %d. 0 draws none. A change in combat "
        .. "applies when combat ends."] =
        "%s框体外圈的彩色描边，单位为像素：%d 到 %d。0 表示不描边。"
            .. "战斗中的修改会在战斗结束后生效。",
    ["Up puts the first DoT where you placed the panel and the next ones above it (Bars "
        .. "look). Down puts them below it. The name keeps its place."] =
        "向上：第一个持续伤害放在框体原位置，后续的往上排列（条形外观）。向下：往下排列。名字保持原位。",
    ["Up puts the first DoT where you placed the panel and the next ones above it (Bars "
        .. "look). Down puts them below it. Up also stacks new mobs upward, in "
        .. "both looks. The name keeps its place."] =
        "向上：第一个持续伤害放在框体原位置，后续的往上排列（条形外观）。向下：往下排列。"
            .. "向上时，两种外观下新怪物也会向上堆叠。名字保持原位。",
    ["Bars: the length of this panel's "
        .. "DoT bars. Compact: the size of its DoT icons. From 75% to 125%. A change in combat applies when "
        .. "combat ends."] =
        "条形：此框体持续伤害条的长度。紧凑：持续伤害图标的大小。范围 75% 到 125%。"
            .. "战斗中的修改会在战斗结束后生效。",
    ["In the %s look, this panel's %s."] = "在%s外观中，此框体的%s。",
    ["Where the mob's name sits in this panel's rows."] = "怪物名字在此框体各行中的位置。",
    ["The row border and health fill of the other mobs' rows. It changes at once, also in combat."] =
        "其他怪物行的边框和生命值填充。立即生效，战斗中也会改变。",
    ["The outline and health fill of the %s panel. It changes at once, also in combat."] =
        "%s框体的描边和生命值填充。立即生效，战斗中也会改变。",
    ["How solid the %s panel is, rows and all, in percent. It changes at once; "
        .. "its bars follow when combat ends."] =
        "%s框体（包括所有行）的不透明度，以百分比表示。立即生效；条形会在战斗结束后跟随。",
    ["This panel back to the defaults: shown, no health, its frame and outline, its size, color, and "
        .. "opacity. Its place stays."] =
        "将此框体恢复默认：显示、不显示生命值、显示边框与描边、默认大小、颜色和不透明度。位置保持不变。",

    -- Options: DoTs page
    ["A row for your target, one for your focus, and up to eight more for the other mobs you DoT, each with "
        .. "a timer bar per DoT."] =
        "目标一行、焦点一行，最多再显示八只被你施加持续伤害的其他怪物，每个持续伤害一条计时条。",
    ["Compact: a row with the name and an icon per DoT. Bars: the name above one bar per DoT."] =
        "紧凑：每只怪物一行，名字后每个持续伤害一个图标。条形：名字在上方，每个持续伤害一条计时条。",
    ["Bars: the length of the DoT bars. Compact: the size of the DoT "
        .. "icons. From 75% to 125%; one setting for both looks. A change in combat applies when combat ends."] =
        "条形：持续伤害条的长度。紧凑：持续伤害图标的大小。范围 75% 到 125%，两种外观共用。"
            .. "战斗中的修改会在战斗结束后生效。",
    ["In the %s look, the DoT tracker's %s."] = "在%s外观中，持续伤害追踪的%s。",
    ["Where the mob's name sits in each row."] = "怪物名字在每一行中的位置。",
    ["Back to the chosen look's own sizes and name position."] = "恢复所选外观自带的大小和名字位置。",
    ["Show a DoT only while it is on the mob. The empty places stay, so the DoTs do not move. The target "
        .. "and focus rows then do not recast a DoT when you click them."] =
        "只在持续伤害存在于怪物身上时显示。空位保留，因此持续伤害不会移位。"
            .. "开启后，点击目标或焦点行不会补放持续伤害。",
    ["The background and border behind each mob's name and DoTs. Turn it off to see only the name and the "
        .. "DoTs. Applies at once, also in combat."] =
        "每只怪物名字和持续伤害后面的背景与边框。关闭后只显示名字和持续伤害。"
            .. "立即生效，战斗中也会改变。",
    ["The colored outline around the Target and Focus panels, "
        .. "in pixels: %d to %d. 0 draws none. A change in combat "
        .. "applies when combat ends."] =
        "目标和焦点框体外圈的彩色描边，单位为像素：%d 到 %d。0 表示不描边。"
            .. "战斗中的修改会在战斗结束后生效。",
    ["Grow: %s"] = "增长方向：%s",
    ["The line with the mob's name is its health bar, with the damage to come drawn on it."] =
        "怪物名字那一行就是它的生命条，并在上面显示预计伤害。",
    ["Text after the mob's name."] = "怪物名字后显示的文字。",
    ["In combat, a dot above each enemy nameplate for each of your DoTs, colored while it "
        .. "is up."] =
        "战斗中，在每个敌对姓名板上方为你施加的每个持续伤害显示一个圆点，存在时显示颜色。",
    ["How far above the nameplate the dots sit, to clear other nameplate "
        .. "AddOns."] =
        "圆点位于姓名板上方的高度，以便避开其他姓名板插件。",
    ["How solid the dots above each nameplate are, in percent. It changes at once, also in combat."] =
        "姓名板上方圆点的不透明度，以百分比表示。立即生效，战斗中也会改变。",
    ["%s panel color"] = "%s框体颜色",
    ["%s panel opacity"] = "%s框体不透明度",
    ["Each DoT"] = "各个持续伤害",
    ["DoT %d"] = "持续伤害 %d",
    ["The DoT in place %d on each row. Pick another and the two swap places. A "
        .. "change in combat applies when combat ends."] =
        "每一行第 %d 格的持续伤害。选择另一个会与之互换位置。"
            .. "战斗中的修改会在战斗结束后生效。",
    ["%s color"] = "%s颜色",
    ["The color of %s on the tracker's bars and on nameplate dots. A change in combat reaches the bars when "
        .. "combat ends."] =
        "%s在追踪器条形和姓名板圆点上的颜色。战斗中的修改会在战斗结束后应用到条形。",
    ["%s dot on nameplates"] = "%s的姓名板圆点",
    ["Show a %s dot in the nameplate bubble."] = "在姓名板气泡中显示%s圆点。",
    ["Reset order and colors"] = "重置顺序与颜色",
    ["Back to the DoTs' own order and colors."] = "恢复持续伤害自带的顺序和颜色。",

    -- Options: damage to come
    ["A striped block on the mob's health bar for the damage your DoTs still have to deal."] =
        "在怪物生命条上显示一个条纹区块，表示你的持续伤害还将造成的伤害。",
    ["The block on enemy nameplates too."] = "在敌对姓名板上也显示该区块。",
    ["A red skull and DIES when the damage to come is enough to kill the mob."] =
        "预计伤害足以击杀怪物时，显示红色骷髅和“死亡”。",
    ["Stripes: diagonal stripes. Solid: one flat color. Bar texture: the texture of the bar it sits on. The "
        .. "same look on the target frame, nameplates, and DoT tracker rows."] =
        "条纹：斜纹。实心：单一纯色。条材质：使用所在生命条的材质。"
            .. "目标框体、姓名板和持续伤害追踪行使用相同外观。",
    ["The block's color."] = "区块的颜色。",
    ["How solid the block is, in percent."] = "区块的不透明度，以百分比表示。",
    ["A thin line around the block, a little lighter than its color."] = "区块周围的一圈细线，比区块颜色稍亮。",
    ["DIES place: %s"] = "“死亡”位置：%s",
    ["DIES left/right: %s"] = "“死亡”左右：%s",
    ["DIES down/up: %s"] = "“死亡”上下：%s",
    ["Where DIES shows on %s. Auto puts it beside "
        .. "the bar, on a side nothing else uses. Center puts it in the middle of the bar."] =
        "“死亡”在%s上的显示位置。自动：放在生命条旁边，选择没有其他内容占用的一侧；"
            .. "中央：放在生命条中间。",
    ["Moves DIES on %s, in pixels: up to %d left or right."] =
        "以像素为单位左右移动%s上的“死亡”：最多 %d。",
    ["Moves DIES on %s, in pixels: up to %d down or up."] =
        "以像素为单位上下移动%s上的“死亡”：最多 %d。",

    -- Options: crowd control
    ["A bar for each mob you control, with its name and time left, so you know which one breaks next."] =
        "为你控制的每只怪物显示一条计时栏，包含名字和剩余时间，让你知道哪一只会先醒来。",
    ["A character macro for each control spell you know (\"! Fear\", \"! Polymorph\", ...): it makes the mob "
        .. "under your mouse your focus, marks it, and casts on it. Off deletes them."] =
        "为你掌握的每个控制法术创建一个角色宏（“! Fear”“! Polymorph”等）：把鼠标指向的怪物设为焦点、"
            .. "标记它并对其施放。关闭会删除这些宏。",
    ["A thin bar under each controlled mob's nameplate with its time left."] =
        "在每只受控怪物的姓名板下方显示一条细计时栏。",
    ["%s marker"] = "%s标记",
    ["The raid marker the macro puts on your %s target, so your group leaves it alone."] =
        "宏会放在你%s目标上的团队标记，让队友别去碰它。",
    ["Tell your party or raid as you cast it: %s"] = "施放时通知小队或团队：%s",
    ["Messages go to Say, also when you are alone."] = "消息发送到“说”频道，单人时也发送。",

    -- Fork: hover line, DoT and Banish end warnings
    ["Gold line on hover"] = "悬停金色连线",
    ["With the mouse on a row, or on a DoT icon of the target or focus row, gold sparks flow "
        .. "from the row to that mob's nameplate (else its target or focus frame). A locked tracker works "
        .. "on the icons; an unlocked one, on the whole row."] =
        "鼠标停在追踪行上（锁定时可停在目标/焦点行的 DoT 图标上）时，金色光点从这一行流向"
            .. "对应怪物的姓名板；没有姓名板时指向目标或焦点框体。解锁后整行都能触发。",
    ["Flash a panel before a DoT ends"] = "持续伤害快结束时闪烁面板",
    ["The target or focus panel flashes shortly before one of your DoTs on that mob runs out. "
        .. "It counts from your cast, so a dispel or a resist can make it early or late."] =
        "你放在该怪物身上的持续伤害快结束时，目标或焦点面板会提前闪烁。时间按你的施法推算，"
            .. "被驱散或抵抗时可能提前或延后。",
    ["Chime with the DoT warning"] = "持续伤害提醒时响铃",
    ["Play a sound with the flash."] = "闪烁时播放提示音。",
    ["Flash the bar before Banish ends"] = "放逐快结束时闪烁控制条",
    ["The crowd-control bar flashes shortly before your Banish ends. It counts from your cast, "
        .. "so an early break can make it wrong."] =
        "放逐快结束时，控制条会提前闪烁。时间按你的施法推算，提前解除时可能不准。",

    -- Options 1.8.0: sections, titles, and the shortened tooltips
    ["target"] = "目标",
    ["focus"] = "焦点",
    ["list"] = "其他",
    ["DoT Tracker"] = "持续伤害追踪",
    ["Crowd Control"] = "控制",
    ["Debuff Cues"] = "减益提示",
    ["Dyre's Debuff Tracker has nothing for your class."] = "Dyre's Debuff Tracker 对你的职业没有可用内容。",
    ["The room for the mob's name beside the icons."] = "图标旁留给怪物名字的空间。",
    ["Shift casts Weakness, Ctrl Tongues, Alt Recklessness."] =
        "Shift 施放虚弱诅咒，Ctrl 施放语言诅咒，Alt 施放鲁莽诅咒。",
    ["%s shows these for you now, so these settings are greyed. Turn that feature off in %s to use these."] =
        "现在由%s为你显示这些，因此这些设置已变灰。关闭%s中的该功能后即可在这里设置。",
    ["Shows an ice arc above each enemy nameplate while the mob is Frozen, and a thin frost arc while your "
        .. "Chill is on it."] =
        "怪物处于冰冻状态时，在每个敌对姓名板上方显示一圈冰弧；你的寒冷效果在它身上时，显示一圈淡淡的霜弧。",
    ["How far above the nameplate the arcs sit."] = "弧线位于姓名板上方的高度。",
    ["The size of the arcs."] = "弧线的大小。",
    [" Greyed out: you have not learned %s yet."] = " 已变灰：你尚未学会%s。",
    ["Shows a five-part ice arc above an enemy's nameplate, one part turning white for each stack of your "
        .. "Winter's Chill."] =
        "在敌对姓名板上方显示由五段组成的冰弧，你的深冬之寒每叠一层就多一段变白。",
    ["The size of the arc."] = "冰弧的大小。",
    ["How far above the nameplate the arc sits."] = "冰弧位于姓名板上方的高度。",
    ["Preview Winter's Chill"] = "预览深冬之寒",
    ["Shows the arc on your target's nameplate so you can set its size and height. Press again to hide it."] =
        "在目标姓名板上显示冰弧，方便调整大小和高度。再次按下即可隐藏。",
    ["Plays a note when Winter's Chill goes on your target and as each stack is added. Needs Dyre's Sounds."] =
        "深冬之寒落到你的目标身上时响一个音，之后每叠一层再响一个。需要 Dyre's Sounds。",
    ["Plays a rising note as each stack of your Winter's Chill goes on your target. Needs Dyre's Sounds."] =
        "你的深冬之寒每在目标身上叠一层，就响一个升高的音。需要 Dyre's Sounds。",
    ["The instrument the chime plays."] = "音阶使用的乐器音色。",
    ["Test the stack chime"] = "试听层数音阶",
    ["Test"] = "试听",
    ["Plays the chime for stacks 1 to %d."] = "依次播放第 1 层到第 %d 层的音阶。",
    ["Reset"] = "重置",
    ["Puts the Winter's Chill settings back to their defaults."] = "将深冬之寒的设置恢复默认。",
    ["Demonic Brand"] = "Demonic Brand",
    ["Shows a glowing red pentagram above an enemy's nameplate while your Demonic Brand is on it."] =
        "你的 Demonic Brand 在敌人身上时，在其姓名板上方显示发光的红色五角星。",
    ["The size of the pentagram."] = "五角星的大小。",
    ["How far above the nameplate the pentagram sits."] = "五角星位于姓名板上方的高度。",
    ["Preview Demonic Brand"] = "预览 Demonic Brand",
    ["Shows the pentagram on your target's nameplate so you can set its size and height. Press again to "
        .. "hide it."] = "在目标姓名板上显示五角星，方便调整大小和高度。再次按下即可隐藏。",
    ["Puts the Demonic Brand settings back to their defaults."] = "将 Demonic Brand 的设置恢复默认。",
    ["Shows the panel for the other mobs you DoT."] = "显示其他被你施加持续伤害的怪物。",
    ["Shows the panel for your %s's DoTs."] = "显示你的%s框体的持续伤害。",
    ["Turns the line with the mob's name into its health bar."] = "把怪物名字那一行变成它的生命条。",
    ["Shows the mob's health after its name, as a number, a percent, or both."] =
        "在怪物名字后显示生命值：数字、百分比或两者。",
    ["Shows the background and border behind each mob's name and DoTs."] =
        "显示每只怪物名字和持续伤害后面的背景与边框。",
    ["The width of the colored outline around the %s panel; 0 hides it."] =
        "%s框体外圈的彩色描边宽度；0 表示不显示。",
    ["Whether new DoTs and new mobs are added above or below the first one."] =
        "新的持续伤害和新怪物加在第一条的上方还是下方。",
    ["Whether new DoTs are added above or below the first one."] = "新的持续伤害加在第一条的上方还是下方。",
    ["The length of this panel's DoT bars, or the size of its icons in the Compact look."] =
        "此框体持续伤害条的长度，或紧凑外观下图标的大小。",
    ["The color of the other mobs' row borders and health bars."] = "其他怪物行的边框和生命条的颜色。",
    ["The color of the %s panel's outline and health bar."] = "%s框体描边和生命条的颜色。",
    ["How solid the %s panel is."] = "%s框体的不透明度。",
    ["Puts this panel's settings back to their defaults."] = "将此框体的设置恢复默认。",
    ["Shows timer bars for your DoTs on your target, your focus, and other mobs."] =
        "在你的目标、焦点和其他怪物身上显示持续伤害计时条。",
    ["Enable DoT tracker"] = "启用持续伤害追踪",
    ["Compact shows an icon per DoT; Bars shows a timer bar per DoT."] =
        "紧凑：每个持续伤害一个图标；条形：每个持续伤害一条计时条。",
    ["The length of the DoT bars, or the size of the icons in the Compact look."] =
        "持续伤害条的长度，或紧凑外观下图标的大小。",
    ["Puts this look's sizes and name position back to their defaults."] =
        "恢复所选外观的大小和名字位置默认值。",
    ["Shows a DoT only while it is on the mob. A click on the target or focus row then recasts nothing."] =
        "只在持续伤害存在于怪物身上时显示。此时点击目标或焦点行不会补放持续伤害。",
    ["The width of the colored outline around the %s and %s panels; 0 hides it."] =
        "%s和%s框体外圈的彩色描边宽度；0 表示不显示。",
    ["What a click on the Curse slot casts: the curse you cast last, or the best curse for that mob. %s"] =
        "点击诅咒栏位时施放的诅咒：上次施放的诅咒，或对该怪物最合适的诅咒。%s",
    ["Shows a letter on the Curse slot for that mob's best curse: T Tongues, E Elements, W Weakness."] =
        "在诅咒栏位上显示该怪物最合适诅咒的字母：T 语言、E 元素、W 虚弱。",
    ["Keep the \"! Curse\" macro"] = "保留“! Curse”宏",
    ["Keeps a \"! Curse\" macro that casts the smart curse. Off deletes it."] =
        "保留用于施放智能诅咒的“! Curse”宏。关闭会删除它。",
    ["Shows a striped block on the mob's health bar for the damage your DoTs still have to deal."] =
        "在怪物生命条上显示条纹区块，表示你的持续伤害还将造成的伤害。",
    ["Shows the block on enemy nameplates too."] = "在敌对姓名板上也显示该区块。",
    ["Shows a red skull and DIES when your DoTs will kill the mob."] =
        "你的持续伤害足以击杀怪物时，显示红色骷髅和“死亡”。",
    ["How the block is drawn: stripes, one solid color, or the texture of the bar it sits on."] =
        "区块的画法：条纹、单一纯色，或所在生命条的材质。",
    ["Draws a thin line around the block."] = "在区块周围画一圈细线。",
    ["Where DIES shows on %s."] = "“死亡”在%s上的显示位置。",
    ["Moves DIES left or right on %s."] = "以像素为单位左右移动%s上的“死亡”。",
    ["Moves DIES down or up on %s."] = "以像素为单位上下移动%s上的“死亡”。",
    ["Shows a dot above each enemy nameplate for each of your DoTs, lit while it is up."] =
        "在每个敌对姓名板上方为你施加的每个持续伤害显示一个圆点，存在时点亮。",
    ["How far above the nameplate the dots sit."] = "圆点位于姓名板上方的高度。",
    ["How solid the nameplate dots are."] = "姓名板上方圆点的不透明度。",
    ["The DoT in place %d on each row; picking another swaps the two."] =
        "每一行第 %d 格的持续伤害；选择另一个会互换位置。",
    ["The color of %s on the tracker's bars and nameplate dots."] = "%s在追踪器条形和姓名板圆点上的颜色。",
    ["Shows a %s dot above nameplates."] = "在姓名板上方显示%s圆点。",
    ["Puts the DoTs' order and colors back to their defaults."] = "将持续伤害的顺序和颜色恢复默认。",
    [" Off also stops the group messages and removes the \"!\" macros from your action bars."] =
        " 关闭后还会停止团队通报，并从动作条移除“!”宏。",
    ["Shows a bar for each mob you control with its time left."] = "为你控制的每只怪物显示一条计时栏。",
    ["Enable crowd control"] = "启用控制",
    ["Keeps a macro for each crowd-control spell you know (\"! Fear\", \"! Polymorph\", ...) that "
        .. "marks and casts on the mob under your mouse. Off deletes them."] =
        "为你掌握的每个控制法术保留一个宏（“! Fear”“! Polymorph”等），标记并施放鼠标指向的怪物。"
            .. "关闭会删除这些宏。",
    ["Shows a thin bar under each controlled mob's nameplate with its time left."] =
        "在每只受控怪物的姓名板下方显示一条细计时栏。",
    ["The raid marker the macro puts on your %s target."] = "宏会放在你%s目标上的团队标记。",
    ["Tells your party or raid as you cast it: %s"] = "施放时通知小队或团队：%s",
    ["Sends the messages to Say instead, also when you are alone."] = "消息改发到“说”频道，单人时也发送。",
    ["%s shows your DoTs and crowd control now. Turn it off, or update it, to use Dyre's Debuff Tracker for "
        .. "them."] = "%s现在为你显示持续伤害和控制。关闭它或更新它，才能让 Dyre's Debuff Tracker 接管。",
    ["DoTs, crowd control, and debuff cues for your class; each has its own page below."] =
        "为你的职业提供持续伤害、控制与减益提示；每项各有单独页面。",
}

function DDT.T(text, context)
    if type(text) ~= "string" or DDT.L ~= zhCN then
        return text
    end
    if context then
        local contextual = zhText[context .. "|" .. text]
        if contextual then
            return contextual
        end
    end
    return zhText[text] or text
end
