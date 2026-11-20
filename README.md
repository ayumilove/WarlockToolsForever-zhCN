# WoW Forever 术士助手（zhCN 汉化增强版）

魔兽世界：无限（WoW Forever）可用的术士工具插件汉化增强包。基于 Dyre 的
[WarlockToolsForever](https://github.com/jbedworth/WarlockToolsForever) v1.9.0，
界面与通报已汉化，并修复/增强了灵魂石与治疗石按钮的使用体验。

非官方汉化版，与原作者无隶属关系；原版功能与代码版权归 Dyre（John Bedworth），
MIT 许可，各插件目录内附原始 LICENSE。

## 包含内容

| 文件夹 | 版本 | 说明 |
| --- | --- | --- |
| `WarlockToolsForever/` | 1.9.0-fork.1 | 汉化增强版：碎片管理、石头按钮、持续伤害追踪、控制条、团队通报 |
| `DyresToolkit/` | 2.10.3 | **必需依赖**：配置档案、布局、小地图菜单、仇恨提示；未改动 |
| `DyresShieldsUp/` | 1.3.0 | 可选：护盾剩余量新月条；未改动 |
| `DyresBuffReminders/` | 1.12.1 | 可选：职业增益提醒、冷却与触发提示；未改动 |

## 安装

1. 下载本仓库（Code → Download ZIP）。
2. 把上面四个文件夹整个放进：
   `World of Warcraft/_forever_/Interface/AddOns/`
3. 进入游戏，或输入 `/reload`。插件列表里确认四个插件都已启用。

需要 Dyre's Toolkit 的配置档案时，`DyresToolkit` 必须保留；另外两个 Dyre 插件
只在你想要对应功能时装。

## 与原版 WarlockToolsForever 的差异

汉化：

- 界面、选项、通告、提示全部中文；专有名词与 Forever 中文客户端一致。
- 宏名（`! Healthstone` 等）、斜杠命令与调试输出保持英文，便于脚本引用。
- 中文文案为童话口吻，不含插件署名。

增强（`X-WTF-Fork: 1.9.0-fork.1`）：

- **给自己绑灵魂石不再通报**，也不再提示"你的灵魂石已结束"；`/wtf stones`
  仍可查看自己灵魂石的剩余时间。不会再覆盖已给其他玩家的灵魂石记录。
- **灵魂石时限按 Forever 的 2 小时**计算（原版按 30 分钟，会误报）。
- **治疗石/灵魂石按钮即时刷新**：施法成功、背包与冷却变化时立刻更新，
  不再等战斗结束才显示。
- **携带状态一目了然**：有石头时显示实际携带的最高等级图标、金色数量；
  没有时图标去色并叠加红叉、数量红色 `0`、红边框。
- **共享冷却可见**：用掉任意等级的治疗石后，按钮显示冷却转圈与剩余秒数。
- **数量变化闪动**：制造或使用后按钮闪一下，变化一眼可见。
- 战斗中安全按钮仍要等脱战；此时悬停会提示"战斗中：等战斗结束，按钮才会用上这块治疗石"。

## 更新与兼容

- 客户端：Forever（Interface 16001），简体中文客户端。
- `## Version` 保持与上游一致的 `1.9.0`，只用 `X-WTF-Fork` 标记本版本，
  避免被当成新版本反复覆盖。
- **不要用 CurseForge 更新 `WarlockToolsForever`**，会覆盖回英文原版。
  上游发新版时，以新上游为准重新合并汉化。
- `DyresToolkit`、`DyresShieldsUp`、`DyresBuffReminders` 未改动，
  可以照常通过 CurseForge 更新。
- SavedVariables 不受覆盖影响，配置不会丢失。

## 许可

MIT License，见各插件目录内的 `LICENSE`。
