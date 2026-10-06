# 工作包 ② 关卡/UI prefab 序列化数据管线 —— 执行记录（2026-10-05）

> 分段落盘。上游调查（现状/优先字段真值/转换器）见 `scene_pipeline_findings.md`，
> 本文件记录**本轮实际改动与验证**。

## 0. 开工时的实际状态（与任务描述的差异，重要）

任务描述说「`MainSceneUI.dialog` 空引用导致启动崩在 `MainSceneUI.hx:32`」。实测**该处已被启动链路
agent 用「手写对象图」修掉了**（`boot_findings.md` §一.9~14，`MainGameScene.buildDialog()` 等）：

- release 标准构建（`export/windows/bin/MVZ2.exe`）在隔离目录运行：exit **139**，boot-trace
  27013 行，末行 `无法读取用户0的MODmvz2的存档或任何备份，创建一个新存档。`
- debug 构建（`tools_build/verify_startup`）显示真实崩点已推进到
  `MVZ2SaveExt.IsNullOrMeetsConditions (MVZ2SaveExt.hx:12) Object does not implement interface`
  —— 即任务里说的**工作包①**（属性注册表缺失），不是 prefab 数据。

**所以本工作包的产出重点调整为**：
1. 让 prefab 数据管线**真正跑通**（`ScenePrefabLoader.InstantiateScene` 目前**段错误**，见 §2）；
2. 把「手工构造对象图」与「prefab 数据注入」接上，给出可复用注入入口；
3. 对**仍无数据来源**的字段给出安全兜底并列出清单（§4）。

## 1. 现状核查（逐条对 C# 源）

`tools_build/build_scene.py` 的导出与 `Assets/Scripts/**` 逐字段对照：

| 类 | C# `[SerializeField]` | 导出数据 | 结论 |
|---|---|---|---|
| `MVZ2.Grids.GridController` | `view`, `size` | `view`,`size`,`hpBarView` | ✅ 一致（`size=(0.8,0.8)`） |
| `MVZ2.UI.Scene.MainSceneUI` | `tooltip`,`dialog`,`blackscreenImage`,`screenCoverFader`,`debugConsoleIcon` | 同 5 个 | ✅ 一致 |
| `MVZ2.Cameras.LevelCamera` | `_viewportTransform`,`_camera`,`cameraAnchor`,`cameraPosition` | 同 4 个 | ✅ 一致 |
| `MVZ2.UI.DragMover` | `dragTarget` | `dragTarget` | ✅ |
| `MVZ2.UI.Level.HintArrow` | `updatesPosition`,`targetTransform`,`targetOffset` | 同 3 个 | ✅ |
| `MVZ2.UI.Level.LevelUIPreset` | 52 个（含 8 个 hintArrow offset/angle） | 同 52 个 | ✅ |
| `MVZ2.Models.LightController` | `lightRenderer`,`shakeRange` | 同 2 个 | ✅ |
| `MVZ2.UI.Level.ClassicBlueprintSet` | `slots`,`offset`,`cellSize`,`alignSpeed` | 脚本名不出现（抽象类） | ⚠️ 真值在子类节点上（§4.1） |

字段名与 C# 原名**一一对应**（`build_scene.py` 只对 Unity 内置组件做 `m_*` → API 属性名投影，
工程内脚本走 `bm._generic_fields` 原样保留）。运行期注入不需要名字映射。

### 1.1 新增静态校验器（本轮产出）

- `tools_build/check_scene_fields.py`：`@:serializeField` 字段的**数据/初值/C# 声明**三方对照。
  实测：891 个字段，**有数据 841**、无数据但已零初始化 5、无数据但有初值 31、无数据且无初值 14。
- `tools_build/check_scene_apply.py`：离线复刻 `ModelPrefabContext.decode` +
  `ScenePrefabFieldApplier` 的判定，对 146410 条字段记录做**可写性**检查，
  找出「数据形态与 Haxe 字段声明类型不匹配」的组合（运行期会崩或写错类型）。

## 2. 阻断点：`ScenePrefabLoader.InstantiateScene("Level")` 段错误（已定位）

`bash tools_build/check_scene.sh --cpp` 基线：

```
dataPath=assets
manifest: version=1 场景=2 prefab=147
-- Prefabs/Level/Grid --
-- 场景 Level --
Segmentation fault        ← exit 139
```

debug 构建（`-debug`，`HXCPP_CHECK_POINTER` 让空引用变成可捕获异常）拿到精确调用链：

```
Called from scenes.ScenePrefabSmokeMain::main line 63
Called from scenes.ScenePrefabSmokeMain::checkSceneLevel line 113
Called from mvz2.scenes.ScenePrefabLoader::InstantiateScene line 142
Called from mvz2.scenes.ScenePrefabLoader::InstantiateKey line 159
Called from mvz2.scenes.ScenePrefabLoader::InstantiateData line 245
Called from mvz2.scenes.ScenePrefabFieldApplier::Apply line 70
Called from mvz2.scenes.ScenePrefabFieldApplier::setField line 158
Called from Reflect::callMethod
Called from unity.tmpro.TMP_Dropdown::set_options line 16
Called from unity.tmpro.TMP_Dropdown::SetupOptions line 55
Error : Null Object Reference
```

**根因（第一处）**：Unity 把 `TMP_Dropdown.m_Options` 序列化成 `{m_Options:[{m_Text,m_Image}]}`，
而 shim 的 `options` 属性 setter 期望 `Array<TMP_OptionData>`：
`set_options(v)` 收到匿名对象 → `SetupOptions(v, value)` → `v.copy()` 空引用。

`check_scene_apply.py` 在**转换期**一次性找出同类问题共 **3832 条 / 38 种**（§3），
不再需要「编译 18 分钟 → 崩 → 再编译」逐处试。

## 3. 静态校验器找出的 38 种形态不匹配（全部在运行期会崩或写错类型）

| # | 脚本.字段 | 声明类型 | 数据形态 | 次数 | 归一化 |
|---|---|---|---|---|---|
| 1 | `UI.Button.colors` / `Toggle.colors` / `Slider.colors` / `Scrollbar.colors` / `TMP_Dropdown.colors` / `TMP_InputField.colors` | `ColorBlock` | `{m_NormalColor,...}` | 812 | → `ColorBlock` 实例，逐色写 |
| 2 | `UI.Button.spriteState` / `Toggle.spriteState` | `SpriteState` | `{m_HighlightedSprite,...}` | 614 | → `SpriteState` 实例 |
| 3 | `UI.Button.navigation` / `Toggle` / `Slider` / `Scrollbar` / `TMP_Dropdown` / `TMP_InputField` | `Navigation` | `{m_Mode,m_WrapAround,...}` | 801 | → `Navigation` 实例（`m_Mode` → `mode`） |
| 4 | `LayoutGroup.padding`（V/H/Grid） | `RectOffset` | `{m_Left,m_Right,m_Top,m_Bottom}` | 891 | → `RectOffset` 实例 |
| 5 | `MVZ2.Audios.SoundPlayer.soundID` | `NamespaceIDReference` | `{spacename,path}` | 471 | → 逐字段写 |
| 6 | `GraphicRaycaster.blockingMask` | `unity.LayerMask` | int | 114 | → `new LayerMask(int)` |
| 7 | `UIModel.onDelayedDestroy` / `AreaModel.onDelayedDestroy` | `UnityEvent` | `{m_PersistentCalls:{m_Calls:[]}}` | 72 | → 保持声明初值（事件不由 prefab 驱动） |
| 8 | `TMP_Dropdown.options` | `Array<TMP_OptionData>` | `{m_Options:[{m_Text,m_Image}]}` | 19 | → 数组（**首崩点**） |
| 9 | `LevelUIBlueprints.battleSortingLayer` / `choosingSortingLayer` | `SortingLayerPicker` | `{id:int}` | 14 | → `new SortingLayerPicker(id)` |
| 10 | `DebugConsoleInputField.m_On*`（7 个事件字段） | `SubmitEvent` 等 | `{m_PersistentCalls:...}` | 21 | → 保持声明初值 |
| 11 | `MVZ2.Cursors.CursorManager.cursorDatas` | `Array<CursorData>` | 数组元素是无标记 dict | 3 | 元素是纯数据类，`decode` 造匿名对象 —— 需逐字段写（§5 待办） |
| 12 | `PerformanceManager.animatorBatchData` | `PerformanceData` | 无标记 dict | 3 | 同上（启动链路已自行 `new PerformanceData()`） |
| 13 | `LevelController.cameraMoveCurve` | `AnimationCurve` | `{m_Curve:[{time,value}]}` | 2 | → 关键帧数组 |
| 14 | `LevelBlueprintController.id` / `LevelBlueprintChooseController.id` | `NamespaceIDReference` | `{spacename,path}` | 4 | → 逐字段写 |
| 15 | `RawImage.uvRect` | `Rect` | `{x,y,width,height}` | 2 | → `new Rect(...)` |

**已在 `ScenePrefabFieldApplier.normalize()` 里实现 1~11、13~15 的归一化**（本轮改动）。

### 3.1 类型检查

改完两轮：

```
neko： [CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0   exit 0
cpp ： [CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0   exit 0
```

## 4. 本轮改动清单

### 4.1 `source/mvz2/scenes/ScenePrefabFieldApplier.hx`（核心）

新增 `normalize(raw, current)`：把 Unity 序列化的子结构 dict 归一化成 shim 的类实例
（ColorBlock / SpriteState / Navigation / RectOffset / LayerMask / Rect / TMP_OptionData 数组 /
SortingLayerPicker / AnimationCurve / NamespaceIDReference），UnityEvent 家族保持声明初值。
`Apply` 与 `applyNested` 都在 `decode` 之前调用它。

### 4.2 `source/mvz2/scenes/ScenePrefabInjector.hx`

新增 `ApplyTree(root, prefabKey)`：把导出的节点表按**名字层级**灌进**已存在的**对象图，
并把数据里的 `{n,c}` 引用**重映射到运行期对象**。这是「手工构造对象图」（`MainGameScene`）
与 prefab 数据之间的桥 —— 场景转换正式接入前的过渡手段，也是 `states/` 之外唯一需要的入口。
新增诊断：`unmatchedNodes` / `missingFields`。

### 4.3 优先字段的安全兜底（避免零值/空引用传播）

| 文件 | 字段 | 兜底 |
|---|---|---|
| `mvz2/grids/GridController.hx` | `size` | 新增 `DEFAULT_SIZE=0.8` + `ensureSize()`：优先 `ScenePrefabInjector.ApplyGridSize`，取不到用常量。在 `UpdateGridController` / `TransformWorld2ColliderPosition` 入口调用（除零点之前）。同时 `Awake` 里对 `view` 做同对象兜底解析 |
| `mvz2/grids/LaneController.hx` | 格子模板 | `InitGrids` 在 `grid.Init()` 前调 `GridController.ensureSize(grid)` |
| `mvz2/models/LightController.hx` | `lightRenderer` | `SetColor` / `UpdateLight` 前从子节点取 `SpriteRenderer`（prefab 里指向 `Light/Light` 子节点） |
| `mvz2/map/MapElement.hx` | `button` | `Awake` 里 `GetComponentInChildren(MapElementButton, true)` 兜底（C# 里该字段可空，`button.Exists()` 才订阅） |
| `mvz2/ui/map/MapButton.hx` | `animatorComponent` | `UpdatePointer` 里按 Unity 语义从同一 GameObject 取 `Animator`（C# 读的是 `Selectable.animator`，prefab 里同节点挂着 Animator） |

## 5. 运行期验证

### 5.1 冒烟自检 `verify/scenes/ScenePrefabSmokeMain.hx`

```
haxe -cp source -cp verify -lib flixel ... -main scenes.ScenePrefabSmokeMain -lib hxcpp -cpp /tmp/scene_smoke2
（cwd 下建 assets 目录联接后运行）
```

| 时点 | 结果 |
|---|---|
| 修复前 | `-- 场景 Level --` 后 **Segmentation fault（exit 139）** |
| 修复后 | `自检完成：断言 48 条，通过 48 条，失败 0 条`，exit 0 |

自检覆盖：清单条目 / `Prefabs/Level/Grid`（`size=(0.8,0.8)`）/ 场景 Level 972 节点 /
场景 Main 1798 节点 / `ScenePrefabInjector` 定向注入 / **新增的 `ApplyTree`**
（`UIPresetStandalone` 52 个字段 + 图内引用重映射）。

补充改动（自检本身）：`InstantiateScene(..., callAwakeInInstantiate=false)`。
关卡/UI 组件的 Awake 依赖运行期管理器（`MainManager.Instance` / `OptionsManager`），
单独重建场景时必然抛异常（修复前实测 8 处 `Awake 抛出异常`）。Unity 的语义也是
「先反序列化整棵树、再由引擎统一分发 Awake」，因此给 `InstantiateData` 加了该开关，
自检只验证反序列化结果。

### 5.2 `ScenePrefabComponentTypes` 的 DCE 缺口

修复前冒烟输出里 `unknownComponents` 有 19 种（`MVZ2.Audios.SoundPlayer x141`、
`MVZ2.UI.Deselector x138`、`MVZ2.Localization.TextMeshProUGUITranslator x128`…）。
根因：这些类的**唯一**引用点是运行期数据（prefab JSON 的 `haxe` 字段），
`Type.resolveClass` 在 hxcpp 上对被 DCE 裁掉的类返回 null。
最小复现（单独编译一个只 `Type.resolveClass` 的 Probe）：

```
mvz2.audios.SoundPlayer -> null
mvz2.grids.GridController -> null
unity.ui.Image -> null
```

修法：把出现次数最多的 40 余个脚本类**列进 `ScriptClasses` 显式表**（产生静态引用）。
这正是该文件 PORT-NOTE 里写的做法（「显式表给最关键的类兜底，反射覆盖其余」）。

## 6. 本轮续推（接入 `MainGameScene`，解 release 卡点）

### 6.1 卡点（新情报 + 本轮实测确认）

release 卡点从 `MainSceneUI.dialog` 推进到 **`MapController.mapCamera` 未注入**：

```
GameEntrance.StartGame → Main.Scene.DisplayPage(Splash) → MapController.Hide
  → SetCameraBackgroundColor → mapCamera.backgroundColor
    mvz2/map/MapController.hx:299
```

数据是齐的：`assets/scene_prefabs/Prefabs/Map/Map.json` 节点 14（`Map`）的
`mapCamera: {n: 7, c: 1}` → 节点 7 `Camera` 上的 `Camera` 组件。

### 6.2 `ScenePrefabLoader` 新增「根对象接管」实例化

新增 `InstantiateData(..., ?rootOverride)` + 公开入口
`InstantiateInto(key, rootOverride, parent, callAwakeInInstantiate)`：

- 数据根节点对应的**已存在** GameObject 不重建（保留手工 `new` 的控制器实例）；
- 根节点上的组件按类型映射到数据记录上（缺的类型仍补建，例如 `MapController` 节点的 `MapUI`）；
- 子节点整棵新建；所有 `[SerializeField]`（含图内引用）照常写入；
- 语义 = Unity 里 prefab 实例**覆盖**场景中已存在的对象。

配套：`ScenePrefabLoader.injectedFields` 统计每次实例化写入的字段数。

### 6.3 `MainGameScene` 接线（本轮授权的 `states/`）

`page()` / `pageRect()` 在挂上控制器组件后调用新的 `InjectPagePrefab(go, name)`，
按 `PAGE_PREFABS`（页面名 -> prefab key）走 `InstantiateInto`：

```
Map          → Prefabs/Map/Map
Almanac      → Prefabs/Almanac/Almanac
Store        → Prefabs/Store/Store
Archive      → Prefabs/Archive/Archive
Addons       → Prefabs/Addons/Addons
MusicRoom    → Prefabs/MusicRoom/MusicRoom
Arcade       → Prefabs/Arcade/Arcade
Splash       → Prefabs/Init/Splash
Titlescreen  → Prefabs/Init/Titlescreen
Mainmenu     → Prefabs/Mainmenu/Mainmenu
ChapterTransition → Prefabs/ChapterTransition
Note         → Prefabs/Note
DebugConsole → Prefabs/Level/UI/DebugConsole
Credits      → Prefabs/Mainmenu/Credits
AchievementHint → Prefabs/UI/AchievementHint
```

- `callAwakeInInstantiate=false`：Awake 仍由 `awakeAll()` 按顺序统一分发（页面 Awake 依赖管理器）。
- 诊断：`MainGameScene.prefabInjectionFailures` / `prefabInjectionFields`。
- 未列出的页面（Portal/Popup/Keybinding/InputNameDialog/DeleteUserDialog）没有对应 prefab 数据，
  保持现状（它们的控制器组件是纯逻辑，没有 `[SerializeField]` 引用）。

### 6.4 `ScenePrefabInjector` 新增

- `ApplyMapPage(pageRoot)`：走 `InstantiateInto("Prefabs/Map/Map", …)`。
- `ApplyMapCameraFallback(controller)`：数据缺失时只在子树里找 `unity.Camera`，仅解空引用。
- `@:access(mvz2.map.MapController)`。

### 6.5 类型检查（每次改动后都跑）

```
neko： [CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0   exit 0
cpp ： [CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0   exit 0
```

### 6.6 冒烟自检（`verify/scenes`，新增 Map 页面用例）

```
-- Map 页面 prefab 接管注入（mapCamera） --
自检完成：断言 57 条，通过 57 条，失败 0 条     exit 0
```

新增 9 条断言验证：手工构造 `MapController` 时 `mapCamera == null` →
`InstantiateInto("Prefabs/Map/Map", root)` 之后
`mapCamera` / `ui` / `mapCameraShakeRoot` / `modelRoot` / `raycastHitbox` 全部非空，
且 `mapCamera` 指向重建出来的 `Camera` 组件。

`unknownComponents` 从 19 种降到 6 种（剩下的都是明确没有 shim 的：AudioListener /
PhysicsRaycaster / Rigidbody / 音频滤镜 / StandaloneInputModule）。


## 7. 待办 / 需要配合

（构建 + 运行验证后补齐）





