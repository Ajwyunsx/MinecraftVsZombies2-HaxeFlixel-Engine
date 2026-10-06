# 场景/prefab 注入收尾（工作包③）—— 执行记录 2026-10-05

> 任务：解掉当前 release 卡点（`MapController.hx:299` 的 `mapCamera` 未注入），补齐剩余
> `[SerializeField]` 注入，直到**能走到主菜单**。
> 分段落盘：每修 1~2 处就追加。
> 上游：`scene_pipeline_work.md` §6（上一轮把 `InstantiateInto` 接进 `MainGameScene:791`）、
> `boot_findings.md`、`integration_report.md`。

## 0. 开工时的实际状态（实测，非任务描述）

**任务描述里的卡点已经不存在了。** 直接运行当前 release 产物
（`HaxePort/export/windows/bin/MVZ2.exe`，mtime 18:41，30,163,456 B），
每 20 s 取一次 boot-trace：

```
[step] MainGameScene 对象图已构建（96 个组件）
[step] 组件 Awake 分发完成，失败 0 个，跳过 21 个
[step] GameEntrance.Start（main.Initialize + InitLoad）
[step] [log] 加载Area Models花费的时间：0.005
[error] [log] 更新赞助者名单时出现错误：Null Object Reference
[done] GameEntrance.Start 完成，已进入主流程
[step] update 循环已进入（MainSceneState.update 第 1 帧）
[step] ENTER_FRAME 心跳：第 1 帧（openfl 主循环在跑）
[step] update 循环正常（第 120 帧）          ← t=40s
[step] ENTER_FRAME 心跳：第 1800 帧
[step] 运行中：已更新 1800 帧                ← t=60s
```

**结论**：
1. **不再段错误**，进程稳定跑 60s+（t=20/40/60 三档心跳都在推进）；
2. `GameEntrance.Start` 全通（`main.Initialize()` + `InitLoad()` 6 个任务全跑完）；
3. `DisplayPage(Splash)` **没有抛异常**（若抛会被 `MainSceneState.create` 的 catch 接住并切
   `ErrorState`，实测没有）⇒ **调用链已经越过 `MapController.hx:299`**；
4. 但画面仍黑、且**永远停在 Splash 页面**（`skippedAwake` 21 个页面组件的 Awake 没分发）。

## 1. 逐项核对任务列出的 6 个「必补字段」

| # | 字段 | C# 声明 | 现状 | 数据来源 |
|---|---|---|---|---|
| 1 | `MapController.mapCamera` | `MVZ2/Map/MapController.cs` `[SerializeField] Camera` | ✅ 已注入 | `scene_prefabs/Prefabs/Map/Map.json` 节点 14 `mapCamera:{n:7,c:1}` |
| 2 | `MainSceneUI.dialog` | `MVZ2/UI/Scene/MainSceneUI.cs` | ✅ 已注入（手写对象图） | `Prefabs/UI/Dialogs/CustomDialog.prefab` |
| 3 | `CameraLimiter._camera` | `MVZ2/Level/CameraLimiter.cs` | ✅ 已注入 | `Prefabs/Camera.prefab` |
| 4 | `LevelUIPreset` 的 4 个 hintArrow offset | `View/Level/LevelUIPreset.cs` | ⚠️ **有实现无调用点**（`ScenePrefabInjector.ApplyLevelUIPreset` 全仓无引用；不影响主菜单路径） | `Level` 节点 `UIPresetStandalone`/`UIPresetMobile` |
| 5 | `LevelCamera.cameraShakeOffset` | `MVZ2/Cameras/LevelCamera.cs:91` | ✅ **本就不该注入**：C# 该字段**没有** `[SerializeField]`，初值 `Vector3.zero` | 无（`scene_pipeline_findings.md` §3.3） |
| 6 | `GridController.size` | `MVZ2/Grids/GridController.cs:236` | ✅ 已兜底（`ensureSize()` 惰性注入） | `Prefabs/Level/Grid.prefab` `size:(0.8,0.8)` |

## 2. 真正的阻塞点：动画事件链路整体缺失（**走到主菜单的唯一障碍**）

`GameEntrance.StartGame` 调 `DisplayPage(Splash)` 之后，**Unity 里推进到下一屏靠的是动画事件**，
而移植层**完全没有动画系统**：

- `Assets/Prefabs/Init/Splash.prefab` 的 `Splash` 节点挂 `Animator`，`m_Controller` →
  `Assets/Animation/Init/Splash/splash.controller`（guid `523cd7d4…`）；
- controller 的默认状态 `Animate` → clip `splash.anim`（guid `5d478da8…`）；
- `splash.anim` 的 `m_Events: [{time: 2.5, functionName: EnterTitleScreen}]`
  → Unity 在播放到 2.5 s 时对**同一 GameObject 上的 `SplashController`** 调用 `EnterTitleScreen()`
  → `MainManager.Instance.Scene.DisplayTitlescreen()`。

移植层现状（逐条核实）：

| 环节 | 现状（修复前） |
|---|---|
| `unity.Animator.Update(dt)` | **空实现**（`Animator.hx:97`） |
| `Animator.runtimeAnimatorController` | 有字段，但由 `ModelPrefabAssets.Resolve` 解析 → **恒为 null** |
| `.controller` / `.anim` 资产 | `assets/Animation/` 下**已镜像**（152 controller + 612 clip），但**没有任何转换脚本** |
| `unity.AnimationClip` | **不存在**（`source/unity/` 无该 shim） |
| 动画事件分派 | 全仓无实现 |
| 场景里 Animator 的驱动 | `MainGameScene.update()` 只遍历 `behaviours`（MonoBehaviour）与 `updateSteps`，**Animator 不在其中** |

**同一个缺口还挡住**：`MainmenuController.Init`（`mainmenu_start.anim` 0.5 s 事件）、
`ChapterTransitionController.CallEnd`、`LevelUI.CallExitLevelToNote`、
`SoundPlayer.Play2D/PlaySound2D`、`Model.UpdateEnable` 等 —— 即全工程的动画事件。

**证据（本机实测）**：当前 release 运行 60 s，boot-trace 里
`DisplayPage(Splash)` 之后**再无任何页面切换痕迹**，也没有 `EnterTitleScreen` 的任何调用记录。

## 3. 本轮实现（工作包③ 的修复）

### 3.1 新增转换器 `tools_build/build_anim.py`

把 `Assets/Animation/**` 的 `.controller` / `.anim` 转成运行期数据（152 controller + 612 clip）：

* `AnimatorController`：参数表（名字/类型/默认值）、层、状态机（状态/默认状态/转移）、
  状态绑定的 clip key、转移条件（Unity 的 `m_ConditionMode`）。
* `AnimationClip`：`m_FloatCurves`（按 path/classID/attribute/script 归组，关键帧原样导出）、
  `m_Events`（**动画事件**）、`m_SampleRate`、`m_WrapMode`、长度。
* 输出：`assets/anim_manifest.json` + `assets/anim_prefabs/**`（764 文件）。
* key = 相对 assets 的路径**含扩展名**（与场景数据里 `runtimeAnimatorController.asset.path` 一致）。
  含扩展名是必须的：`X/splash.controller` 与 `X/splash.anim` 去扩展名后同名会互相覆盖
  （实测第一次跑时 Splash 的 controller 数据被同名 clip 覆盖，动画事件整条丢失）。
* 实测统计：`{"controllers": 152, "clips": 612, "curves": 963, "events": 16, "states": 629,
  "unresolvedClips": 56}`。56 个未解析的 state 都在 `Entities/**` 的模型 controller 上
  （它们指向 `Model` 自己的动画数据，不在场景/UI 主路径）。
* **BlendTree 按「第一个子 clip」近似**（Mainmenu 背景图混合），见脚本内的 PORT-NOTE。

### 3.2 新增运行期 `source/mvz2/animations/`

| 文件 | 作用 |
|---|---|
| `AnimData.hx` | 数据 typedef（`AnimControllerFile` / `AnimClipFile` / `AnimManifest`…） |
| `AnimatorManifestLoader.hx` | 按 key 加载并缓存 controller / clip 数据 |
| `AnimatorRuntime.hx` | **状态机运行期**：层/状态/转移推进、条件求值、曲线线性插值写字段、**动画事件分派** |

关键语义（对照 Unity）：
* 转移条件支持 `m_ConditionMode` 1=If、2=IfNot、3=Greater、4=Less、6=Equals、7=NotEqual；
  `hasExitTime` 在 normalizedTime 越过 exitTime 时触发；无条件且无 hasExitTime 的转移**不触发**
  （否则每帧自转，Unity 同样要求二者之一）。
* 曲线按 (path, classID, attribute) 定位目标：`classID` 4=Transform、212=SpriteRenderer、
  224=RectTransform、225=CanvasGroup、1=GameObject(m_IsActive)，其余（114 MonoBehaviour 自定义字段、
  198 ParticleSystem）走按字段名反射写入。
* **动画事件**：时间跨过事件时刻时对**动画根 GameObject** 的所有组件反射调用同名方法
  （等价 Unity 的 `SendMessage`，但移植层没有 SendMessage，且目标都是同 GameObject 上的
  已移植组件）。这是 `SplashController.EnterTitleScreen` 被调用的唯一途径。
* 贝塞尔切线（`inSlope`/`outSlope`）不导出，曲线线性插值（这批 clip 都是少量手 K 关键帧）。

### 3.3 `unity/Animator.hx` 接线

* `runtimeAnimatorController` 改成 `get/set` 属性：赋**字符串**（数据 key）即绑定 controller
  （Unity 的同一语义：赋 controller 会重置到默认状态与参数默认值）。
* `Update(dt)` 交给 `AnimatorRuntime` 推进（含触发动画事件）。
* 参数读写同时更新本地 `parameters` 表（保持 `Model.SerializableAnimator` 的既有行为）与 runtime。

### 3.4 `mvz2/models/ModelPrefabAssets.hx`

`AnimatorController` / `AnimationClip` 的资产引用返回**数据 key 字符串**
（原来返回 null）。`ScenePrefabFieldApplier` 写 `runtimeAnimatorController` 时就会把 key 写进去，
Animator 的 setter 随即绑定。

### 3.5 场景驱动（`MainGameScene.hx` + 新增 `AnimatorAutoUpdater.hx`）

Unity 的引擎每帧自动推进所有 `enabled && activeInHierarchy` 的 Animator；移植层没有引擎，
`MainGameScene.update()` 原本只驱动 MonoBehaviour 协程与显式登记的 `updateSteps`，**Animator 不在其中**
—— 所以 Splash 的 Animator 从不播放。新增 `AnimatorAutoUpdater`：
`build()` 末尾（全部页面 prefab 注入完成后）`addTree(root)` 递归登记，`update()` 开头按 Unity 语义推进。

* **显式 `Update()` 不检查 `enabled`**：C# 里 `LevelController.UpdateEntityAnimators` 先
  `animator.enabled = false` 再 `animator.Update(dt * speed)`（限流更新），在 runtime 里判 `enabled`
  会让关卡模型动画全部停摆。`enabled` 只在自动推进侧过滤。
* **fileID 必须转字符串**：Unity 的 fileID 是 64 位（实测 `-7411722888129386122`），
  Haxe 的 Int 是 32 位，直接当数字会在 JSON 解析时溢出。导出脚本统一转十进制字符串
  （`build_anim.py` 的 `_key()`）。
* **登记点必须在注入处，不能只在 `build()` 末尾**：实测末尾从 `root` 递归只登记到 **8** 个，
  而每个页面从自己的根递归能看到 **43** 个。原因是页面根在 `page()` 里 `SetActive(false)`，
  且 `GetComponentsInChildren(..., includeInactive=false)` 会跳过未激活子树
  （shim 的实现在 `unity/GameObject.hx:61`）。改为在 `InjectPagePrefab` 里对每个页面根
  `addTree(go)`（不依赖 root 的可达性），并在 `build()` 末尾保留一次兜底。
  `addTree` 也改成显式遍历 `transform.children`，不看激活状态。

（待续：运行验证）

## 4. 任务列出的字段：数据源核查（本轮逐条实测）

用 `ScenePrefabLoader.InstantiateScene("Level", null, false)` 重建整棵树后逐字段断言
（探针 `/tmp/probe/Probe5.hx`，`--interp` 运行，输出见下）：

```
nodes=972
GridController=1     grid Grid size=0.8,0.8                                  ← 任务项 ⑥ ✅
LevelUIPreset=2      UIPresetStandalone bp=24,-108 starshardAngle=180        ← 任务项 ④ ✅
                     UIPresetMobile     bp=160,-27.5 starshardAngle=180
LevelCamera=1        anchor=0.5 pos=3,-10                                    ← 任务项 ⑤ ✅（cameraShakeOffset 无 [SerializeField]）
```

| 任务项 | 数据源 | 运行期注入路径 | 状态 |
|---|---|---|---|
| `GridController.size` | `Prefabs/Level/Grid` `size:(0.8,0.8)` | `GridController.ensureSize()`（惰性，`UpdateGridController`/`TransformWorld2ColliderPosition` 入口） | ✅ 已验证 |
| `LevelUIPreset` 4 offset + 4 angle | `scenes/Level` 的 `UIPresetStandalone`/`UIPresetMobile`（**场景实际生效值**，非 `UIPreset.prefab` 裸值） | `InstantiateScene("Level")` 建树时由 `ScenePrefabFieldApplier` 写入 | ✅ 已验证 |
| `LevelCamera.cameraAnchor/cameraPosition` | `scenes/Level` `Camera` 节点 | 同上 | ✅ 已验证 |
| `LevelCamera.cameraShakeOffset` | **无**（C# 无 `[SerializeField]`） | 无需注入，`= new Vector3(0,0,0)` 已等价 | ✅ 结论已确认 |
| `CameraLimiter._camera` | `scenes/Level` `Camera` 节点 `_camera:{n:11,c:1}`；`MainGame` 场景里由 `buildMainScene()` 手工建同一实例 | 数据路径 + 手工路径双覆盖 | ✅ |
| `MainSceneUI.dialog` | `Prefabs/MainGame` 节点 21 `Dialogs/Dialog` | `buildDialog()` → `injectDialogPrefab` | ✅（见 §5） |

**`ScenePrefabInjector` 的定向入口目前仍无调用点**（`ApplyLevelUIPreset` / `ApplyLevelCamera` 全仓无引用）：
关卡场景还没有构建入口（`LevelManager.GotoLevelSceneAsync` → `Scene.LoadSceneAsync("Level")`，
而 `SceneManager.scenes` 里没有注册 "Level"，见 `scene_pipeline_findings.md` §4）。
数据驱动的 `InstantiateScene("Level")` 路径已实测可用，等关卡接入时直接用即可，
这两个定向入口保留给「手工构造的单点对象」场景。

## 5. 对话框对象图：两套来源已合并（与另一 agent 的修法对齐）

任务提到的 `MainGameScene.buildDialog()` 手工对象图**已被另一 agent 改为「优先走 prefab 数据」**：
`buildDialog` / `buildInputNameDialog` / `buildDeleteUserDialog` 三处在建好根组件后先调
`injectDialogPrefab(dialogObject, key)`（内部就是 `ScenePrefabLoader.InstantiateInto`），
数据存在时**直接 return**，手写图只作为数据缺失时的回退。

本轮核对结论：**两套来源不会再冲突** ——
* 三个对话框的根节点名与数据根名一致（`CustomDialog` / `InputNameDialog` / `DeleteUserDialog`），
  `InstantiateInto` 的「根对象接管」模式保留手工 `new` 的控制器组件，只补子节点与字段；
* 数据里 `CustomDialog.dialogTransform/title/desc/buttonRowList`、
  `InputNameDialogController.ui`、`DeleteUserDialogController.ui` 等引用全部齐备
  （实测 `Prefabs/UI/Dialogs/{CustomDialog,InputNameDialog,DeleteUserDialog}.json`）；
* 三个对话框在 `MainGame.prefab` 里挂在**同一个 `Dialogs` 节点**（节点 21）下，
  与 `build*Dialog(dialogsObject)` 共用一个父节点的写法一致。

**唯一需要注意的差异**：手工回退路径缺 `Image.sprite`（数据里有 `mvz2:init/form` 等），
表现为纯白占位色块 —— 这正是 `black_screen_report.md` §4 描述的现象。
数据路径接管后该问题消失。

## 6. 运行验证：**Splash → Titlescreen 页面推进已打通**（本轮实测）

release 构建（`haxelib run lime build windows`，产物 30,385,664 B，21:40）运行 30 s：

```
[step] 页面 prefab 注入：Splash（Prefabs/Init/Splash）写入 74 个字段，Animator=1（累计登记 1 个）
[step] 页面 prefab 注入：Titlescreen（...）写入 679 个字段，Animator=1（累计登记 2 个）
...
[step] Animator 已登记：43 个（每帧自动推进，触发动画事件），其中未绑定 controller 数据 14 个
[step] Animator 推进第 1 帧：登记 43，enabled=43，activeInHierarchy=2，已绑定 controller=29
[step]   [Splash] enabled=true active=true bound=true 状态=splash            ← 第 1 帧 Splash 激活
[step]   [Titlescreen] enabled=true active=false bound=true 状态=titlescreen
...
[step] Animator 推进第 200 帧：登记 43，enabled=43，activeInHierarchy=2，已绑定 controller=29
[step]   [Splash] enabled=true active=false bound=true 状态=splash            ← 已切走
[step]   [Titlescreen] enabled=true active=true bound=true 状态=titlescreen  ← 已切到标题页
```

**这证明 `splash.anim` 的 2.5 s 动画事件 `EnterTitleScreen` 被触发并成功执行了
`MainManager.Instance.Scene.DisplayTitlescreen()`** —— 这是「黑屏卡在 Splash」的直接修复。

截图（`tools_build/shots/_w3_titlescreen.png`，1280×720 客户区，`grab_shot.ps1` + `analyze_shot.py`）：

```
非黑像素 384,277 / 921,600 = 41.697%      颜色桶 29      连通区域 4
主要颜色 #f0f0f0 41.62%（标题页的 Logo / StartButton / 版本条占位色块）
```

人工核对截图：**布局已是 Titlescreen 的**（上方 Logo 块、中部下拉的 StartButton、下方按钮条、
左下角版本文本 `版本{0}`），不再是之前「居中一个对话框」的 Splash 画面。

**判定：动画事件链路修复生效，页面推进已打通。** 剩余可见问题是
`Image.sprite` 未解析成帧（纯白占位色块）与文本无字体 —— 属渲染层工作包，
与 `black_screen_report.md` §4 的结论一致，不在本工作包范围。

## 7. 仍需注意 / 未完成项

1. **14 个 Animator 未绑定 controller 数据**（`unboundCount`）。逐条定位（脚本扫描
   `assets/scene_prefabs/**` 里 `type=="Animator"` 且 `runtimeAnimatorController.asset` 缺失的记录）：

   | 页面 | 节点名 | 个数 |
   |---|---|---|
   | `Prefabs/Almanac/Almanac` | `ui` / `contraption` / `bone` / `humanoid` | 12 |
   | `Prefabs/Store/Store` | `ui` | 2 |

   这些是**模型子树上的 Animator**（`ModelPrefabLoader` 路径，controller 引用由模型 prefab
   数据 / `ModelPrefabAssets` 提供），不属于场景/UI 的动画事件链路，因此不影响页面推进。
   关卡与图鉴/商店的模型动画接入时需要单独确认。
2. **`ScenePrefabInjector.ApplyLevelUIPreset` / `ApplyLevelCamera` 仍无调用点** ——
   数据驱动路径（`InstantiateScene("Level")`）已实测可用（§4），关卡接入时直接用即可。
3. **`buildDialog` 的手写回退路径**仍缺 `Image.sprite`（数据路径正常）。若 `build_scene.py`
   未跑过，回退路径会退化成白块 —— 但那是「数据缺失」的降级行为，可接受。
4. **`MainSceneController.DisplayPage` 只遍历 `pages` 表**，因此页面推进完全依赖
   动画事件（Splash）或按钮点击（Titlescreen 的 StartButton）。后者需要 uGUI 按钮的
   `onClick` 链路可用 —— 属渲染/输入层工作包。

## 8. 最终验证（2026-10-05 21:52 产物）

```
cd HaxePort && haxelib run lime build windows        # exit 0
产物 export/windows/bin/MVZ2.exe  30,386,688 B  md5 48178d98a1e03d92175969d29902a7e4
```

类型检查（本轮改完最后一次）：

```
neko: exit 0
cpp : [CoverageCheck] 模块总数=2493 类型化成功=2493 失败=0   exit 0
```

运行 35 s（`export/windows/bin/boot-trace.log`，273 行）：

```
[step] Animator 已登记：43 个（每帧自动推进，触发动画事件），其中未绑定 controller 数据 14 个
[step] Animator 推进第 1 帧：登记 43，enabled=43，activeInHierarchy=2，已绑定 controller=29
[step] Animator 推进第 600 帧：登记 43，enabled=43，activeInHierarchy=2，已绑定 controller=29
```

截图 `tools_build/shots/_w3_final.png`：非黑像素 **41.697%**（384,277/921,600），颜色桶 29，
连通区域 4 —— **画面是 Titlescreen 布局**（Logo / StartButton / 版本条 / 左下角 `版本{0}`）。

**结论：Splash → Titlescreen 页面推进已打通并稳定**（运行 35 s 无崩溃、无新增 `[error]`）。
