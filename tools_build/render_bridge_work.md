# 渲染桥核心：Unity 对象图 → Flixel 显示列表（工作包 ①）—— 执行记录

> 分段落盘，边做边写。姊妹笔记：`ui_render_findings.md`（uGUI 层）、`sprite_pipeline_work.md`
> （unity.Sprite → FlxFrame）、`black_screen_report.md`（黑屏量化验证）。

## 0. 开工时的实际状态（2026-10-05 19:50，与任务描述有差异）

任务描述说「`unity` 包整包只有 13 处 FlxSprite/addChild 引用、渲染桥整体缺失」。实测
**并行 agent 已落地两个半边**：

| 半边 | 文件 | 状态 |
|---|---|---|
| `unity.Sprite` → `FlxFrame`/`FlxImageFrame` | `source/mvz2/sprites/SpriteFrameFactory.hx`（19:42） | 已打通 |
| `SpriteRenderer.sprite` → `renderSprite:FlxSprite` | `source/unity/SpriteRenderer.hx`（19:21） | 已接线（setter 钩子） |
| uGUI 树 → Flixel 显示列表 | `source/mvz2/ui/UiRenderer.hx`（19:40，905 行） | 已接线（`MainSceneState:41` install） |
| **`unity.Camera` → `FlxCamera`** | — | **完全未做**（`Camera.hx` mtime 10-01 22:08） |
| **`SetCameraBackgroundColor` 真正改底色** | — | **未做**（`backgroundColor` 是裸字段，无消费者） |
| **Unity/Flixel Y 轴换算** | — | **未做**（`ScreenToWorldPoint` 把屏幕 y 当世界 y） |
| **sortingLayer 名字↔ID 表** | `source/unity/SortingLayer.hx` | **只有 "Default"**，14 个工程层全部落到 0 |
| **`Destroy` 从显示列表移除** | `source/unity/UnityObject.hx:37` | 只置 `destroyed=true`，不从父级 children 摘除 |
| **嵌套 Transform 的世界坐标** | `source/unity/Transform.hx:8` | `position` 是**裸字段**，从不按父级级联 |

所以本工作包聚焦上面 5 项**未被覆盖**的部分（全部落在 `source/unity/`，不与并行 agent 冲突）。

## 1. 设计

### 1.1 依赖方向：unity 包不反向依赖 mvz2

沿用姊妹工作包确立的**钩子**模式（`SpriteRenderer.spriteApplier`）。本工作包新增的
`unity.RenderBridge` 只在 unity 包内活动，用 `FlxG.signals.preUpdate` 驱动每帧同步，
**不需要任何外部文件调用 `install()`**（避免与正在被并行编辑的 `MainSceneState` 抢文件）。

### 1.2 各文件职责

| 文件 | 改动 |
|---|---|
| `source/unity/Camera.hx` | 相机注册表；`backgroundColor` 改为属性并**真正写 `FlxG.cameras.bgColor`**；`ScreenToWorldPoint`/`WorldToScreenPoint`/`ViewportToWorldPoint` 按 Y 翻转 + 正交尺寸换算 |
| `source/unity/SortingLayer.hx` | 按 `ProjectSettings/TagManager.asset` 注册 20 个工程排序层（含 signed int32 的 uniqueID），`NameToID`/`IDToName`/`GetLayerValueFromID` 语义对齐 Unity |
| `source/unity/Transform.hx` | `position` 改为**世界坐标**（按父级 lossyScale/position 级联），与 Unity 语义一致 |
| `source/unity/UnityObject.hx` | `destroy` 递归标记子树 + 从父级 children 摘除（显示列表据此淘汰） |
| `source/unity/RenderBridge.hx` | **新增**：把 `SpriteRenderer.renderSprite` 的 scale/flip/visible 按 `transform.lossyScale` 每帧同步（补上 `UiRenderer` 读 `target.scale` 却没人写它的缺口） |
| `source/unity/GameObject.hx` | `AddComponent` 时把 `SpriteRenderer` 登记进 RenderBridge |

### 1.3 坐标系（Unity ↔ Flixel）

```
Unity 屏幕：原点左下角，y 向上          Flixel 屏幕：原点左上角，y 向下
ppu = FlxG.height / (2 * orthographicSize)          （正交相机）
ScreenToWorldPoint(p) : x = camX + (p.x - w/2)/ppu ; y = camY + (h/2 - p.y)/ppu
WorldToScreenPoint(p) : x = w/2 + (p.x - camX)*ppu ; y = h/2 - (p.y - camY)*ppu
```

**注意**：`unity.Input.mousePosition` 的 shim 返回的是 **Flixel 风格（y 向下）** 的
`FlxG.mouse.screenX/screenY`，而 Unity 的 `Input.mousePosition` 是 y 向上。
因此 `ScreenToWorldPoint` 按「输入 y 向下」实现，才能与 shim 的指针位置端到端自洽
（见 `Camera.hx` 的 PORT-NOTE）。**不改 `Input.hx`**：那属输入工作包，且改动会波及其它消费者。

## 2. 进度

- [x] §2.1 `RenderBridge.hx`（新增）
- [x] §2.2 `Camera.hx`（FlxCamera 桥 + 底色 + Y 翻转）
- [x] §2.3 `SortingLayer.hx`（20 层注册表）
- [x] §2.4 `GameObject.hx`（AddComponent 登记渲染器）
- [x] §2.5 `UnityObject.hx`（destroy 摘除子树）
- [x] §2.6 `verify/renderbridge/RenderBridgeSmokeMain.hx` + `tools_build/check_render_bridge.sh`
- [x] §2.7 neko 类型检查（`include('unity')` 与全覆盖均 **exit 0**）
- [ ] §2.8 cpp 冒烟测试（进行中）
- [ ] §2.9 构建 + 运行 + 截图 + 像素统计

## 3. 决策记录

### 3.1 `Transform.position` 保持"裸字段"（不改世界坐标语义）

Unity 的 `Transform.position` 是**世界坐标**，而 shim 里是普通字段（`localPosition` 的别名），
从不按父级级联。看起来该改，但实测风险很高：

- 全仓有 **57 处** `transform.position` 读写，覆盖 `EntityController`（实体世界位置）、
  `LevelCamera`（把相机摆到 `CameraPosition + offset - viewportCenter`）、
  `ModelGroup`、`HPBarCanvasController`、`Conveyor` 等**关卡/模型**链路；
- 这些链路的父级 `Transform` 通常**没有** localScale（`MainGameScene` 的 `child()` 建的都是
  单位变换），因此"级联"对它们**恒等**；而一旦某个父级带非单位缩放（如 `Mainmenu` 的
  `Ceiling` 是 `scale=16`），级联会把已经手算好的世界坐标**再乘一遍**，直接把画面打飞。
- 移植层已有的约定是"position 由调用点自己算好"（见 `LevelCamera.UpdatePosition`、
  `ModelPrefabLoader` 只写 `localPosition`）。

**结论**：保持裸字段，另加**只读**的 `Transform.WorldPosition`（按父级 lossyScale/position
级联）供渲染层按需使用。属**保守选择**：不动 57 处调用点的语义，把风险留给专门的
「关卡/模型坐标回归」工作包（已记入 §4 未完成项）。

### 3.2 `ScreenToWorldPoint` 的 y 方向：按"输入 y 向下"

`unity.Input.mousePosition` 的 shim 返回 `FlxG.mouse.screenX/screenY`（**Flixel 风格，y 向下**），
而 Unity 的 `Input.mousePosition` 是 y 向上。调用链是
`Input.mousePosition → InputHelper.GetPointerPosition → MapController.ScreenToWorldPoint`。
为了让**整条链**自洽，`ScreenToWorldPoint` 按"输入 y 向下"实现（x 两种约定相同）。
这与 `mvz2.ui.UiRenderer` 的 `y = FlxG.height*0.5 - (pos.y-origin.y)*scale` 是同一方向约定。
**没有改 `Input.hx`**（属输入工作包，会波及其它消费者）。

### 3.3 `sortingLayerName` ↔ `sortingLayerID` 双向收敛放在 `RenderBridge.syncOne`

`ScenePrefabFieldApplier` 只能按 prefab 数据写 `sortingLayerID`（Unity 序列化的就是它，实测
602 处、`sortingLayerName` 0 处），而 C# 代码路径写的是 `sortingLayerName`。
Unity 里两者是同一份数据的两种视图，因此在 `RenderBridge.syncOne` 里收敛：
名字非 Default 时以名字为准，否则以 ID 为准。这样 `UiRenderer.stableSortWorldSprites`
（按 ID 排序）与 `SpriteRenderer.sortingLayerName` 的读取者都拿到一致值。

实测数据（`Prefabs/Mainmenu/Mainmenu.json`）：`sortingLayerID` 分布为
`0: 28 个`、`-2057763135 (Background): 8 个`、`-2092243167 (BackUI): 1 个`。
其中 `WindowView` 用 BackUI（层级序号 7），必须排在 Background（序号 0）**之后** ——
这正是 `UiRenderer` 里那条"不排序会盖住背景"的注释所指的问题，现已可解。

### 3.4 相机不自建 `FlxCamera`

一个 Unity 场景里有 17 个 Camera 对象（`scenes/Main.json` 实测）。各自建一个 FlxCamera
会叠加出多层绘制。移植层沿用 Flixel 的**单一默认相机**，把 Unity 相机的正交参数
映射成"每世界单位多少像素"（`Camera.pixelsPerUnit()`）与 `FlxG.cameras.bgColor`。
`mvz2.ui.UiRenderer` 已经在用同一套（它自己 `FlxG.height / (orthographicSize*2)`），
因此两边换算一致。
