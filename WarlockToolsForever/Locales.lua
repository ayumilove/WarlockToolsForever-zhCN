local _, WTF = ...

-- Text chosen by the client's language. GetLocale returns the locale code
-- ("enUS", "zhCN", ...); a client without it, or one whose language has no
-- table here, uses English. WTF.L is the table for this client, and
-- WTF.LOCALES keeps every table, since SanitizeDB treats a text left at any
-- locale's default as unedited and swaps in this locale's.
--
-- announceDefaults are WTF.ANNOUNCE_DEFAULTS: the same keys, with %T (the
-- target), %Z (your zone), and %M (a raid marker) kept. One chat line, 255
-- bytes at most (SanitizeAnnouncement drops longer texts).
-- announcePage labels the Announce settings page; chatNames names the chat
-- types in its blocked-message reports.

local enUS = {
    announceDefaults = {
        summonGroupText = "The ritual hungers! Click the portal to drag >> %T << through the Twisting Nether - via Warlock Tools Forever (WTF)",
        soulstoneGroupText = "A piece of >> %T <<'s soul now rests in my keeping. Death is merely an inconvenience - via Warlock Tools Forever (WTF)",
        summonWhisperText = "Summoning you to %Z, since your sloth-like pace would get you there sometime next week. Accept the summon when it pops up (and tell me if it doesn't). Courtesy of Warlock Tools Forever (WTF)",
        soulstoneWhisperText = "I've trapped a sliver of your soul in a stone. If you die, it drags you back to life right where you fell, so if you're going to die, die in a good spot. Courtesy of Warlock Tools Forever (WTF)",
        healthstoneEmoteText = "crushes a Soul Shard and forges a Healthstone from the screaming essence within. - via Warlock Tools Forever (WTF)",
        soulstoneEmoteText = "binds a captured soul into a Soulstone. Someone's afterlife just got an escape hatch. - via Warlock Tools Forever (WTF)",
        healthstoneWhisperText = "Here, have a Healthstone. Some poor creature's essence gives you more health! Courtesy of Warlock Tools Forever (WTF)",
        fearGroupText = "Fearing >> %T <<. Let it run; chase it and you bring friends - via Warlock Tools Forever (WTF)",
        banishGroupText = "Banishing >> %T << %M to the Twisting Nether. Hands off until it comes back - via Warlock Tools Forever (WTF)",
        enslaveGroupText = "Enslaving >> %T <<. It works for me now; leave my new pet alone - via Warlock Tools Forever (WTF)",
        howlGroupText = "Howl of Terror! Everything nearby is about to run screaming - via Warlock Tools Forever (WTF)",
    },
    announcePage = {
        title = "Announce",
        help = "%T is the target's full name and %Z your zone. Press Enter to keep an edit, Escape to undo it. "
            .. "Nothing is sent for yourself or for a cast that fails. The Fear and Banish announcements moved "
            .. "to Dyre's Debuff Tracker (the Control page).",
        channelLabel = "Group messages go to",
        channelGroup = "Raid or party (nothing when alone)",
        channelSay = "Say (the game may block it outdoors)",
        rows = {
            summonGroup = "Ritual of Summoning: tell the group",
            summonWhisper = "Ritual of Summoning: whisper the target",
            soulstoneGroup = "Soulstone: tell the group",
            soulstoneWhisper = "Soulstone: whisper the target",
            healthstoneWhisper = "Healthstone trade: whisper the player",
            healthstoneEmote = "Healthstone created: emote (starts with your name; once a minute)",
            soulstoneEmote = "Soulstone created: emote (starts with your name; once a minute)",
            fearGroup = "Fear: tell the group as you start casting",
            banishGroup = "Banish: tell the group as you start casting (%M: its moon, at your focus)",
            enslaveGroup = "Enslave Demon: tell the group as you start casting",
            howlGroup = "Howl of Terror: tell the group",
        },
        blockedSay = "The game blocked the Say announcement. Choose Group in the Announce settings.",
        blockedChat = "The game blocked the %s message. Turn it off in the Announce settings.",
        chatNames = {PARTY = "party", RAID = "raid", WHISPER = "whisper", SAY = "say"},
    },
    mainAnnounce = {
        name = "Announce",
        tooltip = "Tell your group and whisper the target when your Ritual of Summoning or a Soulstone use "
            .. "succeeds, and whisper the player when a Healthstone trade opens.",
    },
}

-- Chinese: the player's own Snow White voice (the mirror, the poisoned apple,
-- the witch), with emoji as asked, and without the credit line: MIT asks for
-- no attribution in chat messages. If the client shows the emoji as boxes,
-- remove only the leading symbol; the rest of each text stands alone.
local zhCN = {
    announceDefaults = {
        summonGroupText = "🪞魔镜魔镜，%T 在哪里？传送门已开，快来点门！",
        soulstoneGroupText = "🍎%T 的灵魂已封入毒苹果，死亡不过是一场沉睡。",
        summonWhisperText = "🏰小矮人别赶路啦！正在召唤你到 %Z，记得接受哦～",
        soulstoneWhisperText = "🍎白雪公主，灵魂石已绑好。",
        healthstoneEmoteText = "🍬魔女开炉做糖啦！放心，不是毒苹果……大概。",
        soulstoneEmoteText = "🔮魔女将一缕灵魂封入宝石，留作死亡后的退路。",
        healthstoneWhisperText = "🍬魔女的糖已送达！残血记得吃，毒不毒就看命啦～",
        fearGroupText = "🌲%T 被吓进黑森林了！",
        banishGroupText = "🌙%T 已陷入沉睡！",
        enslaveGroupText = "🍎%T 已被魔女收服！",
        howlGroupText = "🐺魔女尖叫啦！怪物四散奔逃，别追！",
    },
    announcePage = {
        title = "通报",
        help = "%T 是目标的全名，%Z 是你的区域。按回车保存修改，按 Esc 撤销。对自己施放或施放失败时不会发送任何"
            .. "消息。恐惧与放逐的通报已移到 Dyre's Debuff Tracker（控制页）。",
        channelLabel = "团队消息发送到",
        channelGroup = "团队或小队（单人时不发送）",
        channelSay = "说（野外可能被系统拦截）",
        rows = {
            summonGroup = "召唤仪式：通知团队",
            summonWhisper = "召唤仪式：密语目标",
            soulstoneGroup = "灵魂石：通知团队",
            soulstoneWhisper = "灵魂石：密语目标",
            healthstoneWhisper = "治疗石交易：密语对方",
            healthstoneEmote = "制造治疗石：表情（以你的名字开头；每分钟一次）",
            soulstoneEmote = "制造灵魂石：表情（以你的名字开头；每分钟一次）",
            fearGroup = "恐惧：开始施法时通知团队",
            banishGroup = "放逐：开始施法时通知团队（%M：对焦点时为它的月亮标记）",
            enslaveGroup = "奴役恶魔：开始施法时通知团队",
            howlGroup = "恐惧嚎叫：通知团队",
        },
        blockedSay = "游戏拦截了“说”频道的通报。请在通报设置里改选“团队”。",
        blockedChat = "游戏拦截了%s消息。请在通报设置里关闭它。",
        chatNames = {PARTY = "小队", RAID = "团队", WHISPER = "密语", SAY = "说"},
    },
    mainAnnounce = {
        name = "通报",
        tooltip = "召唤仪式或灵魂石施放成功时通知团队并密语目标；治疗石交易窗口打开时密语对方。",
    },
}

WTF.LOCALES = {enUS = enUS, zhCN = zhCN}
WTF.L = WTF.LOCALES[type(GetLocale) == "function" and GetLocale() or "enUS"] or enUS

-- English UI text -> zhCN, keyed by the English line, so a line missing here
-- still shows (in English) instead of disappearing. A second argument picks a
-- context ("fill|Solid" and "outline|Solid" are different Chinese words).
-- Spell and item proper nouns never go through this table: WTF.SpellName and
-- WTF.ItemName take them from the client, so they match its language exactly.
local zhText = {
    -- Reused
    ["None"] = "无",
    ["you"] = "你",
    -- Core
    ["  Ready. Type /wtf to open the settings."] = "  就绪。输入 /wtf 打开设置。",
    ["Install Dyre's Toolkit from CurseForge for one layout mode and settings home for all Dyre's AddOns."] =
        "请从 CurseForge 安装 Dyre's Toolkit，让所有 Dyre 插件共用一种布局模式和设置入口。",
    ["Update Dyre's Toolkit from CurseForge: this version is too old for WTF, so WTF uses its own layout."] =
        "请从 CurseForge 更新 Dyre's Toolkit：此版本对 WTF 来说太旧，因此 WTF 使用自己的布局。",
    ["the shield display"] = "护盾显示",
    ["the cooldown chimes, the Nightfall sound, and the Demon Armor reminder"] =
        "冷却提示音、夜幕音效和恶魔护甲提醒",
    ["Enable %s in the AddOn list for %s: it moved there from WTF."] =
        "请在插件列表中启用 %s，以恢复%s：它已从 WTF 移到那里。",
    ["Install %s from CurseForge for %s: it moved there from WTF."] =
        "请从 CurseForge 安装 %s，以恢复%s：它已从 WTF 移到那里。",
    ["AddOn files are from different versions (missing %s). Reinstall every Warlock Tools Forever file, "
        .. "then restart the client."] =
        "插件文件版本不一致（缺少 %s）。请重新安装 Warlock Tools Forever 的全部文件，然后重启客户端。",
    ["Warlock Tools Forever is for Warlocks, so it stays off on this character."] =
        "Warlock Tools Forever 是术士专用插件，因此在本角色上保持关闭。",
    ["All WTF frames locked."] = "已锁定 WTF 的全部框体。",
    ["All WTF frames unlocked: drag them where you want (Shift-drag moves a snapped group), then type /wtf lock."] =
        "已解锁 WTF 的全部框体：把它们拖到想要的位置（按住 Shift 拖动可移动吸附在一起的一组），然后输入 /wtf lock。",
    ["Install or update Dyre's Toolkit (2.5 or later) from CurseForge for the DoT tracker, the nameplate DoT "
        .. "dots, the Control bar, and DoT damage prediction: they stay off without it."] =
        "请从 CurseForge 安装或更新 Dyre's Toolkit（2.5 或更高版本），以启用持续伤害追踪、姓名板持续伤害圆点、"
            .. "控制条和持续伤害预测；没有它这些功能将保持关闭。",
    ["WTF frames move back to their default places after combat."] = "战斗结束后，WTF 的框体会移回默认位置。",
    ["Another AddOn (%s) also uses %s. Use %s instead."] = "另一个插件（%s）也在使用 %s。请改用 %s。",
    ["Drag to move · /wtf lock when done"] = "拖动以移动 · 完成后输入 /wtf lock",
    -- DoT families and tracker settings
    ["Curse"] = "诅咒",
    ["Bane"] = "灾祸",
    ["Corruption"] = "腐蚀术",
    ["Immolate"] = "献祭",
    ["Siphon Life"] = "生命虹吸",
    ["Fear and control"] = "恐惧与控制",
    ["Target panel color"] = "目标框体颜色",
    ["Focus panel color"] = "焦点框体颜色",
    ["Other mobs panel color"] = "其他怪物框体颜色",
    ["Target"] = "目标",
    ["Focus"] = "焦点",
    ["Others"] = "其他",
    ["target panel"] = "目标框体",
    ["focus panel"] = "焦点框体",
    ["other mobs' panel"] = "其他怪物框体",
    ["Target panel opacity"] = "目标框体不透明度",
    ["Focus panel opacity"] = "焦点框体不透明度",
    ["Other mobs panel opacity"] = "其他怪物框体不透明度",
    ["Icon size"] = "图标大小",
    ["Name width"] = "名字宽度",
    ["The room the name has beside the icons (name Left or Right): the row grows or shrinks with it. "
        .. "A longer name is cut with \"...\". Above or below the icons, the name spans the row."] =
        "名字在图标旁占用的宽度（名字在左或右时）；行会随之变宽或变窄。过长的名字用“...”截断。"
            .. "名字在上方或下方时，会占满整行。",
    ["Text size"] = "文字大小",
    ["Bar width"] = "条形宽度",
    ["Line height"] = "行高",
    ["Left"] = "左",
    ["Right"] = "右",
    ["Above"] = "上",
    ["Below"] = "下",
    ["Stripes"] = "条纹",
    ["Bar texture"] = "条材质",
    ["fill|Solid"] = "实心",
    ["outline|Solid"] = "实线",
    ["Purple"] = "紫色",
    ["Red"] = "红色",
    ["Orange"] = "橙色",
    ["White"] = "白色",
    ["Green"] = "绿色",
    ["Number"] = "数字",
    ["Percent"] = "百分比",
    ["Number and Percent"] = "数字和百分比",
    -- Options: page titles and moved-feature pages
    ["Soul Shards"] = "灵魂碎片",
    ["Stones"] = "石头",
    ["DoT Tracker"] = "持续伤害追踪",
    ["DoTs"] = "持续伤害",
    ["Alerts"] = "警报",
    ["Shield"] = "护盾",
    ["Cooldown Chimes"] = "冷却提示音",
    ["Demon Armor"] = "恶魔护甲",
    ["Control"] = "控制",
    ["The AddOn settings page is unavailable on this client. Use /wtf shards for status."] =
        "此客户端无法打开插件设置页。可用 /wtf shards 查看状态。",
    [" (Coming soon)"] = "（即将推出）",
    ["Shield display"] = "护盾显示",
    ["Open Shield settings"] = "打开护盾设置",
    ["The shield display"] = "护盾显示",
    ["Cooldown chimes"] = "冷却提示音",
    ["Open Chime settings"] = "打开提示音设置",
    ["The cooldown chimes"] = "冷却提示音",
    ["Nightfall sound"] = "夜幕音效",
    ["Open Proc settings"] = "打开触发音效设置",
    ["The Nightfall sound (Proc Sounds)"] = "夜幕音效（触发音效）",
    ["Demon Armor reminder"] = "恶魔护甲提醒",
    ["Open Reminder settings"] = "打开提醒设置",
    ["The Demon Armor reminder"] = "恶魔护甲提醒",
    ["Install %s from CurseForge for %s."] = "请从 CurseForge 安装 %s，以恢复%s。",
    ["%s moved to %s in WTF %s. This opens its settings."] = "%s已在 WTF %s 中移到 %s。点击打开它的设置。",
    ["%s (moved to %s)"] = "%s（已移到 %s）",
    ["%s moved to %s in WTF %s. %s"] = "%s已在 WTF %s 中移到 %s。%s",
    ["Open Debuff Tracker settings"] = "打开 Debuff Tracker 设置",
    ["DoT tracker and damage prediction"] = "持续伤害追踪与伤害预测",
    ["The DoT tracker, DoT damage prediction, and the smart curse"] =
        "持续伤害追踪、持续伤害预测与智能诅咒",
    ["DoT colors, order, and nameplate dots"] = "持续伤害颜色、顺序与姓名板圆点",
    ["The DoT colors, order, and nameplate DoT dots"] = "持续伤害颜色、顺序与姓名板圆点",
    ["Control bar, macros, and announcements"] = "控制条、宏与通报",
    ["The Control bar, \"! Fear\", \"! Banish\", \"! Seduction\", and the Fear and Banish announcements"] =
        "控制条、\"! Fear\"、\"! Banish\"、\"! Seduction\"，以及恐惧与放逐通报",
    ["the DoT tracker, DoT colors, nameplate DoT dots, DoT damage prediction, the smart curse, "
        .. "and the Control bar with its macros and announcements"] =
        "持续伤害追踪、颜色与姓名板圆点、伤害预测、智能诅咒，以及带宏与通报的控制条",
    ["Smart curse (moved to Dyre's Debuff Tracker)"] = "智能诅咒（已移到 Dyre's Debuff Tracker）",
    -- Options: Alerts page, the proc's owner (1.10.1)
    ["%s arcs and sound"] = "%s弧线与音效",
    ["Open settings"] = "打开设置",
    ["No AddOn plays it with proc arcs now."] = "现在没有插件用触发弧线播放它。",
    ["%s plays it with its proc arcs. This opens its settings."] =
        "%s会用它自己的触发弧线播放。点击打开它的设置。",
    ["No Dyre's AddOn plays it with proc arcs now."] = "现在没有 Dyre 插件用触发弧线播放它。",
    ["The settings open out of combat."] = "设置需在战斗结束后打开。",
    -- Options: Control page
    ["Fear, Banish, and your focus"] = "恐惧、放逐与你的焦点",
    ["How Fear and your focus work"] = "恐惧与焦点如何运作",
    ["Show in chat"] = "在聊天中显示",
    ["Say in chat how \"! Fear\", the Focus box, and \"! Banish\" use your focus."] =
        "在聊天中说明“! Fear”、焦点框和“! Banish”如何使用你的焦点。",
    ["\"! Fear\" makes the mob under your mouse (else your target) your focus and fears it. "
        .. "Shift-press it to fear another mob and keep your focus."] =
        "“! Fear”会把鼠标指向的怪物（没有则用你的目标）设为焦点并恐惧它。按住 Shift 按下可恐惧另一只怪物，"
            .. "同时保留你的焦点。",
    ["The Focus box above the Control bar shows your focus's Fear. Click it to fear your focus again; "
        .. "with no focus it does nothing."] =
        "控制条上方的焦点框会显示你焦点上的恐惧。点击它可再次恐惧你的焦点；没有焦点时不起作用。",
    ["Every other mob you fear gets its own row, and a Fear timer under its nameplate."] =
        "你恐惧的每一只其他怪物都会有一行，并在其姓名板下方显示恐惧计时。",
    ["\"! Banish\" works the same way: it makes the mob your focus, marks it with the moon, and banishes it. "
        .. "Click its row to banish your focus again."] =
        "“! Banish”同理：把怪物设为焦点、标记月亮并放逐它。点击它的行可再次放逐你的焦点。",
    ["Where the game has no focus (Classic Era), the macros fear or banish the mob under your mouse, else "
        .. "your target; rows show the time left but take no clicks, and there is no Focus box."] =
        "在游戏没有焦点功能的版本（经典旧世）中，宏会恐惧或放逐鼠标指向的怪物（没有则用你的目标）；"
            .. "行只显示剩余时间，不能点击，也没有焦点框。",
    ["%s marker"] = "%s标记",
    ["The raid marker for a mob you %s: the \"! %s\" macro marks your focus with it, also in combat. "
        .. "The row click and the plain spell button do not mark. For a Banish at your focus, %%M puts it in "
        .. "the message. In a raid only the leader and assistants mark."] =
        "你%s怪物时使用的团队标记：“! %s”宏会用它标记你的焦点，战斗中也可用。点击行和普通法术按钮不会标记。"
            .. "对焦点放逐时，%%M 会把它写进消息。在团队中只有队长和助理能标记。",
    ["Keep control macros"] = "保留控制宏",
    ["Keep \"! Fear\", \"! Banish\", \"! Seduction\", and \"! Curse\" in your character macros for your action bars, "
        .. "each once you know its spell. \"! Fear\" makes the mob under your mouse (else your target) your "
        .. "focus and fears it; Shift-press it to fear another mob and keep your focus. The Focus box above "
        .. "the Control bar shows your focus's Fear; click it to fear your focus again. \"! Banish\" and "
        .. "\"! Seduction\" focus the hostile mob under your mouse (or your target, out of combat) and cast on "
        .. "your focus; \"! Banish\" also marks it with the moon. \"! Seduction\" appears once your Succubus "
        .. "or Incubus has learned Seduction from its Grimoire, and casts only while one is your pet. \"! Curse\" "
        .. "is the smart curse (DoT Tracker page). Turning this off deletes them."] =
        "把“! Fear”“! Banish”“! Seduction”和“! Curse”保留在动作条可用的角色宏中；学会对应法术后会各自出现。"
            .. "“! Fear”会把鼠标指向的怪物（没有则用你的目标）设为焦点并恐惧它；按住 Shift 按下可恐惧另一只怪物，"
            .. "同时保留你的焦点。控制条上方的焦点框会显示你焦点上的恐惧；点击它可再次恐惧你的焦点。"
            .. "“! Banish”和“! Seduction”会把鼠标指向的敌对怪物（脱战时为你的目标）设为焦点，并对焦点施放；"
            .. "“! Banish”还会标记月亮。当你的魅魔或梦魇从魔典学会诱惑后，“! Seduction”才会出现，"
            .. "且仅在魅魔或梦魇为宠物时施放。“! Curse”是智能诅咒（见“持续伤害追踪”页）。"
            .. "关闭此选项会删除这些宏。",
    ["Fear timers on nameplates"] = "姓名板上的恐惧计时",
    ["A thin bar under each feared mob's nameplate that drains with your Fear's time left, so you see which "
        .. "one is about to break; click its nameplate to target it."] =
        "在被恐惧怪物的姓名板下方显示一条细条，随恐惧剩余时间缩短，方便看出哪一只即将脱离；点击其姓名板可选中它。",
    ["Bar size"] = "控制条大小",
    ["How big the control bar is, in percent. A change in combat applies when combat ends."] =
        "控制条的大小，以百分比表示。战斗中的修改会在战斗结束后生效。",
    -- Options: Shards page
    ["Match soul bag size"] = "匹配灵魂袋容量",
    ["Keep as many Soul Shards as your soul bags hold, or 6 without a soul bag."] =
        "让携带的灵魂碎片数量与灵魂袋容量一致；没有灵魂袋时为 6 枚。",
    ["Shard limit"] = "碎片上限",
    ["How many Soul Shards to keep in your bags. Turn off Match soul bag size to change it."] =
        "背包中保留的灵魂碎片数量。关闭“匹配灵魂袋容量”后可修改。",
    ["Report deletions in chat"] = "在聊天中报告删除",
    ["Print one chat line for each Soul Shard WTF deletes."] = "WTF 每删除一枚灵魂碎片，就在聊天中输出一行。",
    ["Show the shard counter"] = "显示碎片计数器",
    ["A Soul Shard icon with your shard count: red when low, green at your limit. Drag it to move it."] =
        "一枚灵魂碎片图标和你的碎片数量：低于警告值时变红，达到上限时变绿。拖动可移动。",
    ["Low shard warning"] = "低碎片警告",
    ["The counter turns red at this many Soul Shards or fewer."] = "碎片数量低于或等于此值时，计数器变红。",
    ["Shard counter size"] = "碎片计数器大小",
    ["How big the shard counter is, in percent. It keeps its center, and changes at once, also in combat."] =
        "碎片计数器的大小，以百分比表示。缩放时保持中心不变，并立即生效，战斗中也可以调整。",
    -- Options: Stones page
    ["Show the Stones bar"] = "显示石头栏",
    ["A bar with Soulstone and Healthstone buttons: left-click uses one, right-click creates one."] =
        "带有灵魂石和治疗石按钮的石头栏：左键使用，右键制造。",
    ["The bar with the Soulstone and Healthstone buttons. Changes in combat apply when combat ends."] =
        "带有灵魂石和治疗石按钮的栏。战斗中的修改会在战斗结束后生效。",
    ["Stones bar size"] = "石头栏大小",
    ["How big the Stones bar is, in percent. It keeps its center. A change in combat applies when combat ends."] =
        "石头栏的大小，以百分比表示。缩放时保持中心不变。战斗中的修改会在战斗结束后生效。",
    ["Keep stone macros"] = "保留石头宏",
    ["Keep \"! Healthstone\" and \"! Soulstone\" in your character macros for your action bars: "
        .. "left-click uses your best stone, right-click creates one. Turning this off deletes them."] =
        "把“! Healthstone”和“! Soulstone”保留在动作条可用的角色宏中：左键使用最好的石头，右键制造一块。"
            .. "关闭此选项会删除它们。",
    ["Spellstone button"] = "法术石按钮",
    ["A Spellstone button and macro: left-click uses it, right-click creates one."] =
        "一个法术石按钮和宏：左键使用，右键制造。",
    ["Firestone button"] = "火焰石按钮",
    ["A Firestone button and macro: left-click uses it, right-click creates one."] =
        "一个火焰石按钮和宏：左键使用，右键制造。",
    ["Soulstone reminders"] = "灵魂石提醒",
    ["Say in chat when your Soulstone ends, and when none is up: on entering an instance, joining a group, "
        .. "or after a fight, at most every 10 minutes."] =
        "当你的灵魂石结束或当前没有灵魂石时在聊天中提醒：进入副本、加入队伍或战斗结束后，每 10 分钟最多一次。",
    ["Healthstone reminders"] = "治疗石提醒",
    ["Say in chat when you carry no Healthstone, at the same times."] =
        "当你没有携带治疗石时在聊天中提醒，时机与上面相同。",
    ["Spellstone reminders"] = "法术石提醒",
    ["Say in chat when you carry no Spellstone, at the same times."] =
        "当你没有携带法术石时在聊天中提醒，时机与上面相同。",
    ["Firestone reminders"] = "火焰石提醒",
    ["Say in chat when you carry no Firestone, at the same times."] =
        "当你没有携带火焰石时在聊天中提醒，时机与上面相同。",
    -- Options: Tracker page
    ["Name position"] = "名字位置",
    ["Where the mob's name sits in each row."] = "怪物名字在每一行中的位置。",
    ["The DoT tracker's %s in the %s theme."] = "持续伤害追踪在%s主题中的%s。",
    [" A change in combat applies when combat ends."] = "战斗中的修改会在战斗结束后生效。",
    ["Bars"] = "条形",
    ["Compact"] = "紧凑",
    ["Settings for the DoT tracker's %s only."] = "仅用于持续伤害追踪的%s。",
    -- Options: Tracker page, the panel switches (1.10.1)
    ["Show the %s"] = "显示%s",
    ["Show the DoT tracker's %s. Untick it to hide the panel, for example when %s. The other panels stay. "
        .. "A change in combat may wait until combat ends."] =
        "显示持续伤害追踪的%s。取消勾选可隐藏此框体，例如当%s时。其他框体不受影响。"
            .. "战斗中的修改会等到战斗结束后生效。",
    ["your target frame already shows your DoTs"] = "你的目标框体已经显示你的持续伤害",
    ["you do not use it"] = "你不需要用它",
    ["The row border and health fill of the other mobs' rows. It changes at once, also in combat."] =
        "其他怪物行的边框和生命值填充。立即生效，战斗中也会改变。",
    ["The outline and health fill of the %s. It changes at once, also in combat."] =
        "%s的轮廓和生命值填充。立即生效，战斗中也会改变。",
    ["How solid the %s is, rows and all, in percent. It changes at once, also in combat."] =
        "%s（包括所有行）的不透明度，以百分比表示。立即生效，战斗中也会改变。",
    ["General"] = "通用",
    ["Settings that every DoT tracker panel shares, and the nameplate dots."] =
        "所有持续伤害追踪框体共用的设置，以及姓名板圆点。",
    ["Theme"] = "主题",
    ["Compact: a row per mob with an icon per spell. Bars: a block per mob with a bar per spell you know, "
        .. "draining as its time runs out. A change in combat applies when combat ends."] =
        "紧凑：每只怪物一行，每个法术一个图标。条形：每只怪物一个区块，你掌握的每个法术一条计时条，"
            .. "随剩余时间缩短。战斗中的修改会在战斗结束后生效。",
    ["Show DoT dots on nameplates"] = "在姓名板上显示持续伤害圆点",
    ["Hide empty DoT slots"] = "隐藏空的持续伤害栏位",
    ["Show a DoT only while it is on the mob. The empty places stay, so the DoTs do not move. The target and focus "
        .. "rows then do not recast a DoT or show the smart curse letter when you click them."] =
        "只在怪物身上存在持续伤害时显示；空格位仍然保留，因此持续伤害不会移位。"
            .. "开启后，点击目标或焦点行不会补放持续伤害，也不显示智能诅咒字母。",
    [" With Curse slot click set to Smart curse, the smart curse still works from its key binding and the \"! Curse\" macro."] =
        " 当诅咒栏位点击设为“智能诅咒”时，智能诅咒仍可通过其按键绑定和“! Curse”宏使用。",
    ["In combat, a bubble above each hostile nameplate with a dot per DoT you know: colored while it is up, "
        .. "grey while it is missing. Needs at least one DoT you know. The DoTs page chooses the dots."] =
        "战斗中，在每个敌对姓名板上方显示一个气泡，你掌握的每个持续伤害对应一个圆点：存在时显示颜色，"
            .. "缺失时显示灰色。需要至少掌握一个持续伤害。可在“持续伤害”页选择显示的圆点。",
    ["Dot height above nameplates"] = "姓名板上方圆点高度",
    ["How far above the nameplate the dots sit, to clear other nameplate AddOns."] =
        "圆点位于姓名板上方的高度，以便避开其他姓名板插件。",
    ["Nameplate dot opacity"] = "姓名板圆点不透明度",
    ["How solid the bubble of DoT dots above each nameplate is, in percent. It changes at once, also in combat."] =
        "每个姓名板上方的持续伤害圆点气泡的不透明度，以百分比表示。立即生效，战斗中也会改变。",
    ["Show mob health"] = "显示怪物生命值",
    ["Each mob's name line in the DoT tracker is its health bar, in the panel's color, also in combat. "
        .. "A change in combat applies when combat ends."] =
        "持续伤害追踪中每只怪物的名字行会变成生命条，使用框体颜色，战斗中也会显示。"
            .. "战斗中的修改会在战斗结束后生效。",
    ["Health text"] = "生命值文字",
    ["The mob's health as text after its name: its number, its percent, or both."] =
        "在怪物名字后显示生命值文字：数值、百分比或两者。",
    ["Tracker size"] = "追踪器大小",
    ["Reset size"] = "重置大小",
    ["Back to the theme's own sizes and name position."] = "恢复主题自带的大小和名字位置。",
    -- Options: Tracker page, the smart curse (Dyre's Toolkit 2.7.0)
    ["Curse slot"] = "诅咒栏位",
    ["Smart curse: with no modifier, Curse of Tongues on a mob with mana, else Curse of "
        .. "the Elements, else Curse of Weakness, chosen out of combat as your target changes. Shift casts Weakness, "
        .. "Ctrl Tongues (Weakness if you do not know Tongues), Alt Recklessness. The \"! Curse\" macro and the "
        .. "Smart curse key binding (Key Bindings, Warlock Tools Forever) cast it too."] =
        "智能诅咒：不加修饰键时，对有法力的怪物施放语言诅咒，否则施放元素诅咒，再否则施放虚弱诅咒，"
            .. "在你切换目标时于脱战状态下选定。按住 Shift 施放虚弱诅咒，按住 Ctrl 施放语言诅咒"
            .. "（未学会语言诅咒时为虚弱诅咒），按住 Alt 施放鲁莽诅咒。“! Curse”宏和“智能诅咒”按键绑定"
            .. "（按键设置中的 Warlock Tools Forever）也会施放它。",
    ["Curse slot click"] = "诅咒栏位点击",
    ["Last used"] = "上次使用",
    ["Smart curse"] = "智能诅咒",
    ["What a click on the target or focus row's Curse slot casts. Last used: the curse you cast last. "
        .. "Smart curse: with no modifier, Curse of Tongues on a mob with mana, else Curse of "
        .. "the Elements, else Curse of Weakness, chosen out of combat as your target changes. Shift casts Weakness, "
        .. "Ctrl Tongues (Weakness if you do not know Tongues), Alt Recklessness. The \"! Curse\" macro and the "
        .. "Smart curse key binding (Key Bindings, Warlock Tools Forever) cast it too. "
        .. "A change in combat applies when combat ends."] =
        "点击目标或焦点行的诅咒栏位时施放什么。上次使用：你上一次施放的诅咒。"
            .. "智能诅咒：不加修饰键时，对有法力的怪物施放语言诅咒，否则施放元素诅咒，再否则施放虚弱诅咒，"
            .. "在你切换目标时于脱战状态下选定。按住 Shift 施放虚弱诅咒，按住 Ctrl 施放语言诅咒"
            .. "（未学会语言诅咒时为虚弱诅咒），按住 Alt 施放鲁莽诅咒。“! Curse”宏和“智能诅咒”按键绑定"
            .. "（按键设置中的 Warlock Tools Forever）也会施放它。战斗中的修改会在战斗结束后生效。",
    ["Show the smart curse letter"] = "显示智能诅咒字母",
    ["With Smart curse, a letter on the Curse slot's icon for that mob's best curse: T Tongues, "
        .. "E Elements, W Weakness. It changes also in combat."] =
        "使用智能诅咒时，在诅咒栏位图标上显示该怪物最合适诅咒的字母：T 语言、E 元素、W 虚弱。"
            .. "战斗中也会变化。",
    -- Options: Tracker page, the target and focus outline (Dyre's Toolkit 2.8.0, 1.7.1)
    ["Target and focus outline"] = "目标与焦点描边",
    ["How thick the solid outline around the target (purple) and focus (red) rows is, in pixels. 0 hides it. "
        .. "A change in combat applies when combat ends."] =
        "目标行（紫色）和焦点行（红色）外圈实线描边的粗细，单位为像素。0 表示不描边。"
            .. "战斗中的修改会在战斗结束后生效。",
    ["Needs Dyre's Toolkit 2.8 or later."] = "需要 Dyre's Toolkit 2.8 或更高版本。",
    -- Options: prediction
    ["DoT damage prediction"] = "持续伤害预测",
    ["A purple block on the health bar for the damage your DoTs still have to deal."] =
        "生命条上表示你的持续伤害还将造成的伤害的紫色区块。",
    [" On WoW: Forever this needs Dyre's Toolkit 2.6 or later."] =
        " 在魔兽世界：无限中，需要 Dyre's Toolkit 2.6 或更高版本。",
    ["Show Predictive DoT Damage"] = "显示持续伤害预测",
    ["Predictive DoT damage: a purple block on your target's health bar, ending where its health ends, "
        .. "and, with Show mob health on, on each DoT tracker row's, for the damage your "
        .. "Corruption, Curse of Agony, Immolate, and Siphon Life still have to deal. Each DoT's tick is "
        .. "learned from its first tick (on WoW: Forever, from the damage meter after combat); until then "
        .. "it is a guess from its rank and your spell power."] =
        "持续伤害预测：在你目标的生命条上显示一个紫色区块，止于其当前生命值；开启“显示怪物生命值”后，"
            .. "也会显示在持续伤害追踪的每一行上，表示你的腐蚀术、痛苦诅咒、献祭和生命虹吸还将造成的伤害。"
            .. "每个持续伤害的单次伤害会从第一次跳伤中学习（在魔兽世界：无限中，战斗结束后从伤害统计中学习）；"
            .. "在此之前，按等级和法术强度估算。",
    ["Also on nameplates"] = "也显示在姓名板上",
    ["The same block on each hostile nameplate's health bar."] = "在每个敌对姓名板生命条上显示同样的区块。",
    ["Show DIES"] = "显示“死亡”",
    ["\"DIES\" in red on the health bar when your DoTs will deal at least the mob's health."] =
        "当你的持续伤害足以造成不低于怪物生命值的伤害时，在生命条上显示红色“死亡”。",
    -- DIES place choices (Core.lua: WTF.DIES_PLACES)
    ["Auto"] = "自动",
    ["Left of the bar"] = "生命条左侧",
    ["Right of the bar"] = "生命条右侧",
    ["Center of the bar"] = "生命条中央",
    ["Above the bar"] = "生命条上方",
    ["Below the bar"] = "生命条下方",
    ["Inside the bar's right end"] = "生命条右端内侧",
    ["DIES place: target and focus"] = "“死亡”位置：目标与焦点",
    ["DIES left/right: target and focus"] = "“死亡”左右：目标与焦点",
    ["DIES down/up: target and focus"] = "“死亡”上下：目标与焦点",
    ["DIES place: nameplates"] = "“死亡”位置：姓名板",
    ["DIES left/right: nameplates"] = "“死亡”左右：姓名板",
    ["DIES down/up: nameplates"] = "“死亡”上下：姓名板",
    ["Where DIES shows on your target and focus frames. Auto puts it beside the bar, on a side nothing else "
        .. "uses. Center puts it in the middle of the bar."] =
        "“死亡”在目标与焦点框体上的显示位置。自动：放在生命条旁边，选择没有其他内容占用的一侧；"
            .. "中央：放在生命条中间。",
    ["Moves DIES on your target and focus frames, in pixels: up to 100 left or right."] =
        "以像素为单位左右移动目标与焦点框体上的“死亡”：最多 100。",
    ["Moves DIES on your target and focus frames, in pixels: up to 100 down or up."] =
        "以像素为单位上下移动目标与焦点框体上的“死亡”：最多 100。",
    ["Where DIES shows on nameplates. Auto puts it beside the bar, on a side nothing else uses. Center puts it "
        .. "in the middle of the bar."] =
        "“死亡”在姓名板上的显示位置。自动：放在生命条旁边，选择没有其他内容占用的一侧；中央：放在生命条中间。",
    ["Moves DIES on nameplates, in pixels: up to 100 left or right."] =
        "以像素为单位左右移动姓名板上的“死亡”：最多 100。",
    ["Moves DIES on nameplates, in pixels: up to 100 down or up."] =
        "以像素为单位上下移动姓名板上的“死亡”：最多 100。",
    ["Block fill"] = "区块填充",
    ["Stripes: WTF's diagonal stripes. Solid: one flat color. Bar texture: the texture of the bar it sits on. "
        .. "The same look on the target frame, nameplates, and DoT tracker rows."] =
        "条纹：WTF 的斜纹。实心：单一纯色。条材质：使用所在生命条的材质。"
            .. "目标框体、姓名板和持续伤害追踪行使用相同外观。",
    ["Block color"] = "区块颜色",
    ["The block's color. On a bar of the same color, as a DoT tracker row in the panel's purple, the block is "
        .. "drawn lighter, so it stands out."] =
        "区块的颜色。在颜色相同的生命条上（例如使用框体紫色的持续伤害追踪行），区块会画得更亮，以便区分。",
    ["Block opacity"] = "区块不透明度",
    ["How solid the block is, in percent."] = "区块的不透明度，以百分比表示。",
    ["Block outline"] = "区块描边",
    ["A thin line around the block, a little lighter than its color."] = "区块周围的一圈细线，比区块颜色稍亮。",
    -- Options: DoTs page
    ["Your DoTs in the order the DoT tracker's rows and the nameplate dots show them, the first one on top "
        .. "or at the left. Drag a row up or down to move it. A change made in combat reaches the tracker "
        .. "when combat ends; colors change at once."] =
        "你的持续伤害，按持续伤害追踪行和姓名板圆点的显示顺序排列，第一项在最上方或最左侧。"
            .. "上下拖动行可调整顺序。战斗中的修改会在战斗结束后应用到追踪器；颜色则立即生效。",
    ["On nameplates"] = "姓名板上",
    ["Drag up or down to move %s."] = "上下拖动以移动%s。",
    ["Show a %s dot in the nameplate bubble."] = "在姓名板气泡中显示%s圆点。",
    ["Turn on Show DoT dots on nameplates on the DoT Tracker page to choose the dots."] =
        "请在“持续伤害追踪”页开启“在姓名板上显示持续伤害圆点”，以选择圆点。",
    ["The color of %s on the tracker's bars and on nameplate dots. Click to change it."] =
        "%s在追踪器条形和姓名板圆点上的颜色。点击可更改。",
    ["Reset order"] = "重置顺序",
    -- Options: main page
    ["Soul Shard management"] = "灵魂碎片管理",
    ["Delete Soul Shards that Drain Soul creates above your limit. Shards you move into your bags are never "
        .. "deleted."] =
        "删除吸取灵魂在你超出上限后制造的灵魂碎片。你自己移入背包的碎片永远不会被删除。",
    ["DoT tracker"] = "持续伤害追踪",
    ["A row per mob you DoT, with the time left on your DoTs, Bane, Curse, and Fear."] =
        "每只被你施加持续伤害的怪物一行，显示你的持续伤害、灾祸、诅咒和恐惧剩余时间。",
    ["Control bar"] = "控制条",
    ["Bars for the mobs you Fear or Banish, with their time left, and a Focus box above them with your "
        .. "focus's Fear. Click the Focus box to fear your focus again, or a Banish row to banish your focus "
        .. "again."] =
        "为你恐惧或放逐的怪物显示计时条，并在上方显示带有焦点恐惧的焦点框。点击焦点框可再次恐惧你的焦点，"
            .. "点击放逐行可再次放逐你的焦点。",
    ["Unlock frames to move them"] = "解锁框体以移动",
    ["Outline the Stones bar and the shard counter, so you can drag "
        .. "them; untick to lock them again. /wtf unlock and /wtf lock do the same, and /wtf reset moves "
        .. "them back."] =
        "为石头栏和碎片计数器显示轮廓，以便拖动；取消勾选可重新锁定。"
            .. "/wtf unlock 和 /wtf lock 作用相同，/wtf reset 可将它们移回原位。",
    ["Show a grid while unlocked"] = "解锁时显示网格",
    ["While frames are unlocked, draw a faint grid over the screen with the center lines in red, so you can "
        .. "line frames up."] =
        "解锁框体时，在屏幕上绘制淡淡的网格，中心线为红色，方便对齐框体。",
    -- Commands
    ["Use /wtf, /wtf options, /wtf shards, /wtf stones, /wtf unlock, /wtf lock, /wtf reset, "
        .. "/wtf debug_shards, /wtf debug_delete, "
        .. "/wtf debug_stones, /wtf debug_click, /wtf debug_announce, /wtf debug_emote, or /wtf debug_restrictions."] =
        "使用 /wtf、/wtf options、/wtf shards、/wtf stones、/wtf unlock、/wtf lock、/wtf reset、"
            .. "/wtf debug_shards、/wtf debug_delete、/wtf debug_stones、/wtf debug_click、"
            .. "/wtf debug_announce、/wtf debug_emote 或 /wtf debug_restrictions。",
    ["Warlock Tools Forever is unavailable. Check the WTF login message."] =
        "Warlock Tools Forever 当前不可用。请查看登录时的 WTF 提示。",
    -- Shards
    ["This client lacks %s, so Warlock Tools Forever stays off."] =
        "此客户端缺少 %s，因此 Warlock Tools Forever 保持关闭。",
    ["Soul Shard deletion stopped: %s. It stays off until you /reload."] =
        "已停止删除灵魂碎片：%s。在你输入 /reload 之前不会恢复。",
    ["the client blocked it"] = "客户端拦截了操作",
    ["the cursor did not hold one Soul Shard, so nothing was deleted"] =
        "光标上没有一枚灵魂碎片，因此未删除任何东西",
    ["Deleted a Soul Shard above your limit of %d."] = "已删除一枚超出上限 %d 的灵魂碎片。",
    ["No Soul Shards above your limit of %d."] = "没有超出上限 %d 的灵魂碎片。",
    ["Soul Shards above your limit go after combat."] = "超出上限的灵魂碎片会在战斗结束后删除。",
    ["Deleting %d Soul Shards above your limit of %d, one per key press or click."] =
        "正在删除 %d 枚超出上限 %d 的灵魂碎片，每按一次键或点击一次删除一枚。",
    ["The game does not let AddOns delete items in this dungeon. "
        .. "Shards above your limit go when you leave it."] =
        "游戏不允许插件在此副本中删除物品。超出上限的灵魂碎片会在你离开副本后删除。",
    ["Right-click: delete shards above your limit (none now)"] =
        "右键：删除超出上限的灵魂碎片（现在没有）",
    ["Right-click: delete 1 shard above your limit"] = "右键：删除 1 枚超出上限的灵魂碎片",
    ["Right-click: delete %d shards above your limit"] = "右键：删除 %d 枚超出上限的灵魂碎片",
    ["%T is the target's full name and %Z your zone. Press Enter to keep an edit, Escape to undo it. "
        .. "Nothing is sent for yourself or for a cast that fails. The Fear and Banish announcements moved "
        .. "to Dyre's Debuff Tracker (the Control page)."] =
        "%T 是目标的全名，%Z 是你的区域。按回车保存修改，按 Esc 撤销。对自己施放或施放失败时不会发送任何"
            .. "消息。恐惧与放逐的通报已移到 Dyre's Debuff Tracker（控制页）。",
    ["Drain Soul was not found, so Soul Shard deletion stays off. Run /wtf debug_shards."] =
        "未找到吸取灵魂，因此灵魂碎片删除保持关闭。可运行 /wtf debug_shards。",
    ["%d of %d (%s limit)"] = "%d / %d（%s）",
    ["your soul bag size"] = "灵魂袋容量",
    ["the default without a soul bag"] = "无灵魂袋时的默认值",
    ["set by you"] = "你设定的上限",
    ["Drag to move. /wtf reset moves it back."] = "拖动可移动。输入 /wtf reset 可移回原位。",
    ["Soul Shards: %d carried, limit %d (%s). Deletion is %s."] =
        "灵魂碎片：携带 %d 枚，上限 %d（%s）。删除功能：%s。",
    ["on"] = "开启",
    ["off"] = "关闭",
    ["stopped until /reload (%s)"] = "已停止，直到 /reload（%s）",
    -- Stones
    ["No free character macro slot for \"%s\"; free one and WTF adds it."] =
        "没有空余的角色宏栏位给“%s”；请腾出一个，WTF 会自动添加。",
    ["The game did not let WTF put the Healthstone into the trade window; drag it in yourself."] =
        "游戏不允许 WTF 把治疗石放入交易窗口；请手动拖进去。",
    ["Healthstone in the trade window. Press Trade to give it."] =
        "治疗石已放入交易窗口。点击“交易”交给对方。",
    ["No Healthstone in your bags. Right-click to create one."] = "背包里没有治疗石。右键点击可制造一个。",
    ["You do not know Create Soulstone yet."] = "你还没有学会制造灵魂石。",
    ["You already carry every Healthstone rank you can make here."] =
        "你已经携带了当前能制造的所有等级的治疗石。",
    ["You do not know Create Healthstone yet."] = "你还没有学会制造治疗石。",
    ["Soulstones cannot be applied in combat."] = "战斗中无法施加灵魂石。",
    ["No Soulstone in your bags. Right-click to create one."] = "背包里没有灵魂石。右键点击可制造一个。",
    ["a stone"] = "一块石头",
    ["Soulstone"] = "灵魂石",
    ["Healthstone"] = "治疗石",
    ["Left-click: trade %s to your target."] = "左键：把 %s 交易给目标。",
    ["Left-click: create a Healthstone your target can use, then left-click again to trade it."] =
        "左键：制造一块目标能使用的治疗石，再左键点击进行交易。",
    ["Left-click: use %s on your friendly target, or on yourself."] = "左键：对友方目标或你自己使用 %s。",
    ["Left-click: use %s."] = "左键：使用 %s。",
    ["Left-click: you carry none."] = "左键：你没有携带。",
    ["In combat: the button uses this Healthstone when the fight ends."] =
        "战斗中：等战斗结束，按钮才会用上这块治疗石。",
    ["Right-click: create %s."] = "右键：制造 %s。",
    ["Right-click: create %s, the best your friendly player target can use."] =
        "右键：制造 %s，即友方玩家目标能使用的最高等级。",
    ["Right-click: you already carry every rank you can make here."] = "右键：你已经携带了当前能制造的所有等级。",
    ["Right-click: you know no rank yet."] = "右键：你还没有学会任何等级。",
    ["Middle-click: use your best Healthstone on yourself."] = "中键：对自己使用最好的治疗石。",
    ["For your action bars: the \"%s\" macro in your character macros does the same, also in combat."] =
        "动作条可用：角色宏中的“%s”宏效果相同，战斗中也可用。",
    ["No Soulstone is up. Left-click the Soulstone button to apply one."] =
        "当前没有灵魂石。左键点击灵魂石按钮施加一个。",
    ["No Soulstone is up. Right-click the Soulstone button to create one."] =
        "当前没有灵魂石。右键点击灵魂石按钮制造一个。",
    ["You carry no Healthstone. Right-click the Healthstone button to create one."] =
        "你没有携带治疗石。右键点击治疗石按钮制造一个。",
    ["Your Soulstone on %s has ended."] = "你施加在 %s 身上的灵魂石已结束。",
    ["Soulstone on %s, %d min left."] = "%s身上的灵魂石还剩 %d 分钟。",
    ["No Soulstone is up."] = "当前没有灵魂石。",
    ["You carry %d Soulstone(s) and %d Healthstone(s)."] = "你携带了 %d 块灵魂石和 %d 块治疗石。",
    ["Stones stay off: this client lacks %s."] = "石头栏保持关闭：此客户端缺少 %s。",
    ["Stone macros stay off: this client lacks %s."] = "石头宏保持关闭：此客户端缺少 %s。",
    -- Tracker
    ["The DoT tracker stays off: this client lacks %s."] = "持续伤害追踪保持关闭：此客户端缺少 %s。",
    -- Control
    ["Fear (sample)"] = "恐惧（示例）",
    ["Banish (sample)"] = "放逐（示例）",
    ["Click: %s your focus again."] = "点击：再次对焦点施放 %s。",
    ["No marker and no target change. With no focus it does nothing."] =
        "不会标记，也不会改变目标。没有焦点时不起作用。",
    ["Banish your focus (\"! Banish\"), then click its row to cast it again."] =
        "先对你的焦点施放放逐（“! Banish”），然后点击它的行再次施放。",
    ["Your Fears and Banishes show here with their time left."] = "你的恐惧和放逐会在这里显示剩余时间。",
    ["The control bar stays off: this client lacks %s."] = "控制条保持关闭：此客户端缺少 %s。",
    ["Focus check reset. "] = "焦点检测已重置。",
    ["Focus check reset for every Dyre's AddOn."] = "已为所有 Dyre 插件重置焦点检测。",
    ["Focus detection reset for every Dyre's AddOn: it is learned again the first time you set a focus."] =
        "已为所有 Dyre 插件重置焦点检测：下次设置焦点时会重新检测。",
    ["WTF's macros try your focus, then the mob under the mouse, then your target, until a focus is seen to work."] =
        "WTF 的宏会先尝试你的焦点，然后鼠标指向的怪物，最后是你的目标，直到检测到焦点可用。",
    ["Fear"] = "恐惧",
    ["Banish"] = "放逐",
    ["Enslave Demon"] = "奴役恶魔",
    ["Howl of Terror"] = "恐惧嚎叫",
    ["Star"] = "星形",
    ["Circle"] = "圆形",
    ["Diamond"] = "菱形",
    ["Triangle"] = "三角形",
    ["Moon"] = "月亮",
    ["Square"] = "方形",
    ["Cross"] = "十字",
    ["Skull"] = "骷髅",
}

-- The client's own spell name, so a spell reads as the game names it (zhCN
-- names on a zhCN client); nil when the client cannot answer.
function WTF.SpellName(spellID)
    if type(C_Spell) == "table" and type(C_Spell.GetSpellName) == "function" then
        local name = C_Spell.GetSpellName(spellID)
        if type(name) == "string" and name ~= "" then
            return name
        end
    end
end

-- The client's own item name (Healthstone, Soulstone, ...).
function WTF.ItemName(itemID)
    if type(C_Item) == "table" and type(C_Item.GetItemNameByID) == "function" then
        local name = C_Item.GetItemNameByID(itemID)
        if type(name) == "string" and name ~= "" then
            return name
        end
    end
end

function WTF.T(text, context)
    if type(text) ~= "string" or WTF.L ~= zhCN then
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
