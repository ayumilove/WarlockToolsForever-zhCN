# WoW Forever 术士助手（zhCN 汉化增强版）

魔兽世界：无限（WoW Forever）可用的术士工具插件汉化增强包。基于 Dyre 的
[WarlockToolsForever](https://github.com/jbedworth/WarlockToolsForever) v1.12.2，
界面与通报已汉化，并增强了灵魂石与治疗石的使用体验。

非官方汉化版，与原作者无隶属关系；原版功能与代码版权归 Dyre（John Bedworth），
MIT 许可，各插件目录内附原始 LICENSE。

## 重要变化（1.11.0 起）

持续伤害追踪（含姓名板圆点、伤害预测、智能诅咒）与控制条（宏、恐惧/放逐通报）
已由上游移到 **Dyre's Debuff Tracker**。本包里的 WTF 设置页会保留原来的
“持续伤害追踪 / 持续伤害 / 控制”位置，点进去直接打开 DDT 的设置。
因此 **DyresDebuffTracker 现在是必需依赖**。DDT 本身未汉化（按范围要求不改
Dyre 插件），它的设置页保持英文。

## 包含内容

| 文件夹 | 版本 | 说明 |
| --- | --- | --- |
| `WarlockToolsForever/` | 1.12.2-fork.1 | 汉化增强版：碎片管理（含右键裁剪）、石头按钮、团队通报 |
| `DyresToolkit/` | 2.12.0 | **必需依赖**：配置档案、布局、小地图菜单、仇恨提示；未改动 |
| `DyresDebuffTracker/` | 1.5.0 | **必需依赖**：持续伤害追踪、姓名板圆点、伤害预测、智能诅咒、控制条；未改动 |
| `DyresShieldsUp/` | 1.5.0 | 可选：护盾剩余量新月条；未改动 |
| `DyresBuffReminders/` | 1.13.1 | 可选：职业增益提醒、冷却与触发提示；未改动 |

## 安装

1. 下载本仓库（Code → Download ZIP）。
2. 把上面五个文件夹整个放进：
   `World of Warcraft/_forever_/Interface/AddOns/`
3. 进入游戏，或输入 `/reload`。插件列表里确认五个插件都已启用。

`DyresToolkit` 与 `DyresDebuffTracker` 必须保留；另外两个 Dyre 插件只在你想要
对应功能时装。Dyre 插件都保持独立文件夹，可以从 CurseForge 照常更新。

## 与原版 WarlockToolsForever 的差异

汉化：

- 界面、选项、通告、提示全部中文；专有名词与 Forever 中文客户端一致。
- 宏名（`! Healthstone` 等）、斜杠命令与调试输出保持英文，便于脚本引用。
- 中文文案为魔女口吻，不含插件署名。

增强（`X-WTF-Fork: 1.12.2-fork.1`）：

- **给自己绑灵魂石不再通报**，也不再提示“你的灵魂石已结束”；`/wtf stones`
  仍可查看自己灵魂石的剩余时间。不会再覆盖已给其他玩家的灵魂石记录。
- **灵魂石时限按 Forever 的 2 小时**计算（原版按 30 分钟，会误报）。
- **治疗石/灵魂石按钮即时刷新**：施法成功、背包与冷却变化时立刻更新，
  不再等战斗结束才显示。
- **携带状态一目了然**：有石头时显示实际携带的最高等级图标、金色数量；
  没有时图标去色并叠加红叉、数量红色 `0`、红边框。
- **共享冷却可见**：用掉任意等级的治疗石后，按钮显示冷却转圈与剩余秒数。
- **数量变化闪动**：制造或使用后按钮闪一下，变化一眼可见。
- 战斗中安全按钮仍要等脱战；此时悬停会提示“战斗中：等战斗结束，按钮才会
  用上这块治疗石”。
- **碎片计数器右键裁剪**：一键删除超出上限的灵魂碎片；副本内被游戏拒绝时
  改为离开副本后补删（上游 1.12 功能，已汉化）。
- 1.12.2 上游功能全部保留。

以前的 fork 增强里，属于持续伤害追踪与控制条的部分（DoT/放逐快结束提示、
追踪条“目标/焦点”标签、点名字选怪、悬停金线、追踪条本地化）已随功能一起
移到 Dyre's Debuff Tracker；DDT 未汉化、也没有这些提醒，按范围要求没有移植。

## 更新与兼容

- 客户端：Forever（Interface 16001），简体中文客户端。
- `## Version` 保持与上游一致的 `1.12.2`，只用 `X-WTF-Fork` 标记本版本，
  避免被当成新版本反复覆盖。
- **不要用 CurseForge 更新 `WarlockToolsForever`**，会覆盖回英文原版。
  上游发新版时，以新上游为准重新合并汉化。
- `DyresToolkit`、`DyresDebuffTracker`、`DyresShieldsUp`、`DyresBuffReminders`
  未改动，可以照常通过 CurseForge 更新。
- SavedVariables 不受覆盖影响，配置不会丢失；1.11.0 起旧的追踪/控制设置
  由 DDT 一次性读取，WTF 只原样保留、不修改。

## 许可

MIT License，见各插件目录内的 `LICENSE`。
