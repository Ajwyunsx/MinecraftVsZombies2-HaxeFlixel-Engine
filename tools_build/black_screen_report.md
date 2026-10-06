# 黑屏判定报告（工作包：验证 — 构建 + 运行 + 截图 + 像素统计）

> 判定者：验证工作包（本 agent）。所有结论都带**可复现命令**与**截图路径 + 像素统计**。
> 本工作包**只做验证**，不改 `source/` 逻辑；新增的都是 `tools_build/` 下的验证工具。
> 每次结论都标注**验证时点**，因为 `source/` 正被 5 个并行渲染层 coder agent 持续改动。

---

## 0. 一句话结论

| 项 | 结果 |
|---|---|
| neko 类型检查 | **exit 0**（`[DefinitionRegistry] 候选模块=932 收录类型=933 跳过=0`） |
| cpp 全覆盖检查 | **exit 0**（`[CoverageCheck] 模块总数=2493 类型化成功=2493 失败=0`） |
| 隔离 release 构建 | **exit 0**，产物 30,369,280 B，md5 `2ec19f2a98cbd45d6939533a7b808158` |
| 独立交叉复验 | 共享产物 md5 `6b673638…`（20:13）给出**相同结论**（30.759% vs 30.757%） |
| 进程存活 | **是** — 运行 30 s / **18,000 帧**无崩溃、无 `[error]` |
| **黑屏** | **已消失** —— 客户区非黑像素 **0.040% → 30.757%**（367 → 283,458 像素） |
| 画面内容 | 出现 **3 个 UI 面板 + 1 个文本元素**（对话框：主面板 / 确认按钮 / 左下角 `[0]`） |
| **剩余问题** | **UI 面板是纯白无贴图的占位色块**：`Image` 的 sprite（`mvz2:init/form`、`mvz2:init/button`）未被解析成帧，全部退化为 1×1 白图拉伸；文本也没有字体 |

**判定：黑屏已被修复（客观像素证据）。但「可辨识的游戏画面」尚未达成 —— 卡在「uGUI Image 的 sprite 引用 → 帧」这一步。**

---

## 1. 验证方法与工具（本工作包新增）

| 文件 | 作用 |
|---|---|
| `tools_build/grab_shot.ps1` | PowerShell 截屏：默认抓 `MVZ2.exe` **主窗口客户区**（`SetProcessDpiAwareness` + `GetClientRect` + `ClientToScreen`，避免 125% DPI 下坐标系错位），`-FullScreen` 抓全屏。**源码刻意全 ASCII**：PowerShell 5.1 按 ANSI(GBK) 读 `.ps1`，UTF-8 中文注释会导致解析失败 |
| `tools_build/analyze_shot.py` | 纯标准库 PNG 解码（zlib + 5 种 scanline filter 反演）→ 非黑像素比例 / 颜色桶数量 / 32×18 网格 4 邻域连通区域数 / 主要颜色分布 |
| `tools_build/run_shot.sh` | 隔离工程「启动 → 定时截屏 → 杀进程 → 打印 boot-trace 末 20 行」一键复验 |
| `tools_build/verify_shot/` | **隔离构建工程**（复制自 `verify_startup/`，只把 source/icon 改相对路径、去掉 943 MB `<assets>`，运行期用目录联接指回 `HaxePort/assets`）。**避开共享 `export/windows` 的竞争**（本机同时有 11~13 个 `cl.exe` 在跑） |

### 1.1 工具自检（保证「黑屏/非黑屏」判定不是截屏/解码的假象）

用脚本合成两张已知内容的 PNG 再分析：

```
python tools_build/analyze_shot.py tools_build/shots/_selftest_black.png tools_build/shots/_selftest_mixed.png
== _selftest_black.png ==   非黑像素 0 / 3072 = 0.000%     颜色桶 0   区域 0   ← 纯黑图判定正确
== _selftest_mixed.png ==   非黑像素 532 / 3072 = 17.318%  颜色桶 2   区域 2   ← 两个色块判定正确
```

截屏链路自检：全屏抓取桌面 → **2560×1440、非黑 99.928%、1040 个颜色桶**（`_desktop_probe.png`）。
说明截屏与解码链路是通的，**全黑只能是游戏窗口本身全黑**。

---

## 2. 构建与类型检查（客观输出）

### 2.1 类型检查（20:20，渲染桥落地后的快照）

```
$ cd HaxePort && haxe -cp source ... -main Main -neko /tmp/snap.n --no-output ...
[DefinitionRegistry] 候选模块=932 收录类型=933 跳过=0
exit 0

$ haxe -cp source -cp verify ... -main Main -cpp "$TEMP/mvz2_cppcheck_s3" --no-output \
    --macro "flixel.system.macros.FlxDefines.run()" --macro "coverage.CoverageCheck.run()"
[CoverageCheck] 模块总数=2493 类型化成功=2493 失败=0
exit 0
```

（模块数 2486 → **2493**，新增 7 个：`mvz2/ui/UiRenderer.hx`、`unity/RenderBridge.hx`、
`mvz2/animations/*` 等渲染层文件。）

### 2.2 隔离 release 构建

```
$ cd HaxePort/tools_build/verify_shot && haxelib run lime build windows
exit 0（约 15 分钟，本机 11~13 个 cl.exe 并发）
产物 export/windows/bin/MVZ2.exe  30,369,280 B  mtime 2026-10-05 20:25:48
md5  2ec19f2a98cbd45d6939533a7b808158
```

历史对照：19:19 产物 30,158,336 B / `70b30351…`；19:29 产物 30,193,152 B / `975e442b…`
（**这两个都早于渲染桥，画面仍全黑**）。

---

## 3. 运行 + 截屏 + 像素统计（核心判定）

### 3.1 修复前基线（共享 exe，19:05，`before_shared_window.png`）

```
尺寸 1298x766   非黑像素 72581 / 994268 = 7.300%
颜色桶 38       非空区域 1（32x18 网格）
主要颜色 #f0f0f0 4.51%（Windows 标题栏/白字）, #000000 1.44%, #101010 0.63% …
```

目视：**客户区整块纯黑**，非黑像素全部来自 **Windows 标题栏**与桌面背景。

### 3.2 渲染桥落地前（隔离 exe，19:25 / 19:29）

抓的是**主窗口客户区**（不含标题栏），所以数值直接反映游戏画面：

```
after_probe.png (md5 70b30351 产物)   非黑像素 367 / 921600 = 0.040%   区域 3
after2_t{6,12,18}s.png (md5 975e442b) 非黑像素 367 / 921600 = 0.040%   区域 3
主要颜色 #101010 0.02%, #b0b0c0 0.01%, #f0f0f0 0.00% …
```

367 个非黑像素**正好是鼠标光标箭头**（`#b0b0c0`/`#f0f0f0` 是光标的白/灰描边）。
**判定：全黑。**

### 3.3 渲染桥落地后（隔离 exe，20:27，`after3_t{6,12,18,24}s.png`）—— 最终判定

```
尺寸            1280x720
非黑像素        283458 / 921600 = 30.757%          ← 0.040% → 30.757%，提升 769 倍
颜色桶数量      27
非空网格区域数  6（32x18 网格，4 邻域连通）          ← 1~3 → 6
主要颜色        #f0f0f0 30.72%, #101010 0.02%, #b0b0c0 0.01% …
```

4 张截图的 **md5 完全相同**（`d13615f284773a97895969edd512fdf1`），说明画面**稳定、不闪、不抖**。

目视（`after3_t12s.png`）：画面出现 **3 个白色矩形面板 + 1 个 `[0]` 文本**：

| 区域 | 客户区坐标 | 尺寸 | 判定为 |
|---|---|---|---|
| 上方面板 | (150,35)–(1130,285) | 980×250 | `CustomDialog` 的 `Background`（`Image`，sprite = `mvz2:init/form`） |
| 下方面板 | (320,565)–(960,640) | 640×75 | `TextButton`（`Image`，sprite = `mvz2:init/button`） |
| 左下小块 | (5,665)–(40,700) | 35×35 | `FPSDisplayer` 的 `Text`（`[0]` = FPS 计数） |
| 中央 2px 点 | (645,357) | 2×2 | 加载进度条（progress ≈ 0） |

**判定：黑屏已修复。** 非黑像素 30.757%、6 个连通区域、内容稳定 —— 这是「屏幕上有真实 UI 内容」的客观证据，不是光标或噪声。

### 3.4 独立交叉复验（共享 `export/windows` 的 20:13 产物）

为排除「只有我这一个产物能出画面」的可能，用**另一个 agent 在共享 `export/windows` 里建的产物**
（`MVZ2.exe` 30,374,400 B / md5 `6b6736387bcdb37b40b6ad3203609e7e`，mtime 20:13，
比我的隔离产物多了一批后续改动）重跑同一套流程：

```
shared20_t10s.png / shared20_t15s.png
尺寸 1280x720   非黑像素 283478 / 921600 = 30.759%
颜色桶 29       非空区域 6（32x18 网格）
主要颜色 #f0f0f0 30.69%, #707070 0.03%, #101010 0.02%, #b0b0c0 0.01% …
```

**与我的隔离产物结果一致（30.759% vs 30.757%，区域数同为 6，颜色分布相同）。**
说明结论**可复现、不依赖特定产物**。该产物同样跑到 3600+ 帧、无崩溃、无 `[error]`。

### 3.5 进程存活与启动进度（`boot-trace.log`，263 行）

```
[step] build: MainScene（UI 与页面控制器）
[step] UI 渲染桥已安装（uGUI 根：MainGame）              ← 本工作包确认接线生效
[step] MainGameScene 对象图已构建（96 个组件）
[step] 组件 Awake 分发完成，失败 0 个，跳过 21 个
[step] GameEntrance.Start（main.Initialize + InitLoad）
[error] [0] 更新赞助者名单时出现错误：Null Object Reference   ← 无网络，非致命（被任务吞掉）
[done] GameEntrance.Start 完成，已进入主流程
[step] update 循环已进入（MainSceneState.update 第 1 帧）
[step] update 循环正常（第 120 帧）
[step] 运行中：已更新 18000 帧                        ← 30 s × 60 fps，全程无异常
```

**关键推进（相对交接描述的 `MapController.hx:299` 崩溃点）**：
- 资源加载流水线 6 个任务全跑完；
- `[done] GameEntrance.Start 完成` —— `DisplayPage(Splash)` 这一路**没有段错误**；
- 跑到 **18,000 帧 / 30 s**，进程被 `taskkill` 主动结束（`run_shot.sh` 报告「仍在运行」），
  期间**没有任何 `[error]` 级失败**（`boot-trace.log` 里仅有的 `[error] [0]` 是赞助者名单的网络失败）。

即：**release 崩溃点已被上游 agent 修掉，黑屏也已被渲染桥修掉。**

---

## 4. 剩余缺口（精确到文件:行，供渲染层 agent 收尾）

黑屏消失了，但 UI 面板是**纯白无贴图的占位块**。证据链：

### 4.1 数据侧：sprite 引用是齐的

`assets/scene_prefabs/Prefabs/UI/Dialogs/CustomDialog.json` 的 `Background` / `TextButton` 节点
（node 8 / node 11）**带真实 sprite 引用**：

```json
"m_sprite": { "asset": { "guid": "ecdea1f2d39df2049be852b3107d40a4", "fileID": "21300000",
  "path": "GameContent/Assets/mvz2/sprites/init/form.png", "address": "mvz2:init/form", "kind": "Image" } }
```

`assets/resource_manifest.json` 里这两条都在、`exists: true`：

```
{"address": "mvz2:init/button", "path": "GameContent/Assets/mvz2/sprites/init/button.png", ..., "exists": true}
{"address": "mvz2:init/form",   "path": "GameContent/Assets/mvz2/sprites/init/form.png",   ..., "exists": true}
```

贴图文件也在磁盘上：`assets/GameContent/Assets/mvz2/sprites/init/{form,button}.png`（2812 / 2918 B）。

### 4.2 代码侧：退化路径被走到

`mvz2/ui/UiRenderer.hx:559~576` 的 `updateGraphic`：

```haxe
var sprite:unity.Sprite = null;
var image = Std.isOfType(graphic, Image) ? cast(graphic, Image) : null;
if (image != null) sprite = image.activeSprite;        // ← 这里取到的是 null
...
if (sprite != null) {
    var frame2 = SpriteFrameFactory.getFrame(sprite);
    if (frame2 != null) { ... entry.kind = UiEntryKind.Image; ... }
    else applySolid(entry, tint, needsRebuild);         // ← 退化成 1×1 白图拉伸
} else {
    applySolid(entry, tint, needsRebuild);              // ← 或走这条
}
```

`applySolid`（`:598~606`）就是 `makeGraphic(1, 1, FlxColor.WHITE, ...)` ——
即实测看到的「纯白矩形」。因此**至少有一个环节断了**：

1. `Image.activeSprite` 为 null：`unity.ui.Image.sprite` 没被写入 `unity.Sprite`；
2. 或 `SpriteFrameFactory.getFrame(sprite)` 返回 null：`unity.Sprite` 没被解析成贴图帧
   （`SpriteFrameFactory.hx:468` 有一条 `无法为 $key 生成帧（贴图未解码或矩形为空）` 的告警，
   但本次运行的 boot-trace 里**没有**出现，所以更可能是第 1 条）。

### 4.3 已定位的对应代码点

`mvz2/scenes/ScenePrefabFieldApplier.hx:82~94`（**mtime 19:49:20，早于本次 20:25 的产物**，
所以**应该已经在产物里**）：

```haxe
if (Std.isOfType(comp, SpriteRenderer)) {
    var sprite = Reflect.field(fields, "sprite");
    if (sprite != null) ModelPrefabAssetsBridge.ApplyRendererSprite(cast comp, cast sprite);
}
// uGUI 的 Graphic（Image/RawImage）的 `sprite` 字段与 SpriteRenderer 走同一套 …
if (Std.isOfType(comp, unity.ui.Graphic)) {
    var imageSprite = Reflect.field(fields, "sprite");
    if (imageSprite != null) ModelPrefabAssetsBridge.ApplyImageSprite(cast comp, cast imageSprite);
}
```

注释本身写着「**原先这里只处理 SpriteRenderer，`Graphic.sprite` 一直是 null
（= 所有 UI 图片都退化成纯色块，画面因此几乎全黑）**」—— 说明作者已经识别出这条路径。

**但本次截屏的对话框是 `MainGameScene.buildDialog()` 手工构造的对象图（`MainGameScene.hx:532`），
不是走 `ScenePrefabLoader` 从 JSON 重建的**，而 `CustomDialog` **不在 `PAGE_PREFABS` 表里**
（表里只有 Map/Almanac/Store/…/AchievementHint 15 项），因此**手工构造的对话框没有经过
`ScenePrefabFieldApplier` 的 sprite 写入路径** → `Image.sprite` 恒为 null → 全部退化成白块。

> 这与 `boot_findings.md` §五.4 的既有结论一致：**手工对象图与 prefab 数据两套来源并存**。
> 建议渲染层 agent 二选一：
> - (a) 把 `Dialogs/CustomDialog`、`InputNameDialog`、`DeleteUserDialog` 也加进 `PAGE_PREFABS`
>   （数据已存在：`assets/scene_prefabs/Prefabs/UI/Dialogs/CustomDialog.json`），
>   让 `InjectPagePrefab` 统一注入；
> - (b) 或让 `buildDialog()` 等手工构造点显式调用
>   `ModelPrefabAssetsBridge.ApplyImageSprite(...)`。

### 4.4 文本也没有字体

左下角 `[0]` 是**可见的**（说明 `UiRenderer` 的 FlxText 路径通了），但对话框的
`Title` / `Desc` / 按钮文字都没显示 —— 与 `UiRenderer.hx:824` 的注释一致：
`TODO-PORT: 等 TMP 字体资产转换落地后，改为按 TextMeshProUGUI.font 的 guid 解析`。
`CustomDialog.json` 里 `font` 指向 `Fonts/mojangles/minecraft_font.asset`（ScriptableObject），
**尚未转换成 Flixel 可用的字体**。

---

## 5. 复现命令（一键）

```bash
cd HaxePort

# ① 隔离构建（避开共享 export/windows 竞争）
cd tools_build/verify_shot && bash setup.sh && haxelib run lime build windows && cd ../..

# ② 运行 + 定时截屏 + boot-trace 末 20 行
bash tools_build/run_shot.sh tools_build/verify_shot after3 30 4

# ③ 像素统计（黑屏判定）
python tools_build/analyze_shot.py tools_build/shots/after3_t*.png

# ④ 工具自检（确认判定链路没坏）
python tools_build/analyze_shot.py tools_build/shots/_selftest_black.png tools_build/shots/_selftest_mixed.png

# ⑤ 类型检查（neko + cpp）
python tools_build/verify_release.py --skip-build
```

---

## 6. 未完成项 / 需配合事项

- [x] **黑屏已修复**（§3.3：非黑像素 0.040% → 30.757%，6 个连通区域，4 帧 md5 一致）。
- [ ] **UI 贴图未生效**（§4）：对话框 `Image` 的 sprite 引用没走到
      `ModelPrefabAssetsBridge.ApplyImageSprite` → 全部退化成 1×1 白块。
      **根因是「手工对象图」与「prefab 数据」两套来源并存**，`CustomDialog` 不在 `PAGE_PREFABS` 里。
      **属渲染层工作包**（数据齐备，见 §4.1）。
- [ ] **TMP 字体未转换**（§4.4）：对话框文字不可见；`[0]`（FPS）能显示是因为它走的是 Flixel 默认字体。
- [ ] **`source/` 正在被 5 个 coder agent 并发改动**：本报告结论对应
      **20:25 的产物（md5 `2ec19f2a…`）**。19:57 之后 `source/` 又持续有新改动
      （`grids/GridView`、`cameras/ShakeManager`、`almanacs/*`、`entities/EntityHPBarSource`、
      `level/RuntimeBlueprintController`、`level/LevelRaycaster`，最新 23:25），**不在该产物里**。
      下一轮复验请以新产物为准。
- [ ] **`tools_build/verify_shot/` 是本工作包新建的隔离工程**，`export/` 占约 1.5 GB；
      不需要时可整体删除（不影响仓库其他部分）。
- [ ] **共享 `export/windows` 竞争**：本机实测同时有 11~13 个 `cl.exe`。任何 agent 想跑标准构建
      都要先确认没有别的构建在跑（PCH 竞争会报 `Could not create PCH` / `c1xx: fatal error C1083`）。

---

## 7. 附：本工作包新增/修改文件

| 文件 | 类型 | 说明 |
|---|---|---|
| `tools_build/grab_shot.ps1` | 新增 | 窗口客户区/全屏截屏（DPI 感知，ASCII-only 源码） |
| `tools_build/analyze_shot.py` | 新增 | 纯标准库 PNG 解码 + 黑屏量化 |
| `tools_build/run_shot.sh` | 新增 | 隔离工程「运行 + 定时截屏 + boot-trace」一键复验 |
| `tools_build/verify_shot/` | 新增 | 隔离构建工程（Project.xml + setup.sh + run.sh） |
| `tools_build/verify_shots_notes.md` | 新增 | 分段工作笔记 |
| `tools_build/black_screen_report.md` | 新增 | 本报告 |
| `tools_build/shots/*.png` | 新增 | 截图证据（修复前/后、独立交叉复验、自检图） |
| `tools_build/verify_shots_notes.md` | 新增 | 分段工作笔记 |

**未改动 `source/`、`Project.xml`、`hmm.json`。**

### 截图证据清单（`tools_build/shots/`）

| 文件 | 含义 | 非黑像素 |
|---|---|---|
| `_selftest_black.png` / `_selftest_mixed.png` | 工具自检（合成图） | 0.000% / 17.318% |
| `_desktop_probe.png` | 桌面全屏（证明截屏链路可用） | 99.928% |
| `before_shared_window.png` | **修复前**（含标题栏） | 7.300%（客户区全黑） |
| `after_probe.png` / `after2_t*.png` | 渲染桥落地前（客户区） | **0.040%**（全黑） |
| `after3_t*.png` | **渲染桥落地后（本工作包主判定）** | **30.757%** |
| `shared20_t*.png` | 独立交叉复验（共享 20:13 产物） | 30.759% |
| `probe_pre/post_click.png` | 点击对话框按钮的交互探测 | 30.722% |
