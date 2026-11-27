local _, ns = ...

-- Strings in this AddOn, keyed by the English text (WTF's Locales.lua
-- pattern): a lookup that misses returns the English, so a string added by a
-- later version still shows. Spell names come from the client; these are the
-- toolkit's own words.
local enUS = {}
local zhCN = {
    -- Home, core, minimap
    ["Dyre's AddOns"] = "Dyre's 插件",
    ["The settings page is unavailable on this client. Use /dyre unlock and /dyre lock."] =
        "此客户端没有设置页面。请使用 /dyre unlock 和 /dyre lock。",
    ["The settings open out of combat."] = "战斗结束后才能打开设置。",
    ["Open settings"] = "打开设置",
    ["Install %s from CurseForge."] = "请从 CurseForge 安装 %s。",
    ["Frames locked."] = "框体已锁定。",
    ["Frames unlocked: they can be dragged after combat."] = "框体已解锁：战斗结束后即可拖动。",
    ["Frames unlocked: drag them where you want (Shift-drag moves a snapped group), then type /dyre lock."] =
        "框体已解锁：拖到想要的位置（按住 Shift 拖动可整体移动已吸附的一组），然后输入 /dyre lock。",
    ["The grid shows while frames are unlocked."] = "解锁框体时显示网格。",
    ["The grid is hidden."] = "网格已隐藏。",
    ["Frames snap to the grid."] = "框体吸附到网格。",
    ["Frames no longer snap to the grid."] = "框体不再吸附到网格。",
    ["Debug mode is on until you reload."] = "调试模式已开启，重载后关闭。",
    ["Debug mode is off."] = "调试模式已关闭。",
    ["Use /dyre (settings), /dyre unlock, /dyre lock, /dyre grid, /dyre snap, /dyre minimap, "
        .. "/dyre debug, /dyre pull [seconds], /dyre tank_reset, /dyre tank_debug, or /dyre debug_threat."] =
        "用法：/dyre（设置）、/dyre unlock、/dyre lock、/dyre grid、/dyre snap、/dyre minimap、"
        .. "/dyre debug、/dyre pull [秒数]、/dyre tank_reset、/dyre tank_debug 或 /dyre debug_threat。",
    ["Unlock frames"] = "解锁框体",
    ["Lock frames"] = "锁定框体",
    ["Settings"] = "设置",
    ["Show the grid"] = "显示网格",
    ["Snap to the grid"] = "吸附到网格",
    ["Left-click: unlock frames"] = "左键：解锁框体",
    ["Left-click: lock frames"] = "左键：锁定框体",
    ["Right-click: menu"] = "右键：菜单",
    ["Left-click locks or unlocks frames; right-click opens a menu. /dyre minimap does the same."] =
        "左键锁定或解锁框体；右键打开菜单。 /dyre minimap 效果相同。",

    -- The toolkit's own page
    ["Every Dyre's AddOn shows its frames to drag. Shift-drag moves a group of snapped frames. /dyre unlock and /dyre lock do the same."] =
        "所有 Dyre 插件都会显示可拖动的框体。按住 Shift 拖动可整体移动已吸附的一组。 /dyre unlock 和 /dyre lock 效果相同。",
    ["While frames are unlocked, a grid across the screen with red lines through its center."] =
        "解锁框体时，在屏幕上显示网格，中央有红线。",
    ["A frame you drop near a red center line centers on it, or puts its nearer edge on it. Elsewhere, an edge within a quarter of the grid size of a grey line lines up with it; when both edges are that close, the one that moves the least wins, so check both corners. Snapping to another Dyre's frame comes first. Hold Ctrl as you drop to place a frame exactly."] =
        "在红色中线附近松开框体，它会居中或把较近的边对齐红线。在其他位置，边距灰线不超过四分之一个网格时会对齐；两边都足够近时，移动更少的那边生效，所以两个角都要看。吸附到其他 Dyre 框体优先。松开时按住 Ctrl 可以精确摆放。",
    ["Grid size"] = "网格大小",
    ["The space between grid lines."] = "网格线之间的间距。",
    ["Minimap button"] = "小地图按钮",
    ["Welcome messages at login"] = "登录时显示欢迎语",
    ["Each Dyre's AddOn says its name and version in chat at login. Turn this off to hide those lines for every Dyre's AddOn. Errors and problems always show."] =
        "每个 Dyre 插件登录时都会在聊天框报出名字和版本。关掉后所有 Dyre 插件都不再显示这些行；错误与问题仍会显示。",

    -- Widgets
    ["Size"] = "大小",
    ["Width"] = "宽度",
    ["Height"] = "高度",
    ["Opacity"] = "不透明度",
    ["%s · drag to move · /dyre lock when done"] = "%s · 拖动摆放 · 完成后输入 /dyre lock",
    ["How solid it is. It fades at once, also in combat."] = "不透明度，立即生效，战斗中也可调整。",
    ["Its %s. A change in combat applies when combat ends."] = "它的%s。战斗中修改会在战斗结束后生效。",
    ["Reset size"] = "重置大小",
    ["Back to its own size. Opacity stays as it is."] = "恢复默认大小。不透明度保持不变。",

    -- Group settings
    ["Threat Indicators: Nameplates"] = "仇恨指示：姓名板",
    ["Threat Indicators: Target Frame"] = "仇恨指示：目标框体",
    ["Threat Indicators: Sounds"] = "仇恨指示：声音",
    ["Group Warnings"] = "团队警告",
    ["Tank Tools"] = "坦克工具",
    ["Enable"] = "启用",
    ["Threat view"] = "仇恨视图",
    ["Auto"] = "自动",
    ["Tank"] = "坦克",
    ["DPS/Healer"] = "输出/治疗",
    ["Place on nameplates"] = "姓名板位置",
    ["Left of the bar"] = "生命条左侧",
    ["Right of the bar"] = "生命条右侧",
    ["Above the bar"] = "生命条上方",
    ["Below the bar"] = "生命条下方",
    ["Nameplate label: left/right"] = "姓名板标签：左右",
    ["Nameplate label: up/down"] = "姓名板标签：上下",
    ["Nameplate label size"] = "姓名板标签大小",
    ["Target label: left/right"] = "目标标签：左右",
    ["Target label: up/down"] = "目标标签：上下",
    ["Target label size"] = "目标标签大小",
    ["Alert sound (red)"] = "警报声音（红色）",
    ["Warning sound (orange)"] = "警告声音（橙色）",
    ["Threat sounds when solo"] = "单人时的仇恨声音",
    ["Pull bars under nameplates"] = "姓名板下方的开怪条",
    ["Dyre's countdown on screen"] = "屏幕上的 Dyre 倒计时",
    ["Countdown tick sound"] = "倒计时滴答声",
    ["Countdown go sound"] = "倒计时开始声",
    ["Warn: pet taunt on in a group"] = "警告：队伍中宠物嘲讽开启",
    ["Tank button bar"] = "坦克按钮条",
    ["Auto (tank only)"] = "自动（仅坦克）",
    ["Always"] = "始终",
    ["Never"] = "从不",
    ["Pull countdown (seconds)"] = "开怪倒计时（秒）",
    ["Countdown size (%)"] = "倒计时大小（%）",
    ["Countdown opacity (%)"] = "倒计时不透明度（%）",
    ["The view's icon and your threat percent beside enemy nameplates. Off: no nameplate labels."] =
        "在敌方姓名板旁显示仇恨图标和你的仇恨百分比。关闭：不显示姓名板标签。",
    ["Auto: the shield (tank view) by the tank bar's rule: group role Tank or raid main tank, a Druid "
        .. "in Bear Form, a Paladin with Righteous Fury, or a Warrior in Defensive Stance; else the "
        .. "crossed swords (DPS and healer view). Tank and DPS/Healer always use that view.\n\n"
        .. "Tank view: green while the mob is on you, yellow while another unit has more threat or is "
        .. "near the pull point, blue while another tank has it, red when it is not on you. DPS/Healer view: "
        .. "green below the tank, yellow at 80% of the pull point (your target only), orange when you have "
        .. "more threat than the tank, red when it is on you.\n\nThe view also sets the Target Frame's label "
        .. "and the threat sounds."] =
        "自动：按坦克条规则选择盾牌（坦克视图）：队伍职责为坦克或团队主坦、熊形态德鲁伊、开启正义怒火的圣骑士，"
        .. "或防御姿态战士；否则使用交叉双剑（输出和治疗视图）。坦克与输出/治疗则始终使用对应视图。\n\n"
        .. "坦克视图：怪物在你身上时绿色，其他单位仇恨更高或接近开怪点时黄色，被另一名坦克拉住时蓝色，不在你身上时红色。"
        .. "输出/治疗视图：低于坦克时绿色，达到开怪点 80% 时黄色（仅限你的目标），仇恨高于坦克时橙色，怪物在你身上时红色。\n\n"
        .. "此视图同时决定目标框体标签和仇恨声音。",
    ["Where the threat label sits beside a nameplate's health bar."] = "仇恨标签在姓名板生命条旁的位置。",
    ["Moves the nameplate threat label right (more) or left (less) from its place, in pixels. Also the "
        .. "gap: with the label right of the bar, more is a wider gap."] =
        "将姓名板仇恨标签从其位置向右（正值）或向左（负值）移动，单位为像素。也决定间距：标签位于生命条右侧时，正值间距更大。",
    ["Moves the nameplate threat label up (more) or down (less) from its place, in pixels."] =
        "将姓名板仇恨标签向上（正值）或向下（负值）移动，单位为像素。",
    ["The size of the nameplate threat label's icon and text: 100% is the default, 200% twice as big, "
        .. "50% half."] = "姓名板仇恨标签图标和文字的大小：100% 为默认，200% 为两倍大，50% 为一半。",
    ["The same label above your target frame's health bar. Off: no Target Frame label."] =
        "在目标框体生命条上方显示同样的标签。关闭：不显示目标框体标签。",
    ["Moves the target frame's threat label right (more) or left (less) from its place, in pixels."] =
        "将目标框体仇恨标签向右（正值）或向左（负值）移动，单位为像素。",
    ["Moves the target frame's threat label up (more) or down (less) from its place, in pixels. Also "
        .. "the gap above the bar."] = "将目标框体仇恨标签向上（正值）或向下（负值）移动，单位为像素。也决定生命条上方的间距。",
    ["The size of the target frame's threat label icon and text: 100% is the default, 200% twice as "
        .. "big, 50% half."] = "目标框体仇恨标签图标和文字的大小：100% 为默认，200% 为两倍大，50% 为一半。",
    ["The red and orange threat sounds. Off: no threat sounds; the labels still change color."] =
        "红色和橙色仇恨声音。关闭：没有仇恨声音；标签仍会变色。",
    ["A sound when a mob's threat label turns red: in the tank view, a mob left you; in the DPS/Healer "
        .. "view, a mob came to you. At most once every 2 seconds. Default: Dyre's Alerts: Bell buzz, from "
        .. "Dyre's Sounds 1.5.0 or later; without it, the game's Raid warning. Game Warnings are the game's own "
        .. "sounds; with Dyre's Sounds installed, all of its sounds follow (Text to Speech says \"Aggro lost\" "
        .. "or \"Aggro\"). A choice plays once to hear it (not in combat). None: no sound."] =
        "当怪物的仇恨标签变红时播放声音：坦克视图中表示怪物离开了你；输出/治疗视图中表示怪物转向了你。每 2 秒最多一次。"
        .. "默认：Dyre's Alerts: Bell buzz，来自 Dyre's Sounds 1.5.0 或更高版本；没有时使用游戏的团队警告。"
        .. "游戏警告是游戏自带声音；安装 Dyre's Sounds 后可使用其全部声音（语音会说“Aggro lost”或“Aggro”）。"
        .. "选择后会播放一次试听（战斗外）。无：不播放。",
    ["A sound when a label turns orange. Tank view: a mob on a nameplate goes from you holding it "
        .. "securely to another unit having more threat (the label shows LOSING). DPS/Healer view: you have "
        .. "more threat than the tank (the early yellow plays nothing). At most once every 2 seconds. Default: "
        .. "Dyre's Alerts: Cartoon shake, from Dyre's Sounds 1.5.0 or later; without it, the game's Quest "
        .. "failed. Pick another "
        .. "sound than the red one, so you can tell them apart. With Dyre's Sounds installed, all of its "
        .. "sounds follow (Text to Speech says \"Losing\" or \"High threat\"). A choice plays once to hear it (not in combat). "
        .. "None: no sound."] =
        "当标签变橙色时播放声音。坦克视图：姓名板上的怪物从你稳稳拉住变为其他单位仇恨更高（标签显示“将失”）。"
        .. "输出/治疗视图：你的仇恨高于坦克（提前出现的黄色不会播放声音）。每 2 秒最多一次。"
        .. "默认：Dyre's Alerts: Cartoon shake，来自 Dyre's Sounds 1.5.0 或更高版本；没有时使用游戏的“任务失败”。"
        .. "请选择与红色声音不同的声音，以便区分。安装 Dyre's Sounds 后可使用其全部声音（语音会说“Losing”或“High threat”）。"
        .. "选择后会播放一次试听（战斗外）。无：不播放。",
    ["On: the red and orange sounds also play when you are not in a group. Off (the default): they play "
        .. "only in a party or raid; the threat labels still change color when solo."] =
        "开启：不在队伍中时也会播放红色和橙色声音。关闭（默认）：仅在队伍或团队中播放；单人时仇恨标签仍会变色。",
    ["The pull bars, Dyre's countdown on screen, and the pet taunt warning. Off: none of them, whatever "
        .. "their own switches say. Sending a pull (/dtt pull, the PULL button) still works."] =
        "开怪条、屏幕上的 Dyre 倒计时和宠物嘲讽警告。关闭：全部不显示，无论它们各自的开关如何。"
        .. "发送开怪（/dtt pull、PULL 按钮）仍然有效。",
    ["Tank view, in a party (not a raid): under each enemy nameplate, a thin bar per party member in its "
        .. "class color, full when that member pulls the mob. No bar for a member not on the mob's threat "
        .. "list."] = "坦克视图，在队伍中（非团队）：每个敌方姓名板下方显示一条细条，按职业颜色代表每名队员，"
        .. "该队员拉住怪物时条满。不在怪物仇恨列表中的队员没有条。",
    ["Sending: /dtt pull and the PULL button always use the best path: Deadly Boss Mods, then BigWigs, then "
        .. "the game's countdown, then Dyre's Toolkit's own message.\n\n"
        .. "On screen: Dyre's big countdown for a pull anyone in your group starts, in place of the game's own "
        .. "countdown, only where no boss mod shows one.\n\n"
        .. "Deadly Boss Mods: turn on its \"Do not show Pull/Break Timer bar\" and \"Do not show announce text for "
        .. "Pull/Break Timer\" (/dbm > Global Disables & Filters > Disable DBM Features) and Dyre's countdown "
        .. "shows instead.\n"
        .. "BigWigs always shows its own pull bar, so with BigWigs loaded Dyre's countdown stays hidden.\n\n"
        .. "/dyre unlock shows it to move."] =
        "发送：/dtt pull 和 PULL 按钮始终使用最佳途径：先 Deadly Boss Mods，再 BigWigs，再游戏倒计时，"
        .. "最后 Dyre's Toolkit 自己的消息。\n\n"
        .. "屏幕：当你的队伍中有人发起开怪时，显示 Dyre 的大倒计时，替代游戏自己的倒计时；仅在没有任何首领插件显示倒计时时。\n\n"
        .. "Deadly Boss Mods：开启其“Do not show Pull/Break Timer bar”和“Do not show announce text for "
        .. "Pull/Break Timer”（/dbm > Global Disables & Filters > Disable DBM Features），Dyre 的倒计时才会显示。\n"
        .. "BigWigs 始终显示自己的开怪条，因此加载 BigWigs 时 Dyre 的倒计时保持隐藏。\n\n"
        .. "/dyre unlock 可显示它以便移动。",
    ["Dyre's countdown: the sound on each of the last 5 seconds. Text to Speech says the number. None: no "
        .. "tick."] = "Dyre 倒计时：最后 5 秒每秒的声音。语音会说出数字。无：没有滴答声。",
    ["Dyre's countdown: the sound at 0, with PULL!. Text to Speech says \"Pull\". None: no sound."] =
        "Dyre 倒计时：0 秒时的声音，伴随“开怪！”。语音会说“Pull”。无：不播放。",
    ["Hunters and Warlocks: a message on screen and in chat when your pet's taunt (Growl, Torment, "
        .. "Suffering) is on autocast in a group where you are not the tank."] =
        "猎人和术士：当宠物的嘲讽（低吼、折磨、痛苦）在队伍中开启自动施放且你不是坦克时，在屏幕和聊天中提示。",
    ["The tank button bar. Off: no bar, also while frames are unlocked. The key bindings and /dtt still "
        .. "work, because you press them on purpose."] =
        "坦克按钮条。关闭：没有按钮条，解锁框体时也不显示。按键绑定和 /dtt 仍然可用，因为那是你主动按下的。",
    ["Skull, Next marker, pings, and PULL in a bar.\n\nAuto (tank only): shown while your group role is "
        .. "Tank (or you are a raid's main tank), or as a Warrior in Defensive Stance, a Druid in Bear or Dire "
        .. "Bear Form, or a Paladin with Righteous Fury. Always and Never force it. It shows also while frames "
        .. "are unlocked, to move it. In combat, a change waits for the end of combat.\n\nThe key bindings "
        .. "(Key Bindings > AddOns > Dyre's Toolkit) work also with the bar hidden."] =
        "骷髅、下一个标记、信号和 PULL 组成一条按钮条。\n\n自动（仅坦克）：当你的队伍职责为坦克（或你是团队主坦），"
        .. "或战士处于防御姿态、德鲁伊处于熊形态或巨熊形态、圣骑士开启正义怒火时显示。始终和从不则强制显示或隐藏。"
        .. "解锁框体时也会显示，便于移动。战斗中修改会在战斗结束后生效。\n\n"
        .. "按键绑定（按键设置 > 插件 > Dyre's Toolkit）在按钮条隐藏时也可用。",
    ["The length of the PULL button's countdown. /dtt pull 5 or /dyre pull 5 sets it for one pull."] =
        "PULL 按钮倒计时的时长。/dtt pull 5 或 /dyre pull 5 可临时设为一次开怪的时长。",

    -- Profile
    ["Defaults (a clean slate)"] = "默认（全新状态）",
    [" (this character)"] = "（本角色）",
    ["Paste an export line first."] = "请先粘贴一行导出文本。",
    ["That text is too long to be an export line."] = "这段文本太长，不是有效的导出行。",
    ["That is not a Dyre's AddOns export line."] = "这不是 Dyre 插件的导出行。",
    ["That line comes from a newer version. Update the AddOns, then try again."] =
        "该导出行来自更新的版本。请先更新插件，再重试。",
    ["That line comes from a test version. Export it again."] = "该导出行来自测试版本。请重新导出。",
    ["That line has %s settings, not %s settings."] = "该导出行是 %s 的设置，不是 %s 的设置。",
    ["That line is damaged or incomplete. Copy all of it again."] = "该导出行已损坏或不完整。请重新完整复制。",
    ["too large"] = "内容过大",
    ["damaged"] = "已损坏",
    ["Settings change out of combat."] = "设置需在战斗结束后修改。",
    ["Your character is not ready yet. Try again in a moment."] = "角色尚未准备就绪。请稍后再试。",
    ["%s cannot take those settings. Nothing changed."] = "%s 无法接收这些设置。未做任何改动。",
    ["That character's settings are not saved."] = "该角色没有保存的设置。",
    ["this character's settings for every Dyre's AddOn (settings, places, sizes, and sounds)"] =
        "本角色所有 Dyre 插件的设置（设置、位置、大小和声音）",
    ["%s."] = "%s。",
    ["Profile copied"] = "配置已复制",
    ["Profile imported"] = "配置已导入",
    ["%s. Reload to finish %s."] = "%s。重载以完成 %s。",
    ["Copy"] = "复制",
    ["Cancel"] = "取消",
    ["Done"] = "完成",
    ["Import"] = "导入",
    ["Reload now"] = "立即重载",
    ["Later"] = "稍后",
    ["Pick another character's profile, or Defaults, to copy."] = "请选择其他角色的配置或“默认”后再复制。",
    ["Pick another character's profile, or Defaults for a clean slate, then press Copy. It covers "
        .. "every Dyre's AddOn.\n\nA character shows here after it logs in once with this version."] =
        "选择其他角色的配置，或选择“默认”获得干净状态，然后按“复制”。它会覆盖所有 Dyre 插件。\n\n"
        .. "角色使用此版本登录一次后才会出现在列表中。",
    ["Copy %s to %s?\n\nThis replaces %s."] = "将 %s 复制到 %s？\n\n这会替换%s。",
    ["Copy the choice above"] = "复制上面的选择",
    ["this character"] = "本角色",
    ["Replaces %s with the choice."] = "用所选配置替换%s。",
    ["Replaces %s with a pasted export line."] = "用粘贴的导出行替换%s。",
    ["Shows %s as one line of text, to copy and keep or share."] = "将%s显示为一行文本，便于复制保存或分享。",
    ["Export profile"] = "导出配置",
    ["Export"] = "导出",
    ["Press Ctrl+C to copy %s.\nPaste it with Import on another character or account."] =
        "按 Ctrl+C 复制%s。\n在另一角色或账号上用“导入”粘贴。",
    ["Import profile"] = "导入配置",
    ["Paste an export line (Ctrl+V).\n\nThis replaces %s."] = "粘贴导出行（Ctrl+V）。\n\n这会替换%s。",
    ["Profile: %s"] = "配置：%s",
    ["Profile"] = "配置",
    ["Each character has one profile, its own: its settings for every Dyre's AddOn."] =
        "每个角色都有自己的配置：该角色所有 Dyre 插件的设置。",
    ["Copy settings from"] = "复制设置来源",

    -- Tank tools: sounds, markers, commands
    ["Game Warnings"] = "游戏警告",
    ["None"] = "无",
    ["Raid warning"] = "团队警告",
    ["Quest failed"] = "任务失败",
    ["Ready check"] = "就绪检查",
    ["Alarm clock"] = "闹钟",
    ["Boss emote"] = "首领表情",
    ["Boss whisper"] = "首领密语",
    ["Battleground ready"] = "战场就绪",
    ["Map ping"] = "地图标记",
    ["Countdown tick"] = "倒计时滴答",
    ["Countdown go"] = "倒计时开始",
    ["Star"] = "星星",
    ["Circle"] = "圆圈",
    ["Diamond"] = "菱形",
    ["Triangle"] = "三角",
    ["Moon"] = "月亮",
    ["Square"] = "方块",
    ["Cross"] = "十字",
    ["Skull"] = "骷髅",
    ["Use /dtt (settings), /dtt pull [seconds], /dtt reset, /dtt debug, /dtt debug_threat, "
        .. "/dtt debug_taunts, or /dtt debug_dots. /dyre pull, /dyre tank_reset, /dyre tank_debug, "
        .. "/dyre debug_threat, /dyre debug_taunts, and /dyre debug_dots do the same."] =
        "用法：/dtt（设置）、/dtt pull [秒数]、/dtt reset、/dtt debug、/dtt debug_threat、/dtt debug_taunts "
        .. "或 /dtt debug_dots。/dyre pull、/dyre tank_reset、/dyre tank_debug、/dyre debug_threat、"
        .. "/dyre debug_taunts 和 /dyre debug_dots 效果相同。",
    ["The threat labels and tank tools are off on this client: "] = "此客户端上的仇恨标签和坦克工具已关闭：",
    ["Give the pull time as whole seconds, %d to %d, or 0 to cancel."] = "请用整数秒给出开怪时长：%d 到 %d，或 0 取消。",
    ["Another AddOn (%s) also uses /dtt. Use /tanktools or /dyre instead."] =
        "另一个插件（%s）也使用了 /dtt。请改用 /tanktools 或 /dyre。",
    ["the toolkit's files are from different versions (missing %s). Reinstall Dyre's Toolkit, then restart the client."] =
        "工具包文件版本不一致（缺少 %s）。请重新安装 Dyre's Toolkit，然后重启客户端。",
    ["this client lacks %s."] = "此客户端缺少 %s。",

    -- Threat label words
    ["OK"] = "安全",
    ["LOW"] = "偏低",
    ["LOST"] = "失去",
    ["HIGH"] = "偏高",
    ["AGGRO"] = "仇恨",
    ["OFF"] = "离开",
    ["LOSING"] = "将失",

    -- Pull countdown
    ["Pull in %d"] = "还有 %d 秒",
    ["Pull in %d - %s"] = "还有 %d 秒 - %s",
    ["PULL!"] = "开怪！",
    ["Pull cancelled"] = "开怪已取消",
    ["Pull countdown"] = "开怪倒计时",
    ["The game refused its countdown (it may need the group leader); Dyre's Toolkit users in your group see the toolkit's."] =
        "游戏拒绝启动倒计时（可能需要队长权限）；你队伍中的 Dyre's Toolkit 用户会看到工具包的倒计时。",
    ["Another Dyre's AddOn runs the pull countdown."] = "另一个 Dyre 插件正在运行开怪倒计时。",
    ["This client has no pull countdown, and neither DBM nor BigWigs is loaded."] =
        "此客户端没有开怪倒计时，并且未加载 DBM 或 BigWigs。",
    ["Deadly Boss Mods"] = "Deadly Boss Mods",
    ["BigWigs"] = "BigWigs",
    ["the game's countdown"] = "游戏倒计时",
    ["Dyre's Toolkit's countdown"] = "Dyre's Toolkit 倒计时",
    ["none"] = "无",

    -- Pet Taunt warning
    ["Pet taunt on"] = "宠物嘲讽已开启",
    [" and "] = "和",
    ["%s is on autocast in a group. Turn it off."] = "%s在队伍中开启了自动施放。请关闭。",
    ["%s are on autocast in a group. Turn it off."] = "%s在队伍中开启了自动施放。请关闭。",
    ["Growl is on autocast in a group. Turn it off."] = "低吼在队伍中开启了自动施放。请关闭。",
    ["Warning messages"] = "警告消息",

    -- Tank buttons
    ["Attack"] = "攻击",
    ["Warning"] = "警告",
    ["Assist"] = "协助",
    ["On my way"] = "正在赶来",
    ["ATK"] = "攻",
    ["WARN"] = "警",
    ["HELP"] = "助",
    ["OMW"] = "赶",
    ["PULL"] = "开怪",
    ["Next marker"] = "下一个标记",
    ["Skull (mouse)"] = "骷髅（鼠标）",
    ["Skull and ping"] = "骷髅并发出信号",
    ["Ping %s"] = "发出%s信号",
    ["Ping %s on your target"] = "对目标发出%s信号",
    ["Pings %s on your target."] = "向你的目标发出%s信号。",
    ["Next marker (mouse, else target)"] = "下一个标记（鼠标指向，否则目标）",
    ["Skull and ping Attack on your target"] = "给目标上骷髅并发出攻击信号",
    ["Skull your target"] = "给目标上骷髅标记",
    ["Skull the mob under your mouse"] = "给鼠标指向的怪物上骷髅标记",
    ["Puts the next marker on the mob under your mouse, else your target: skull, then cross, square... "
        .. "The order starts again after combat."] =
        "给鼠标指向的怪物（否则目标）上顺序中的下一个标记：骷髅、十字、方块……战斗结束后顺序从头开始。",
    ["Starts the pull countdown (DBM or BigWigs when loaded). Set its length in the settings, or type /dtt pull 10."] =
        "开始开怪倒计时（加载了 DBM 或 BigWigs 时用它们）。可在设置中修改时长，或输入 /dtt pull 10。",
    ["Puts the skull on your target, also in combat."] = "给你的目标上骷髅标记，战斗中也可用。",
    ["Puts the skull on the mob under your mouse."] = "给鼠标指向的怪物上骷髅标记。",
    ["Puts the skull on your target and pings Attack on it, in one press."] = "一次按键给目标上骷髅，并对它发出攻击信号。",
    ["The tank button bar is back in its first place."] = "坦克按钮条已回到初始位置。",
    ["Tank buttons"] = "坦克按钮",

    -- Tracking frames
    ["  |cff999999%d s|r"] = "  |cff999999%d 秒|r",
    ["%d m"] = "%d 分",
    ["%d s"] = "%d 秒",
    ["Focus (sample)"] = "焦点（示例）",
    ["Focus: %s"] = "焦点：%s",
    ["Focus"] = "焦点",
    ["Click: %s your focus again."] = "点击：再次对焦点施放%s。",
    ["No marker and no target change. With no focus it does nothing."] = "不设标记，也不切换目标。没有焦点时无效果。",
    ["Your crowd control shows here with its time left."] = "你的控制技能显示在这里，并标出剩余时间。",
    ["Only your focus; with no focus it does nothing."] = "只作用于焦点；没有焦点时无效果。",
    ["Target (sample)"] = "目标（示例）",
    ["Another mob (sample)"] = "另一个怪物（示例）",
    ["One more mob (sample)"] = "再一个怪物（示例）",
    ["target"] = "目标",
    ["focus"] = "焦点",
    ["Smart curse on your %s."] = "对你的%s使用智能诅咒。",
    ["Click: %s (picked out of combat)"] = "点击：%s（战斗外自动选择）",
    ["Ctrl-click: %s"] = "Ctrl+点击：%s",
    ["Shift-click: %s"] = "Shift+点击：%s",
    ["Alt-click: %s"] = "Alt+点击：%s",
    ["The letter shows the best curse for this mob: T Tongues for a caster, else E Elements or W Weakness."] =
        "字母表示对这个怪物的最佳诅咒：法系用 T（语言），否则用 E（元素）或 W（虚弱）。",
    ["Click: cast %s on your %s."] = "点击：对你的%s施放%s。",
    ["You know no spell for this slot yet; it recasts the last one you used."] =
        "这个栏位还没有学会法术；它会重复上一次使用的法术。",
    ["Proc arcs"] = "触发弧线",
    [" Shown by %s now, so this setting does nothing here."] = " 现在由 %s 显示，此项设置在这里不起作用。",
    ["DIES"] = "死亡",
    ["Focus detection reset for every Dyre's AddOn: it is learned again the first time you set a focus."] =
        "所有 Dyre 插件的焦点检测已重置：下次设置焦点时会重新学习。",
    ["No free character macro slot for \"%s\"; free one and it is added."] =
        "角色宏栏位已满，无法创建“%s”；空出一个栏位后会自动添加。",
    ["An owner listener for %s failed and is off until you reload: %s"] =
        "一个 %s 的所有者监听器出错，已停用直到重载：%s",

    -- Procs
    ["Procs"] = "触发",
    ["Sound"] = "声音",
    ["%s arc"] = "%s 弧线",
    ["%s sound"] = "%s 声音",
    ["An arc each side of you, in its own color, while %s can be used. It is "
        .. "dimmed while you are short of rage or other power, also in combat."] =
        "你身体两侧各有一道弧线，显示为它自己的颜色，%s 可用时出现。怒气或其他资源不足时变暗，战斗中同样有效。",
    ["An arc each side of you, in its own color, while %s is up. It drains with the "
        .. "time left and goes the moment you use it, also in combat."] =
        "你身体两侧各有一道弧线，显示为它自己的颜色，%s 存在时出现。它随剩余时间消退，你使用后立刻消失，战斗中同样有效。",
    ["Play a sound the moment %s can be used, also in combat; at most once every "
        .. "%d seconds."] = "%s 变为可用时播放声音，战斗中同样有效；最多每 %d 秒一次。",
    ["Play a sound the moment %s procs, also in combat."] = "%s 触发时播放声音，战斗中同样有效。",
    ["The sound when %s can be used. Choosing one plays it once. The sounds come from "
        .. "Dyre's Sounds."] = "%s 可用时的声音。选择后会播放一次试听。声音来自 Dyre's Sounds。",
    ["The sound when %s procs. Choosing one plays it once. The sounds come from "
        .. "Dyre's Sounds."] = "%s 触发时的声音。选择后会播放一次试听。声音来自 Dyre's Sounds。",
    ["Proc arc size"] = "触发弧线大小",
    ["How big the proc arcs are, in percent. They grow and shrink from their "
        .. "center, and the gap between them grows with them."] =
        "触发弧线的大小，按百分比。它们以中心为基准缩放，间距也随之变化。",
    ["The proc arcs back to 100%."] = "触发弧线恢复为 100%。",
    ["Nightfall (Shadow Trance)"] = "夜幕（暗影冥思）",
    ["Clearcasting (Arcane Concentration)"] = "节能施法（奥术专注）",
    ["Clearcasting (Omen of Clarity)"] = "节能施法（清晰预兆）",
    ["Clearcasting (Elemental Focus)"] = "节能施法（元素专注）",
    ["Nature's Grace"] = "自然之赐",
    ["Flurry"] = "乱舞",
    ["Overpower"] = "压制",
    ["Revenge"] = "复仇",
    ["Missile Barrage"] = "飞弹速射",
    ["Fingers of Frost"] = "寒冰指",
    ["Decimation"] = "灭杀",
    ["Shadow Trance: your next Shadow Bolt is instant."] = "暗影冥思：你的下一个暗影箭变为瞬发。",
    ["Soul Fire casts faster and costs no Soul Shard for 10 seconds."] = "灵魂之火施法更快，且 10 秒内不消耗灵魂碎片。",
    ["Your next damage spell costs no mana."] = "你的下一个伤害法术不消耗法力。",
    ["Your next damage or healing spell or offensive ability costs nothing."] =
        "你的下一个伤害或治疗法术或攻击技能不消耗资源。",
    ["Your next spell casts faster."] = "你的下一个法术施法更快。",
    ["Your next three swings are faster."] = "你的接下来三次近战挥击更快。",
    ["After your target dodges; dimmed while you lack the rage."] = "目标闪避后可用；怒气不足时变暗。",
    ["After you block, dodge, or parry; dimmed while you lack the rage."] =
        "在你格挡、闪避或招架后可用；怒气不足时变暗。",
    ["With two charges up, both arcs show; when you use one, the right arc goes."] =
        "叠到两层时两侧弧线都显示；用掉一层后右侧弧线消失。",

    -- Class data labels
    ["Curse"] = "诅咒",
    ["Bane"] = "灾祸",
    ["Corruption"] = "腐蚀术",
    ["Immolate"] = "献祭",
    ["Siphon Life"] = "生命虹吸",
    ["Fear and control"] = "恐惧与控制",
    ["Fear"] = "恐惧",
    ["Banish"] = "放逐",
    ["Enslave Demon"] = "奴役恶魔",
    ["Howl of Terror"] = "恐惧嚎叫",
    ["Fireball"] = "火球术",
    ["Pyroblast"] = "炎爆术",
    ["Frostfire Bolt"] = "霜火之箭",
    ["Polymorph"] = "变形术",
    ["Moonfire"] = "月火术",
    ["Insect Swarm"] = "虫群",
    ["Entangling Roots"] = "纠缠根须",
    ["Rake"] = "斜掠",
    ["Rip"] = "割裂",
    ["Pounce"] = "扑击",
    ["Lacerate"] = "裂伤",
    ["Hibernate"] = "休眠",
    ["Serpent Sting"] = "毒蛇钉刺",
    ["Immolation Trap"] = "献祭陷阱",
    ["Scare Beast"] = "惊吓野兽",
    ["Wyvern Sting"] = "翼龙钉刺",
    ["Freezing Trap"] = "冰冻陷阱",
    ["Shadow Word: Pain"] = "暗言术：痛",
    ["Devouring Plague"] = "噬灵瘟疫",
    ["Holy Fire"] = "神圣之火",
    ["Shackle Undead"] = "束缚亡灵",
    ["Psychic Scream"] = "心灵尖啸",
    ["Rupture"] = "割裂",
    ["Garrote"] = "锁喉",
    ["Sap"] = "闷棍",
    ["Blind"] = "致盲",
    ["Flame Shock"] = "烈焰震击",
    ["Rend"] = "撕裂",
    ["Intimidating Shout"] = "破胆怒吼",
    ["Hamstring"] = "断筋",
    ["Turn Undead"] = "超度亡灵",
    ["Repentance"] = "忏悔",

    -- 2.18.0: bindings, bar layout, the welcome flag, and shortened proc text
    ["Dyre's Threat and Combat Tools"] = "Dyre 的威胁与战斗工具",
    ["Skull mouseover, else target"] = "骷髅：鼠标指向，否则当前目标",
    ["Skull and ping Attack, mouseover, else target"] = "骷髅并发出攻击信号：鼠标指向，否则当前目标",
    ["Ping Attack on your target"] = "对目标发出攻击信号",
    ["Ping Warning on your target"] = "对目标发出警告信号",
    ["Ping Assist on your target"] = "对目标发出协助信号",
    ["Ping On my way on your target"] = "对目标发出“正在赶来”信号",
    ["Lay the buttons out in a row or a column."] = "将按钮排成一行或一列。",
    ["Layout"] = "排列",
    ["Horizontal"] = "横向",
    ["Vertical"] = "纵向",
    ["Threat, tank tools, and swing timer"] = "威胁、坦克工具与挥砍计时",
    ["Open"] = "打开",
    ["Dyre's Threat and Combat Tools: threat labels and sounds, tank tools, and the swing timer."] =
        "Dyre 的威胁与战斗工具：威胁文字与音效、坦克工具和挥砍计时。",
    ["These are now in Dyre's Threat and Combat Tools: install it from CurseForge."] =
        "这些功能现已移至 Dyre 的威胁与战斗工具：请从 CurseForge 安装。",
    ["The threat labels, tank tools, and swing timer are now in Dyre's Threat and Combat Tools: install it "
        .. "from CurseForge, then use /dct."] =
        "威胁文字、坦克工具和挥砍计时现已移至 Dyre 的威胁与战斗工具：请从 CurseForge 安装，然后使用 /dct。",
    ["Use /dyre (settings), /dyre unlock, /dyre lock, /dyre grid, /dyre snap, /dyre minimap, or /dyre debug."] =
        "使用 /dyre（设置）、/dyre unlock、/dyre lock、/dyre grid、/dyre snap、/dyre minimap 或 /dyre debug。",
    ["Shows an arc and plays a chime when a proc makes an important spell or ability ready."] =
        "触发使重要法术或技能就绪时，显示弧线并播放提示音。",
    ["Shows every Dyre's AddOn frame so you can drag it."] = "显示所有 Dyre 插件的框体，以便拖动。",
    ["Shows a grid across the screen while frames are unlocked."] = "框体解锁时在屏幕上显示网格。",
    ["Frames you drop line up with the grid; hold Ctrl as you drop to place one exactly."] =
        "放下的框体与网格对齐；按住 Ctrl 放下可精确摆放。",
    ["Shows the Dyre's AddOns button on the minimap."] = "在小地图上显示 Dyre 插件按钮。",
    ["Each Dyre's AddOn says its name and version in chat at login."] =
        "登录时每个 Dyre 插件都会在聊天框显示名称与版本。",
    ["The sound to play when %s can be used."] = "当%s可以使用时播放的音效。",
    ["The sound to play when %s procs."] = "当%s触发时播放的音效。",
    ["An arc on each side of you while %s can be used."] = "%s可以使用时，在你两侧显示弧线。",
    ["An arc on each side of you while %s is up."] = "%s持续期间，在你两侧显示弧线。",
    ["Plays a sound when %s can be used."] = "%s可以使用时播放提示音。",
    ["Plays a sound when %s procs."] = "%s触发时播放提示音。",
    [" Greyed out: you have not learned %s yet."] = " 已变灰：你尚未学会%s。",
    ["How big the proc arcs are."] = "触发弧线的大小。",
    ["Puts the proc arcs back to their normal size."] = "将触发弧线恢复为正常大小。",
    ["How solid it is."] = "它的不透明度。",
    ["Its %s."] = "它的%s。",
    ["Puts it back to its normal size."] = "将其恢复为正常大小。",
    ["Switch between a row and a column."] = "在一行与一列之间切换。",
    ["Pick another character's settings, or Defaults, then press Copy."] =
        "选择另一个角色的设置，或“默认”，然后按“复制”。",
}

ns.LOCALES = {enUS = enUS, zhCN = zhCN}
ns.L = ns.LOCALES[type(GetLocale) == "function" and GetLocale() or "enUS"] or enUS
ns.IsChinese = ns.L == zhCN

-- The Chinese text for an English string, with an optional context for the
-- same word with two meanings ("fill|Solid"). Other locales get the English.
function ns.T(text, context)
    if type(text) ~= "string" or ns.L ~= zhCN then
        return text
    end
    if context then
        local contextual = zhCN[context .. "|" .. text]
        if contextual then
            return contextual
        end
    end
    return zhCN[text] or text
end
