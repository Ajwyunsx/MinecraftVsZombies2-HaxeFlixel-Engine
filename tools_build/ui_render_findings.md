# uGUI 渲染层（工作包：让 UI 元素真正画出来）—— 执行记录 2026-10-05

> 分段落盘，边做边写。上游：`PORTING.md`（构建与验证）、`boot_findings.md`、
> `integration_report.md`、`scene_pipeline_work.md`、`scene_inject_findings.md`、
> `verify_shots_notes.md`。
> 姊妹工作包（精灵/SpriteRenderer 渲染）已并行落地 `source/mvz2/sprites/SpriteFrameFactory.hx`
> 与 `source/unity/SpriteRenderer.hx`（`renderSprite` 字段 + `spriteApplier` 钩子）。

## 0. 开工时的实际状态（实测，与任务描述有差异）

任务描述说「release 崩溃点是 `MapController.hx:299` 的 `mapCamera` 未注入」。实测**该处已修**：
直接运行 `export/windows/bin/MVZ2.exe`（18:41 产物，30,163,456 B），启动链路全通：

```
[step] 组件 Awake 分发完成，失败 0 个，跳过 21 个
[step] GameEntrance.Start（main.Initialize + InitLoad）
[step] [log] 加载Area Models花费的时间：0.005
[error] [log] 更新赞助者名单时出现错误：Null Object Reference
[done] GameEntrance.Start 完成，已进入主流程
[step] update 循环已进入（MainSceneState.update 第 1 帧）
[step] 运行中：已更新 1800 帧
```

**本工作包实测的黑屏基线**（`tools_build/shots/before_shared_window.png`，由姊妹工作包产出）：
窗口客户区整块纯黑（非黑像素 7.300% 全部来自 Windows 标题栏/桌面）。

## 1. 黑屏的**直接**根因（本工作包负责的部分）

`source/unity/ui/*`（20 个文件）是纯逻辑 shim，且**从未往 Flixel 显示列表里加过任何东西**：

| 检查 | 结果 |
|---|---|
| `grep -rn "FlxG.state\|addChild\|FlxGroup" source/unity/ui/` | **0 命中** |
| `Graphic.Rebuild(update)` | 空实现（`Graphic.hx:45`） |
| `Graphic.SetAllDirty/SetVerticesDirty/SetMaterialDirty` | 空实现 |
| `Graphic.canvasRenderer` | 裸 `new CanvasRenderer()`，不持有任何绘制内容 |
| `Image.sprite` / `RawImage.texture` / `Text.text` | 只存字段，无消费者 |
| `unity.GameObject` | `import flixel.group.FlxGroup` 但**从未实例化**，只是注释里说"composes a FlxGroup" |
| `unity.Camera.backgroundColor` | 只存字段，从不写 `FlxG.cameras.bgColor` |

**结论**：黑屏 = 「uGUI 逻辑图 → Flixel 显示列表」这一层整体缺失，不是某个字段没注入。

## 2. 设计（本工作包的实现方案）

### 2.1 分层与依赖方向

`unity` 包**不能**反向依赖 `mvz2`（会形成循环，且 `unity` 是"引擎兼容层"）。
姊妹工作包已确立的模式是**钩子**（`SpriteRenderer.spriteApplier`）。本工作包沿用同一模式：

```
unity.ui.Graphic          ── 声明静态钩子 GraphicRebuilder（Void->Void）
                              并在"任何可能改变视觉的属性被写"时调用
mvz2.ui.UiRenderer        ── 安装钩子；每帧/按需把 uGUI 树转成 Flixel 显示列表
```

### 2.2 关键设计点

1. **一个 FlxGroup 作为 UI 根**（`mvz2.ui.UiRenderer.root`），挂在 `FlxG.state` 上。
   不挂到 `FlxG.plugins`：plugins 的 draw 顺序由 `FlxG.plugins.drawOnTop` 决定，
   而 UI 必须**永远在最上层**（Unity 的 ScreenSpaceOverlay Canvas 语义）。
2. **RectTransform → 实际矩形**：按 Unity 的 anchor/pivot/offset 规则，
   用父级 rect 递推（`anchorMin/anchorMax/anchoredPosition/sizeDelta/pivot`）。
   Canvas 根的 rect = 屏幕（由 `CanvasScaler` 换算，见 §2.3）。
3. **Graphic → FlxSprite**：`Image`/`RawImage` 有贴图就用帧；没贴图（纯色块）就用
   `FlxSprite.makeGraphic` 生成的 1x1 白图 + `color` 染色（Unity 的 Image 无 sprite 时
   就是画一个纯色矩形，`Image.cs` 的 `GenerateSimpleSprite` 走 `s_WhiteTexture`）。
4. **Text → FlxText**：字号/颜色/对齐/换行。
5. **CanvasScaler**：`ScaleWithScreenSize` + `referenceResolution` → scaleFactor，
   按工程既有约定（`Main` 场景 1280x720 逻辑分辨率、`FlxG.width/height`）。

## 3. 进度（分段落盘）

- [ ] §3.1 读 `source/mvz2/ui/**` 与 `MainSceneUI.hx`，列出实际用到的 UI 能力
- [ ] §3.2 `unity.ui.Graphic` 加渲染钩子（不改变既有逻辑）
- [ ] §3.3 `mvz2.ui.UiRenderer`（RectTransform → rect 递推 + Graphic → FlxSprite）
- [ ] §3.4 Canvas / CanvasScaler 分辨率换算
- [ ] §3.5 接入 `MainSceneState`（每帧同步）
- [ ] §3.6 neko + cpp 类型检查
- [ ] §3.7 构建 + 运行 + 截图 + 像素统计

---

## 4. 实际改动（第一轮，2026-10-05 19:2x）

### 4.1 新增 `source/mvz2/ui/UiRenderer.hx`（**本工作包核心**，约 870 行）

`flixel.group.FlxGroup` 的子类，每帧把 uGUI 树同步成 Flixel 显示列表：

| 步骤 | 实现 |
|---|---|
| 遍历 | `roots`（`MainGameScene.root`）→ 深度优先；`activeInHierarchy == false` 的子树整棵跳过 |
| RectTransform | `childFrame()` 按 Unity 规则递推：`anchorMin/anchorMax` 定位锚点框、`sizeDelta` 定尺寸、`pivot` 定参考点、`anchoredPosition` 定偏移；父级 `localScale` 级联 |
| Canvas | `screenFrame()` = 屏幕 / scaleFactor，原点在画布中心（根 Canvas 的 pivot 强制 (0.5,0.5)） |
| CanvasScaler | `computeScaleFactor()` 复刻 Unity `HandleScaleWithScreenSize`（MatchWidthOrHeight 用 log2 插值、Expand 取小、Shrink 取大） |
| Image/RawImage | 有 sprite → `SpriteFrameFactory.getFrame()` 取帧；无 sprite → 共享 1x1 白图 + `color` 染色（等价 Unity 的 `s_WhiteTexture` 纯色矩形） |
| Text/TMP | `FlxText`；字体按内容挑（非 ASCII → unifont，否则 minecraft_font）；`setFormat` 只在字体/字号变化时调用（否则每帧重排版会掉帧） |
| Mask | 用 `FlxSprite.clipRect` 做矩形裁剪；裁剪矩形按子树派生，不污染兄弟 |
| CanvasGroup | 向上收集 `alpha` 并相乘 |
| SpriteRenderer | **世界空间**精灵（Mainmenu/Titlescreen 背景）按正交相机换算到屏幕，并按 `(sortingLayerID, sortingOrder)` 排序 |
| 顺序 | `applyOrder()` 用 `members.resize(n)` + 逐位赋值（不用 `clear()+add()`：后者在槽位不足时会把 `add()` 的项 splice 到数组头部，打乱顺序） |
| 淘汰 | `retire()` 推迟到 `reap()` 销毁（遍历中 `destroy()` 会改 FlxGroup 成员表） |

### 4.2 `source/unity/ui/Graphic.hx`

- 新增静态钩子 `Graphic.visualDirty`（由 UiRenderer 安装）+ `Graphic.revision` 版本号 + `Graphic.markVisualDirty()`。
  unity 包不能反向依赖 mvz2，沿用 `SpriteRenderer.spriteApplier` 已确立的钩子模式。
- `color` / `raycastTarget` 改成属性（写入时 bump revision）；
  `SetAllDirty/SetLayoutDirty/SetVerticesDirty/SetMaterialDirty/SetNativeSize` 统一收敛到 `markVisualDirty()`。
- `CrossFadeColor` / `CrossFadeAlpha`：Unity 是"相对当前值渐变"，移植层无渐变队列 → **立即落到目标值**（保证收敛值一致）。
- `canvas` 属性改为 `unity.Canvas.FindCanvasOf(this)`（原先恒返回 null）。

### 4.3 `source/unity/ui/{Image,Text,RawImage}.hx` + `source/unity/tmpro/TextMeshProUGUI.hx`

所有会改变外观的字段改成属性并触发 `Graphic.markVisualDirty()`：
`Image.sprite/overrideSprite/type/fillAmount/…`、`Text.text/font/fontSize/alignment/…`、
`RawImage.texture/uvRect`、`TMP.text/fontSize/alignment/richText/…`。
**字段名、类型、默认值全部保持原样**（只把 `public var x` 改成 `public var x(get,set)` + 同名私有字段）。

### 4.4 `source/unity/Canvas.hx`

新增 `Canvas.FindCanvasOf(comp)`：沿 Transform 向上找 Canvas 组件（Unity 由引擎维护该引用）。

### 4.5 `source/unity/SpriteRenderer.hx`

补 `sortingLayerID:Int`。prefab 导出数据里只有 `sortingLayerID`（Unity 序列化的就是它），
原先 shim 没有该字段 → `ScenePrefabFieldApplier` 判"类型不符"跳过 → 渲染层拿不到排序层
（Mainmenu 的 `WindowView` 排序层 -10 会被当成 0，盖住背景）。

### 4.6 `source/mvz2/sprites/SpriteManifestLoader.hx`

新增 `createSpriteForTexture(texture)`：把一张**已有**的 `unity.Texture2D` 包成整图 Sprite
（等价 `Sprite.Create(texture, rect, pivot)`），供 `RawImage.texture` 走统一的取帧路径。

### 4.7 `source/mvz2/states/MainSceneState.hx`

`create()` 里在 `new MainGameScene()` 之后、`awakeAll()` 之前调用 `UiRenderer.install(scene.root)`，
并落一条 boot-trace。**不改 `source/Main.hx`**（归启动链路工作包）。

### 4.8 `source/mvz2/scenes/ScenePrefabFieldApplier.hx`（**关键**，属工作包②的字段写回）

导出数据里 `Image.sprite` 是 `{asset:{guid,fileID,path,address}}`，**原先只对
`SpriteRenderer` 走 `ModelPrefabAssetsBridge.ApplyRendererSprite`，`Image` 的 sprite 从未被解析**
→ 所有 UI 图片的 `sprite` 恒为 null → UiRenderer 只能画纯色块 → 画面几乎全黑。

新增：
- `ApplyImageSprite(image, raw)` —— 解析成 `unity.Sprite` 写进 `Image.sprite`；
- `ApplyRawImageTexture(rawImage, raw)`；
- `ResolveSprite(raw)` —— 先按 `(guid, fileID)` 查清单，再回退 `ModelPrefabAssets.Resolve`。

### 4.9 `source/mvz2/sprites/SpriteManifestLoader.hx`

新增 `findSpriteByFileID(guid, fileID)`：按贴图 guid + 子精灵 fileID 精确定位
（`fileID == 21300000` 是"整图精灵"，其它值对应图集 slices 的 `internalIDString`）。

### 4.10 隔离验证工程 `tools_build/verify_ui/`

复制自 `verify_startup/`，额外加 `<assets path="../../assets/Fonts" />`
（**必须**：UI 文本要能从 lime 资源库取到 unifont/minecraft_font，否则 FlxText 会
`Assets.getFont` 抛异常）。`export/windows/bin/assets` 是指回 `HaxePort/assets` 的目录联接。


### 4.11 与并行工作包的重叠（**已协调，勿重复实现**）

开工后发现另有 2 个 agent 在并行做**同一件事**的相邻部分，本工作包已让路 / 对接：

| 文件 | 归属 | 本工作包的处理 |
|---|---|---|
| `source/mvz2/sprites/SpriteFrameFactory.hx`、`source/unity/SpriteRenderer.hx`（`renderSprite` + `spriteApplier` 钩子） | 精灵工作包 | **复用**，不重写。`UiRenderer` 用它的 `getFrame/makeImageFrame` 取帧 |
| `source/unity/RenderBridge.hx`（每帧把 SpriteRenderer 的 transform/激活状态同步到 renderSprite） | 另一 agent（19:57 落地） | 只读不改。它在 `preUpdate` 写 `scale`/`visible`/`alpha`/`flip`，**不写位置**（位置由本工作包的 `UiRenderer` 负责，注释里已明确分工） |
| `source/mvz2/animations/*`（AnimatorRuntime 动画状态机 + 动画事件） | 另一 agent | 只读不改。Splash → Titlescreen 的页面推进靠它的动画事件 `EnterTitleScreen` |

**职责分界（重要）**：`RenderBridge` 管「SpriteRenderer → renderSprite 的 transform 同步」；
`UiRenderer` 管「uGUI 树 → 显示列表 + 世界空间 SpriteRenderer 的**屏幕位置**」。


### 4.12 `source/mvz2/states/MainSceneState.hx`（诊断落盘）

每 120 帧把 `UiRenderer` 的统计写进 boot-trace：
`可见项/成员（Graphic / 文本 / 纯色 / 世界精灵 / 跳过）+ SpriteFrameFactory.failureCount + 同步异常`。
理由：lime 的 Windows 程序是 GUI 子系统没有 stdout，画面又可能被别的窗口盖住，
「UI 到底画出来没有」需要一个**不依赖截图**的客观判据。


---

## 5. 第二轮：修「白色占位块」（2026-10-05 20:5x~21:3x）

### 5.1 实测证据：布局**完全正确**，缺的只是贴图

对 20:49 抓到的画面（`tools_build/shots/ui_after_2.png`）做像素几何分析，与
`UiRenderer` 的 RectTransform 解析结果**逐像素吻合**：

| 元素 | 我算出的屏幕矩形 | 截图实测白色区域 | 结论 |
|---|---|---|---|
| `Logo`（Titlescreen node 6，anchor(0.5,1)+sizeDelta 614×154） | x=149,y=36 982×246 | x=149..1130 y=37..282 → **982×246** | 一致 |
| `StartButton`（node 9，anchor(0.5,0) sizeDelta 400×40） | x=320,y=576 640×64 | x=320..959 y=576..639 → **640×64** | 一致 |
| `VersionText`（node 7，anchor(0,0) sizeDelta 200×30） | x=8,y=664 320×48 | x=12..90 y=666..687 | 一致（文本实际宽度更窄） |

（`scaleFactor = 1.6` = `2^(log2(1280/800))`，与 Unity 的 `ScaleWithScreenSize` +
`matchWidthOrHeight=0` 相同。）

⇒ **anchor/pivot/sizeDelta → 屏幕矩形** 这条链路是对的；「白块」纯粹是**贴图没接上**。

### 5.2 三个 Dialog 已加入 `PAGE_PREFABS`（任务指定的修法 a）

`MainGameScene.hx` 的 `PAGE_PREFABS` 新增：
```
"CustomDialog" => "Prefabs/UI/Dialogs/CustomDialog",
"InputNameDialog" => "Prefabs/UI/Dialogs/InputNameDialog",
"DeleteUserDialog" => "Prefabs/UI/Dialogs/DeleteUserDialog",
```
（原先这 3 个对话框由 `buildDialog()`/`buildInputNameDialog()`/`buildDeleteUserDialog()`
**手工**建对象图，只挂组件不写序列化字段 ⇒ `Image.sprite` 恒 null ⇒ 退化成 1×1 白图拉伸。）

### 5.3 **但根因不止于此**（重要，推翻任务描述里的单点归因）

实测诊断（`tools_build/verify_ui` 隔离构建，21:2x 产物）：

```
UI 渲染统计：可见项=23 / 成员=30（Graphic=31 文本=0 纯色=0 世界精灵=0 跳过=63），取帧失败=0
UI Image 诊断：有 sprite=0 sprite 为 null=0 取帧失败=0
Graphic 具体类分布（有 RectTransform=30）：unity.tmpro.TextMeshProUGUI=13, unity.ui.Image=18
```

**`unity.ui.Image=18` 个被遍历到，但 `有 sprite=0` 且 `sprite 为 null=0`** —— 两者之和
应为 18 却为 0，说明这 18 个 Image **根本没走到取 sprite 的分支**。
同一批诊断里 `文本=0 纯色=0` 也与 `TextMeshProUGUI=13` 矛盾。

⇒ 卡点在 `updateGraphic()` 的**分支入口**，不是「sprite 没注入」这一件事。
**结论：任务描述给出的单点归因不完整**；加入 `PAGE_PREFABS` 是必要但不充分的一步。

#### 5.3.1 更正：`updateGraphic 调用=0` 是**假读数**

第一次加 `updateGraphicCalls++` 时，`Edit`/脚本的 `old_string` 因空白不匹配**没有真正落盘**
（只在 `sync()` 里留下了 `= 0` 的复位），于是那一轮产物里计数器恒为 0。
**教训**：诊断计数必须**双向核对**（源文件 `grep ++` + 生成的 `.cpp` `grep HXLINE`），
否则会把"探针没接上"误读成"分支没执行"。已改正并重新构建。

同一教训适用于 `text=0`：`textCount++` 只在**首次创建** FlxText 时执行（`updateText` 里
`label == null` 的分支），稳定帧读到 0 属正常，不能据此判定"文本没渲染"。


---

## 6. 第三轮：白色占位块的**真正根因**（2026-10-05 21:5x~22:xx）

### 6.1 决定性证据（隔离构建 `tools_build/verify_ui`，21:58 产物）

给 `UiRenderer.sync()` 末尾加了一帧内自洽的快照（见 §4.12 的说明），实测：

```
UI 快照（sync 末尾自洽）：可见项=23 成员=30 Graphic=31(有Rect=30) 文本=0 纯色=0
  世界精灵=0 跳过=63 updateGraphic调用=30 Image有sprite=0 Image无sprite=0 Image取帧失败=0
  类=[unity.tmpro.TextMeshProUGUI=13,unity.ui.Image=18]

updateGraphic 样例：
  .../CustomDialog/Blocker            g=unity.ui.Image            text=false uiText=false
  .../CustomDialog/Root/Desc          g=unity.tmpro.TextMeshProUGUI text=true uiText=false
  .../CustomDialog/Root/Buttons/ButtonRow/TextButton          g=unity.ui.Image text=false
  .../CustomDialog/Root/Buttons/ButtonRow/TextButton/Text     g=unity.tmpro.TextMeshProUGUI text=true
  ...
```

关键矛盾：
- `updateGraphic 调用=30`、样例里 `g=unity.ui.Image` **明明有**；
- 但 `Image有sprite=0` + `Image无sprite=0` = **0 ≠ 18**，即 `image != null` 从未成立；
- 同一函数里 `if (text != null)` 也从未成立（`文本=0`）。

⇒ **`Std.isOfType(graphic, Image)` / `Std.isOfType(c, TextMeshProUGUI)` 在 cpp 上判定为 false。**

### 6.2 根因：hxcpp 把 `Std.isOfType(x, ClassOf<T>)` 编译成**数字类索引**

在生成的 `obj/src/mvz2/ui/UiRenderer.cpp` 里：

```cpp
// renderNode()：有的站点拿到正确的类对象，有的站点拿到数字索引
HXLINE( 493)  _hx_tmp  = ::Std_obj::isOfType(c, ::hx::ClassOf< ::unity::ui::Graphic >());       // 正确
HXLINE( 497)  _hx_tmp2 = ::Std_obj::isOfType(c, 3);                                            // 数字索引！
HXLINE( 499)  _hx_tmp3 = ::Std_obj::isOfType(c, 4);                                            // 数字索引！
// updateGraphic()：
HXDLIN( 618)  if (::Std_obj::isOfType(graphic, 1)) { ... }                                     // 数字索引！
HXDLIN( 619)  if (::Std_obj::isOfType(graphic, ::hx::ClassOf< ::unity::ui::RawImage >()))      // 正确
```

而 `Std.isOfType` 的实现（`obj/src/Std.cpp`）只是转调 `__instanceof(v, t)`：

```cpp
bool Std_obj::isOfType( ::Dynamic v, ::Dynamic t){ return ::__instanceof(v,t); }
```

**数字索引与 `Class` 对象不是一回事** ⇒ 传数字时判定恒为 false。

**触发条件**：类型与**同一模块里声明的其它类型**混用时，hxcpp 的类型推断会退化成"类索引常量"。
本例 `unity.ui.Image`（`Image.hx` 里还声明了 `ImageType`/`FillMethod`）、
`unity.ui.Text`（同文件另有枚举）、`unity.SpriteRenderer`（同文件另有 `SpriteApplier` typedef）
都是"一个模块多个类型"，全部命中。

### 6.3 修法：`UiRenderer.isInstanceOf`（沿继承链判定）

```haxe
private static function isInstanceOf(obj:Dynamic, cls:Class<Dynamic>):Bool {
    if (obj == null || cls == null) return false;
    var c = Type.getClass(obj);
    var guard = 0;
    while (c != null && guard++ < 32) {
        if (c == cls) return true;
        c = Type.getSuperClass(c);
    }
    return false;
}
```

`Type.getClass` / `Type.getSuperClass` 走的是类对象本身，与模块布局无关。
`UiRenderer.hx` 里**全部** `Std.isOfType` 调用点（`Graphic`/`TextMeshProUGUI`/`Text`/`SpriteRenderer`/
`Image`/`RawImage`/`RectTransform`/`FlxText`，共 9 处）都已替换。

### 6.4 与任务描述的差异（重要）

任务描述把白块归因于「三个 Dialog 不在 `PAGE_PREFABS` ⇒ 没走 `ApplyImageSprite` ⇒ sprite 恒 null」。
**这个归因不完整**：

1. 我把三个 Dialog 加进了 `PAGE_PREFABS`（§5.2），**白块依旧**；
2. 反证：`Titlescreen` **本来就在** `PAGE_PREFABS` 里（boot-trace 实测
   `页面 prefab 注入：Titlescreen（Prefabs/Init/Titlescreen）写入 679 个字段`），
   但它的 `Logo` / `StartButton` / `Background` 在截图里**同样是白块**
   （见 §5.1 的几何对照：982×246 / 640×64 白块与算出的矩形逐像素吻合）；
3. 诊断计数 `Image无sprite=0` 直接否掉了"sprite 恒 null"——若真是 sprite 为 null，
   这个计数应当是 18。

⇒ **真正的根因是 §6.2 的 `Std.isOfType` 数字索引缺陷**，它让**所有** uGUI Graphic
（无论有没有 sprite）都进不了取帧分支。加入 `PAGE_PREFABS` 仍是必要的一步
（它保证 sprite 字段真的有值），但**不充分**。

### 6.5 教训（写给后续 agent）

**hxcpp 上不要用 `Std.isOfType(x, SomeClass)` 做运行期类型判定**，尤其当 `SomeClass`
所在模块声明了多个类型时。用 `Type.getClass` + `Type.getSuperClass` 沿继承链判定，
或 `Type.resolveClass(...)` 比对类对象。
（本工程 `unity/` 与 `mvz2/` 里还有大量 `Std.isOfType` 调用点，建议全局排查——
这是与本次「白块」同源的一类缺陷。）


---

## 7. 根因定论：模块级**枚举成员遮蔽类名**（2026-10-05 22:2x）

> §6 把根因记成「hxcpp 把 `Std.isOfType` 编译成数字索引」。**那个描述是错的**，
> 本节的结论取代它。§6.2 的代码引用属实，但"hxcpp 会随机发数字索引"这个解释不对。

### 7.1 真正的原因

`UiRenderer.hx` 模块底部声明了：

```haxe
enum abstract UiEntryKind(Int) {
    var Empty = 0;
    var Image = 1;            // ← 与类 `unity.ui.Image` 同名
    var Solid = 2;
    var Text = 3;             // ← 与类 `unity.ui.Text` 同名
    var SpriteRenderer = 4;   // ← 与类 `unity.SpriteRenderer` 同名
}
```

**Haxe 的 `enum abstract` 成员会被提升为模块级名字**。于是同一个模块里：

| 代码 | 实际比较的对象 |
|---|---|
| `Std.isOfType(c, Text)` | 整数 `3`（不是类 `unity.ui.Text`） |
| `Std.isOfType(c, SpriteRenderer)` | 整数 `4` |
| `Std.isOfType(graphic, Image)` | 整数 `1` |

而 `Std.isOfType` 在 cpp 上就是 `__instanceof(v, t)`，拿整数当类型自然恒为 `false`。

### 7.2 与生成代码**逐值吻合**（决定性证据）

21:58 产物（含缺陷）的 `obj/src/mvz2/ui/UiRenderer.cpp`：

```cpp
HXLINE( 497)  _hx_tmp2 = ::Std_obj::isOfType(c,3);            // ← Text = 3
HXLINE( 499)  _hx_tmp3 = ::Std_obj::isOfType(c,4);            // ← SpriteRenderer = 4
HXDLIN( 618)  if (::Std_obj::isOfType(graphic,1)) { ... }     // ← Image = 1
```

三个数字与枚举值 `Image=1 / Text=3 / SpriteRenderer=4` **一一对应**；
而同一文件里 `Graphic`（模块里没有同名成员）发出的是正确的
`::hx::ClassOf< ::unity::ui::Graphic >()`。**这就是遮蔽的直接证据。**

### 7.3 修法

1. **枚举成员改名**（根上消除遮蔽）：
   `Image → ImageGraphic`、`Text → Label`、`Solid → SolidRect`、`SpriteRenderer → WorldSprite`，
   `None → Empty`。全部引用点（11 处）同步更新。
2. **保留 `isInstanceOf` 全限定判定**作为二次保险（对"值位置"的遮蔽同样有效）：
   `Type.getClass` + `Type.getSuperClass` 沿继承链比对类对象，与模块作用域无关。

### 7.4 复验

```
neko:  exit 0   [DefinitionRegistry] 候选模块=932 收录类型=933 跳过=0
cpp :  exit 0   [CoverageCheck] 模块总数=2493 类型化成功=2493 失败=0
```

### 7.5 教训（写给后续 agent）

**在声明了 `enum abstract` / `typedef` 的模块里，不要给成员起与类同名的名字。**
Haxe 会把它们提升到模块作用域，静默遮蔽同名的 import，而且 **neko 类型检查查不出来**
（neko 上 `Std.isOfType` 走的是另一条路径，判定仍然正确）——
只有 cpp 运行期才会表现为"判定恒 false"。

**全局排查建议**（同类风险，非本工作包范围）：
```bash
# 找出所有「模块内声明的名字」与「同模块 import 的类名」冲突的文件
grep -rn "enum abstract\|typedef " source/ | ...
```
本工作包只修了 `UiRenderer.hx`；`mvz2/`、`unity/` 下还有大量 `Std.isOfType` 调用点，
建议后续 agent 按同一模式排查（重点：模块里同时有 enum/typedef 与 `Std.isOfType` 的文件）。

