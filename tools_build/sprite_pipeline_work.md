# 精灵/贴图纸张接线到 Flixel（工作包：精灵渲染接线）

> 状态：**核心已完成**，冒烟测试 neko/cpp 均全过。最后更新：2026-10-05。
> 目标：让 `unity.Sprite` 真正产出可给 Flixel 用的帧，并让 `SpriteRenderer` 把它落到渲染对象上；
> 统一「贴图解码」的唯一来源，消除工作包 ③ 指出的重复解码。

---

## 0. 一句话结论

| 项 | 结果 |
|---|---|
| `unity.Sprite` → `FlxFrame` / `FlxImageFrame` / `FlxAtlasFrames` | **已打通**（`mvz2/sprites/SpriteFrameFactory.hx`） |
| 贴图解码唯一来源 | **已统一**（`ResourceManifest.loadImageByPath`；`SpriteTextureCache` 复用它） |
| `unity.SpriteRenderer` → 渲染对象 | **已接线**（`sprite` setter 钩子 → `renderSprite:FlxSprite`） |
| prefab 的 `m_Sprite {guid,fileID}` → 单帧精灵 | **已接线**（`SpriteManifestLoader.getSpriteDefinitionByAssetRef` + `ModelPrefabAssets`） |
| 冒烟测试 | `tools_build/check_sprites.sh`，**逐项 302 项全过；全量 709 精灵 + 1222 帧全过** |
| 类型检查 | neko `模块总数=2493 失败=0` / cpp `模块总数=2493 失败=0`，均 exit 0 |
| 未完成 | `renderSprite` 进 Flixel 显示列表（属渲染层/场景包，见 §4） |

---

## 1. 改动清单

| 文件 | 类型 | 说明 |
|---|---|---|
| `source/mvz2/sprites/SpriteFrameFactory.hx` | **新增** | 核心：贴图→FlxGraphic、unity.Rect→FlxFrame、图集→FlxAtlasFrames、渲染器接线 |
| `source/unity/SpriteRenderer.hx` | 改 | `sprite` 改为 get/set（赋值触发 `spriteApplier` 钩子）；新增 `renderSprite:FlxSprite` |
| `source/unity/Texture2D.hx` | 改 | 新增 `graphic:FlxGraphic` / `assetPath:String`（贴图 → 已解码像素的唯一挂点） |
| `source/unity/addressableassets/ResourceManifest.hx` | 改 | 新增 `pathIndex` + `loadByPath`/`loadImageByPath`/`bitmapDataOf`；`decodeImage` 关 `destroyOnNoUse` |
| `source/mvz2/sprites/SpriteManifestLoader.hx` | 改 | 新增 `getSpriteDefinitionByAssetRef(guid, fileID)` / `sheetAsSingleSprite` + guid 索引 |
| `source/mvz2/sprites/SpriteTextureCache.hx` | 改 | `getTexture` 优先走 `ResourceManifest`（复用同一份解码），回填 `texture.graphic` |
| `source/mvz2/models/ModelPrefabAssets.hx` | 改 | 解析顺序加一档「guid[:fileID] → 精灵清单」；`ApplyRendererSprite` 直接写 `sprite` |
| `source/mvz2/models/ModelManager.hx` | 改 | `AlignAllChildrenSpriteRenderers` 恢复 C# 原逻辑（unity.Sprite 用 rect/pivot/PPU，FlxSprite 才用近似） |
| `verify/sprites/SpriteFrameSmokeMain.hx` | **新增** | cpp/neko 可跑的逐项冒烟测试（302 项） |
| `verify/sprites/AllSheetsSmoke.hx` | **新增** | 全量取帧检查（709 精灵 + 222 图集 / 1222 帧） |
| `tools_build/check_sprites.sh` | **新增** | 一键跑冒烟测试（默认 cpp；`--all` 全量，`--neko` 快速） |

**没有改**：`Project.xml`、`hmm.json`、`source/Main.hx`、清单生成脚本。

---

## 2. 关键设计决定

### 2.1 坐标系换算（Unity 左下角 → Flixel 左上角）

```
flixelY = textureHeight - unityY - unityHeight
origin  = (pivot.x * frameWidth, (1 - pivot.y) * frameHeight)
```
`textureHeight` 用**解码后的实际像素高度**（不是清单里的 `height`，两者曾出现不一致）。
`origin` 换算对 alignment 推导出的 pivot 全部成立：
- alignment 6 (BottomLeft) → pivot (0,0) → origin (0, h)
- alignment 7 (Bottom) → pivot (0.5, 0) → origin (w/2, h)
- alignment 0 (Center) → pivot (0.5,0.5) → origin (w/2, h/2)

### 2.2 帧集合的组织（踩到的三个 Flixel 坑，都会静默画错/崩）

1. **`FlxImageFrame.fromFrame(frame)` 会回收帧自己的矩形。**
   它把 `source.frame` 交给 `FlxImageFrame.findFrame`，而 `FlxRect.equals` 内部对传入矩形调
   `putWeak()`（Flixel 对象池回收）。帧的 `frame` 矩形因此被放回池子，下一次 `FlxRect.get()`
   就把它拿走改值 —— 实测表现为「第二个精灵的帧矩形错乱」。
   **解法**：`FlxImageFrame.fromEmptyFrame(graphic, rect)` 建集合（不碰传入矩形），
   再把 `frames[0]` 换成真实帧（见 `SpriteFrameFactory.makeImageFrame`）。

2. **`FlxGraphic` 默认 `destroyOnNoUse = true`。**
   `FlxSprite.frames = 其它集合` 会让旧 graphic 的 useCount 归零 → flixel 把它从位图缓存移除并
   `destroy()`，于是**位图与之前所有帧一起失效**（实测：第二个渲染器赋值后第一个贴图的
   `frameCollections` 变 null，再取帧就 `Invalid field access : get`）。
   **解法**：`ResourceManifest.decodeImage` 与 `SpriteFrameFactory.toGraphic` 都显式
   `graphic.destroyOnNoUse = false`（移植层把这些 graphic 当常驻资源，与 Unity 的资产引用语义一致）。

3. **一个 FlxGraphic 上只能有一个「自建帧集合」。**
   `FlxFramesCollection` 构造函数会自动挂到 `parent.addFrameCollection`；重复挂载会刷
   `Attempting to add already added collection` 告警。本包按 FlxGraphic 缓存唯一集合（`framesOf`），
   帧下标因此稳定。

### 2.3 解码唯一来源（修掉工作包 ③ 指出的重复解码）

```
ResourceManifest.loadImageByPath(path)  ──┐
                                          ├─→ FlxGraphic（loadedAssets 按路径缓存，只解一次）
SpriteTextureCache.getTexture(def)      ──┘        │
                                                   └→ texture.graphic（贴图 → 像素的唯一挂点）
```
- `ResourceManifest` 新增 `pathIndex`（assets 相对路径 → 定位符）与 `loadByPath`：
  精灵清单里的贴图只有 `assetPath`（`GameContent/Assets/.../x.png`），没有 Addressables 地址；
  按路径取值即可复用同一份 `loadedAssets` 缓存。
- `SpriteTextureCache.getTexture` 改为优先走 `SpriteFrameFactory.getGraphic(texture)`；
  只在清单缺失（独立运行的自检程序没有 assets 根）时回退到直接读盘（带 `TODO-PORT`）。
- 冒烟测试断言：`texture.graphic == ResourceManifest 的 FlxGraphic`、
  `SpriteTextureCache.getBitmapData(texture) == graphic.bitmap`、重复取值 20 次 `decodeCount` 不变。

### 2.4 prefab 资产引用（`m_Sprite: {fileID, guid}`）

Unity 里 prefab 的精灵引用由资产系统解析；移植层按 `guid`（贴图 guid）+ `fileID`
（贴图 `.meta` 里该 Sprite 子资源的 `internalID`）反查 `sprites_manifest.json`：
- `fileID` 空 / `21300000`（Unity 主资产 fileID）→ 整图单帧；
- 其它 `fileID` → `spriteMode=2` 贴图的某个切片（即图集某一帧）；
- 未知 → null（调用点按「无法还原 = 无匹配资源」处理）。

接线点：`ModelPrefabAssets.resolveFromRegistry`（模型 prefab）与
`ScenePrefabFieldApplier`（场景 prefab，经 `ModelPrefabAssetsBridge` 走同一条路径）。

---

## 3. 验证

### 3.1 冒烟测试
```
bash HaxePort/tools_build/check_sprites.sh            # cpp（与游戏同目标），逐项断言
bash HaxePort/tools_build/check_sprites.sh --neko     # 快速
bash HaxePort/tools_build/check_sprites.sh --all      # 全量取帧（709 精灵 + 222 图集），只统计
bash HaxePort/tools_build/check_sprites.sh --all --neko
```
逐项版覆盖：26 个单帧精灵（entity / ui / level / map / misc / shading / artifacts / products /
icons / achievements / init）+ 13 个图集（entity / characters / ui / level / misc）+
prefab 资产引用 + 坐标系纯函数。关键断言：
- 帧矩形与清单 `rect` 一致、y 换算正确、帧在贴图范围内；
- 图集帧顺序/名字表可用（`getByName` == `frames[0]`）；
- `frame.paint()` 的像素与位图对应区域**逐像素相同**（证明真实解码 + y 翻转正确）；
- 贴图只解码一次；`FlxSprite.frames` 赋值后 `frameWidth/frameHeight/origin` 正确；
- `guid+fileID` 解析出的单帧精灵能生成帧、交给 `SpriteRenderer` 后帧宽正确。

**实测**：
```
逐项 neko: 检查项 302，失败 0，说明 0 → [sprites] 全部通过
逐项 cpp : 检查项 302，失败 0，说明 0 → [sprites] 全部通过（exit 0）
全量 neko: sprites: 709 取帧失败 0 / sheets: 222 帧总数 1222 失败 0 / decodeCount=931 failure=0
全量 cpp : sprites: 709 取帧失败 0 / sheets: 222 帧总数 1222 失败 0 / decodeCount=931 failure=0
```
**`decodeCount=931` 正好等于清单里被精灵/图集引用的唯一贴图数**
（`sprites_manifest.json` 的 931 条 `resourceManifestResolved`），即**没有重复解码**。

> 注意：cpp 冒烟程序**不要并发跑两份**（默认输出目录 `$TEMP/mvz2_sprite_smoke` 是共享的，
> 两个 MSVC 同时写 `obj/msvc1964/__pch/haxe/hxcpp.pch` 会报 `C1083 Could not create PCH`）。
> 并发时用 `MVZ2_SPRITE_SMOKE_OUT=<独立目录>` 隔离。

### 3.2 类型检查（全工程）
```
neko: [CoverageCheck] 模块总数=2493 类型化成功=2493 失败=0  → exit 0
cpp : [CoverageCheck] 模块总数=2493 类型化成功=2493 失败=0  → exit 0
```
另有本包模块集合的定向检查（32 个直接受影响的模块）：失败 0。

> 备注：验证过程中一度被其它 agent 的**并行编辑**打断（`mvz2/animations/AnimatorRuntime.hx`
> 19:44~19:45 语法未完成、`mvz2/ui/UiRenderer.hx` 19:40~19:43 的 `CanvasScaler.ScaleMode`
> 与 `unity.Texture`/`Texture2D` 不匹配、`mvz2/states/MainSceneState.hx` 19:37 引用尚不存在的
> `unity.tmpro.TextAlignmentOptions` 顶层导入）。这些文件**不是本包改的**；等它们落盘后重跑即全绿
> （上表就是重跑结果）。

---

## 4. 未完成项 / 需要配合

1. **`renderSprite` 还没有进 Flixel 显示列表。**
   本包只做到「unity.Sprite → 带正确帧的 FlxSprite」，并挂在 `SpriteRenderer.renderSprite` 上。
   把它加进 `FlxState` / `FlxGroup`（按 `sortingLayerName`/`sortingOrder` 排序、跟随
   `unity.Transform` 的位置/缩放/旋转）属于**渲染层 / 场景与 prefab 包**：
   - 落点建议：`source/mvz2/scenes/ScenePrefabLoader.hx`（场景树遍历）+ 一个 `FlxGroup` 根；
   - `unity.Camera` / `Canvas` 的显示顺序需要与 `SortingLayers` 对齐。
2. **`unity.ui.*`（uGUI）仍不渲染。** `Image` / `RawImage` / `Text` 都是逻辑 shim；
   它们持有 `Sprite`/`Texture` 引用，可用 `SpriteFrameFactory.getFrame(sprite)` /
   `getWholeImageFrame(texture)` 产出帧，但「RectTransform 布局 → FlxSprite 位置/尺寸」
   需要 UI 渲染层实现（属 UI 包）。`mvz2/ui/UiRenderer.hx` 正在做这件事（并行 agent）。
3. **`SpriteRenderer.sortingLayerID` 缺失**（shim 只有 `sortingLayerName`）。
   `ModelPrefabFieldApplier.applySpriteRenderer` 里已记 `missing(...)`；渲染层要按层排序时需补。
4. **`unity.Sprite.border` / `Image.type=Sliced` 的九宫格拉伸**未实现（shim 有字段，无渲染语义）。
5. **`AnimatedSpriteSetter` 那类「按帧序列切换」的组件**目前只能拿到单帧；
   若要用 Flixel 的 `animation.addByPrefix`，需要用 `SpriteFrameFactory.getAtlasFrames(sheet)`
   （本包已提供，图集帧带名字）——这属于模型/动画包的接线。
6. **两个精灵不经过任何 SpriteManifest，因此 `ResourceManager` 目前不会把它们填进
   `ModResource.Sprites`**（原工程同样如此，属**既有缺口**，非本包引入）：
   `entity/boss/red_dragon`、`level/ship/cloudy_noise` 的 `manifestLabels` 只有 `["Main"]`
   （没有 `SpriteManifest`），而 `LoadInitSpriteManifests`/`LoadMainSpriteManifests` 都按
   `Intersection("Main"/"Init", "SpriteManifest")` 加载。
   原工程里本应由 `ResourceManager_Sprites.LoadSprites`（按标签 `Sprite`）兜住，但
   `ResourceManager.cs:197` 有一个同名的**局部函数** `LoadSprites(TaskProgress)` 遮蔽了
   成员方法 `LoadSprites(string)`，后者成为死代码（`ResourceManager_Sprites.cs:163` 无调用点）。
   这属于资源管理包；本包不动它，只报告。若上游确认要补，本包的取帧路径无需改动
   （这两条精灵的 `texture/rect` 都是完整的，`SpriteFrameFactory.getFrameOfDefinition` 可用）。

---

## 5. `sprites_manifest.json` 缺口核对（不改清单生成器，仅报告）

- **字段齐全**：`sprites` 709/709、`spriteSheets` 222/222、`textures` 988/988 都有本包需要的字段
  （`rect/pivot/pivotRaw/alignment/pixelsPerUnit/texture/assetPath` 等）。**没有缺字段导致取不到帧的情况。**
- **实际核对**：977 张贴图的解码尺寸与清单 `width/height` **完全一致**；
  709 个单帧精灵的 `rect` 都等于整张贴图；222 个图集共 0 个越界切片。
- **7 张贴图在镜像里不存在**（清单声明存在，属工作包 ① 的资源转换缺口）：
  `Tests/TextureWarp/sample.png`、`Icons/Windows/Icon16x.png`、`Icons/Windows/Icon1024x.png`、
  `Icons/Android/IconAndroid192x.png`、`Icons/Android/IconAndroidForeground432x.png`、
  `Icons/Android/IconAndroidBackground432x.png`、`TextMesh Pro/Sprites/EmojiOne.png`。
  **它们不挂在任何精灵/图集上**（`sprites`/`spriteSheets` 里没有条目引用这 7 个 guid），
  所以对精灵取帧没有影响，只是 `ResourceManifest.loadImageByPath` 会返回 null 并告警。
