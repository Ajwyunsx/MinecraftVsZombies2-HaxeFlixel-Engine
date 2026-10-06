# MVZ2 Unity → HaxeFlixel 移植规范 (PORTING GUIDE)

本项目将 `MinecraftVsZombies2Unity`（Unity 2022.3 / C#）1:1 移植为 HaxeFlixel 工程（结构参照 FNF Psych Engine）。
所有移植 agent **必须**遵守本规范，保证 10 个并行工作包产出风格一致、可互相引用。

## 目录结构（Psych Engine 风格）

```
HaxePort/
├── Project.xml          # lime/openfl 工程文件（已存在，勿改）
├── hmm.json             # 依赖锁定（已存在，勿改）
├── source/
│   ├── Main.hx          # 入口（已存在，勿改）
│   ├── mvz2/            # namespace MVZ2.*        ← Assets/Scripts/MVZ2, Assets/Scripts/View, Assets/Scripts/Vanilla
│   ├── mvz2logic/       # namespace MVZ2Logic.*   ← Assets/Scripts/Logic
│   ├── pvzengine/       # namespace PVZEngine.*   ← Assets/Scripts/Logic 中 PVZEngine 命名空间的文件
│   ├── expressionevaluator/ ← Assets/Scripts/ExpressionEvaluator
│   └── unity/           # UnityEngine API 兼容层（shims）
└── assets/              # 资源（后续整合阶段处理）
```

## 命名映射规则

- C# `namespace MVZ2.Level.Components` → Haxe `package mvz2.level.components;`（全小写）
- 类名、接口名、枚举名、字段名、属性名、方法名 **保持完全不变**（包括大小写，如 `levelEasy`）。
- 一个 C# 文件 → 一个同名 `.hx` 文件（`Foo.cs` → `Foo.hx`）。文件中多个顶层类时，主类用文件名，其余类放同文件底部（Haxe 允许一个模块多类型）。
- `Assets/Scripts/View/*`（namespace `MVZ2.View.*`）→ `source/mvz2/view/*`
- `Assets/Scripts/Vanilla/Frameworks/*`（namespace `MVZ2.Vanilla.*`）→ `source/mvz2/vanilla/*`
- `Assets/Scripts/Vanilla/GameContent/*`（namespace `MVZ2.GameContent.*`）→ `source/mvz2/gamecontent/*`
- `Assets/Scripts/MVZ2/*`（namespace `MVZ2.*`）→ `source/mvz2/*`

## C# → Haxe 类型/语法映射

| C# | Haxe |
|---|---|
| `string` | `String` |
| `int` / `long` | `Int` / `haxe.Int64` |
| `float` / `double` | `Float` |
| `bool` / `void` | `Bool` / `Void` |
| `object` | `Dynamic` |
| `List<T>` | `Array<T>`（`.Add(x)`→`.push(x)`，`.Count`→`.length`，`.Remove`→`.remove`，`[i]` 不变） |
| `Dictionary<K,V>` | `Map<K,V>`（`[k]=v`→`.set(k,v)`，`[k]`→`.get(k)`，`.ContainsKey`→`.exists`） |
| `HashSet<T>` | `Map<T,Bool>` 或 `Array<T>` 辅助 |
| `Action` / `Action<T>` / `Func<T>` | `Void->Void` / `T->Void` / `Void->T` 函数类型 |
| `event Action X` | `flixel.util.FlxSignal`，或 `Array<Void->Void>` + `dispatch()` 方法 |
| `T?`（可空） | `Null<T>` |
| `enum E { A, B }` | `enum abstract E(Int) { var A = 0; var B = 1; }`（有 flags 时保留位运算），纯符号枚举可用 `enum E { A; B; }` |
| `switch` | Haxe `switch`（语法兼容，注意 case 穿透改为显式逻辑） |
| `foreach (var x in xs)` | `for (x in xs)` |
| `base.Foo()` / `base.field` | `super.Foo()` / 直接访问字段 |
| `is` / `as` 类型判断转换 | `Std.isOfType(x, T)` / `cast x`（或 `Std.downcast`） |
| `typeof(T)` | 不需要时省略；需要运行期类型信息用 `Type.resolveClass("pack.T")` |
| `?.` / `??` | 手动判空或使用 `haxe.ds.Option`（简单情形直接 `if (x != null)`） |
| `[Attribute]` 装饰 | 保留为 Haxe 元数据 `@:attributeName(...)`；无对应语义时注释保留原文 |
| `const string X = "y"` | `public static inline var X:String = "y";` |
| `static class` | `class X { private function new() {} ... }` 或直接用 `class X` 全静态成员 |
| `partial class` | 合并为一个类文件（同名分部合并；资源管理器分部按 `ResourceManager.hx` 单文件合并） |
| `interface IFoo` | `interface IFoo { ... }`（Haxe 原生支持） |
| `abstract` 类/方法 | Haxe `abstract` 关键字语义不同 → 抽象类仍写 `class`，抽象方法 `throw "abstract"` 或留空，注释标注 `// abstract` |
| `struct` | 改为 `class`（或 `@:structInit` 仅用于简单数据）；Unity 数学 struct 用 unity shim |
| LINQ（`.Where/.Select/.FirstOrDefault`） | `Lambda.filter/Lambda.map/Lambda.find` 或显式 for 循环 |
| `nameof(X)` | `"X"` 字符串字面量 |
| 字符串插值 `$"a{b}c"` | `'a${b}c'`（单引号） |
| `try/catch(Exception e)` | `try {...} catch (e:Dynamic) {...}` |
| `using (var x = ...)` | Haxe **没有** `finally`，也没有 `using`：改为 `try { ... } catch (e:Dynamic) { x.Dispose(); throw e; }` 并在其后补一次 `x.Dispose();`（正常路径），保证语义等价 |

## UnityEngine API 兼容层（package `unity`）

所有 Unity 引擎类型一律引用 `unity.*` 兼容层（由 core 工作包建立；**你需要的 shim 不存在时，在 `source/unity/` 下自行新增最小实现**，类名与 Unity 一致）：

- `UnityEngine.Vector2/Vector3/Vector4/Quaternion/Rect/Color/Color32` → `unity.Vector2` 等（值语义类）
- `UnityEngine.Mathf` → `unity.Mathf`
- `UnityEngine.Random` → `unity.Random`（静态方法同名）
- `UnityEngine.Time`（`deltaTime` 等）→ `unity.Time`（内部桥接 `FlxG.elapsed`）
- `UnityEngine.GameObject/Transform/MonoBehaviour/Component` → `unity.GameObject` 等（底层组合 `flixel.FlxBasic/FlxSprite/FlxGroup`）
- `SpriteRenderer/Animator/AudioSource/ParticleSystem` → 对应 shim（底层 `FlxSprite`/`FlxAnimationController`/`FlxSound`）
- `Application.persistentDataPath` 等 → `unity.Application`
- `SceneManager` → 游戏状态切换映射为 `FlxG.switchState`
- `UnityEngine.Object.Destroy(obj)` → `unity.UnityObject.destroy(obj)`（底层 `kill()/destroy()`）
- `Instantiate(prefab)` → 工厂方法或 `unity.GameObject.instantiate`
- 序列化字段 `[SerializeField] private T x;` → `@:serializeField private var x:T;`（或普通 private var + 注释）

## 协程（IEnumerator / yield）移植模式

C# 协程统一移植为 `unity.Coroutine` 辅助类的步骤函数：

```haxe
// C#: IEnumerator Foo() { yield return new WaitForSeconds(1); DoX(); }
function Foo():Coroutine {
    return Coroutine.create(function(co:CoroutineContext) {
        co.wait(1);
        DoX();
    });
}
```

`co.wait(seconds)`、`co.waitFrames(n)`、`co.yieldBreak()` 由 core 包提供。启动协程：`StartCoroutine(Foo())` → `coroutineRunner.start(Foo())`。

### `yield return 子协程` 必须写成 `co.waitCoroutine(...)`

C# 的 `yield return SomeCoroutine()` / `yield return StartCoroutine(sub)` 语义是「挂起本协程直到 sub 结束」，
由 Unity 引擎负责驱动 sub。移植层用 **`co.waitCoroutine(sub)`** 表达（`unity/Coroutine.hx` 已实现，
且对「未被显式启动的子协程」会自动接手驱动）。

**禁止**写成工厂轮询：

```haxe
// ✗ 错误：重放模型下每次恢复都会重新调用工厂，拿到一个全新的、无人驱动的子协程，循环永不退出
var inner = SomeFactory();
while (inner != null && !inner.finished) co.waitFrames(1);

// ✓ 正确
co.waitCoroutine(SomeFactory());
```

原因见 `unity/Coroutine.hx` 的「重放模型取舍」：Haxe 无法从函数体中间恢复执行，恢复时是从函数体开头重放，
因此局部变量会被重新初始化、挂起点之前的语句会重跑。

### 协程由谁驱动：`unity.BehaviourRegistry`

Unity 由引擎推进**场景内全部** MonoBehaviour 的协程。移植层的登记点是 `unity.BehaviourRegistry`：

- **登记**：`GameObject.AddComponent` 时自动登记（与 `RenderBridge` 登记 SpriteRenderer 同一模式）。
  覆盖 `ScenePrefabLoader` 建出来的关卡场景树与页面 prefab 子树 —— 这些组件**不在**
  `MainGameScene.behaviours` 里（那张表只收显式 `new` + `attach` 的组件），原先无人驱动。
- **驱动**：`FlxG.signals.postUpdate`（排在 `_state.tryUpdate` 之后，与 Unity「先 Update、后恢复协程」一致）。
- **淘汰**：对象销毁（`UnityObject.destroy` 置 `destroyed`）后由 `step()` 里的 `prune()` 移除。

行为回归护栏：`bash HaxePort/tools_build/check_level_chain.sh`（`--neko` 快、默认 `--cpp` 与游戏同目标）。

## 其他约定

- **不移植**：`Assets/Scripts/Editor/**`（Unity 编辑器专用）、`*.asmdef`、`*.meta`。
- 每个文件顶部保留原文件路径注释：`// Ported from: Assets/Scripts/Logic/Level/LevelController.cs`
- 遇到 Haxe 无法直接表达且 shim 也解决不了的内容（unsafe 代码、反射重逻辑、Addressables、TextMeshPro 富文本内部实现），用等价 Haxe/lime/openfl/Flixel API 实现，并加 `// PORT-NOTE:` 注释说明差异。
- 不要发明原代码不存在的功能；不要删减原有逻辑。**1:1 还原优先于编译完美**——若某处无法确定如何移植，原样翻译并在行尾加 `// TODO-PORT: <原因>`。
- 属性 `{ get; set; }`：简单自动属性直接 `public var x:T;`；有逻辑的属性用 `public var x(get, set):T;` + `function get_x()` / `function set_x(v)`。
- 泛型约束、扩展方法：扩展方法改为静态普通方法，调用处改为静态调用或 `using` 等价。
- 事件 `+=` / `-=`：`FlxSignal.add/remove` 或数组 push/remove。
- `namespace A { namespace B {} }` 嵌套 → 合并包路径 `a.b`。
- 完成后在回复中报告：移植文件数、新建的 unity shim 列表、TODO-PORT 数量。

## 构建与验证（2026-10-02 起适用）

### 类型检查（快速，约 35 秒）
在 `HaxePort/` 下：

```
haxe -cp source -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl \
  -lib hscript -lib hxjsonast -lib json2object -main Main -neko /tmp/check.n --no-output \
  -D lime_use_old_deltatime \
  --macro "flixel.system.macros.FlxDefines.run()" \
  --macro "include('mvz2',true)" --macro "include('pvzengine',true)" --macro "include('mvz2logic',true)" \
  --macro "include('unity',true)" --macro "include('system',true)" --macro "include('tools',true)"
```

- `-D lime_use_old_deltatime` 必需：本机 lime 为定制分支（`Application.onUpdate` 用 `Float`），openfl 9.3.4 硬编码 `Int`，缺该定义会在 openfl 库源码处报 `Float should be Int`。该定义已写入 `Project.xml`，lime 构建无需再传。
- `FlxDefines.run()` 必需：`haxe -lib flixel` 不会执行 flixel 的 `include.xml` 定义，缺了会报 `FlxG.mouse/keys has no field`。
- `include()` 宏**不保证**未被引用的模块进入检查。
- **注意（2026-10-02 实测）**：上面这类「include 宏 + --no-output」检查会**漏掉类型序相关的错误**——`Context.getModule` 逐模块类型化时能通过，但同一批模块放在一次真实编译里可能失败。例：`mvz2/archives/ArchiveController.hx:231` 的命名实参错位在标准检查下全绿，而 `--macro "include('mvz2.archives',true)"`（或任何先类型到 `mvz2.talk.TalkController` 的编译）会报 `TalkController.hx:47 Null<String> cannot be called` + `LevelController.hx:1448`（把该行按 C# 的 `onEnd:` 命名实参补成第 4 个位置参数后即全绿）。要复现真实构建的报错，用不带 include 宏的 `-main Main -neko ... --no-output`，或直接跑 `lime build windows`。
- **neko 只能做类型检查，不能做代码生成/运行**（实测）：只要编译里类型到 `mvz2/modding/ModResource.hx`（连带 MVZ2 的 UI/Manager 层），neko 生成期就报 `Error: Field hashing conflict GetLocalizedStringPlural and _id`（`mvz2/localization/LanguageManager.hx` 的字段表冲突）。最小复现：任意 trivial `-main` + `--macro "include('mvz2.localization',true)"`。需要真机运行验证的冒烟程序请在 **cpp** 目标下跑。

### 全覆盖验证（确认每个模块都真的被类型检查）
```
haxe -cp source -cp verify -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl \
  -lib hscript -lib hxjsonast -lib json2object -main Main -neko /tmp/check.n --no-output \
  -D lime_use_old_deltatime \
  --macro "flixel.system.macros.FlxDefines.run()" --macro "coverage.CoverageCheck.run()"
```
期望输出：`[CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0`
（模块数随新增文件变化：2026-10-02 为 2478，2026-10-05 第二轮为 2486）。

### cpp 目标类型检查（neko 检查不到的错误类型，约 50 秒）
```
haxe -cp source -cp verify -lib flixel -lib flixel-addons -lib flixel-ui -lib lime -lib openfl \
  -lib hxcpp -lib hscript -lib hxjsonast -lib json2object -main Main -cpp "$TEMP/mvz2_cppcheck" --no-output \
  -D lime_use_old_deltatime \
  --macro "flixel.system.macros.FlxDefines.run()" --macro "coverage.CoverageCheck.run()"
```
期望输出同样是 `[CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0`。

**以退出码为准**：出错时退出码为 1，且错误行会打印在 `[CoverageCheck]` 汇总行**之后**（汇总里的
「失败=0」只统计模块级加载失败，模块内部的类型错误不算在里面）。所以别只看汇总行，看退出码。

**为什么必须单独跑**：`Null<Bool>` / `Null<Float>` 这类写法在 neko 上合法、在 hxcpp 上直接报
`On static platforms, null can't be used as basic type Bool/Float`。最小复现（同一份文件，
`-neko --no-output` 退出码 0，`-cpp --no-output` 报 2 处错误）：

```haxe
class Probe {
	public static function f():Bool return Std.parseFloat("1.5") != null; // cpp: null can't be used as basic type Float
	public static function h():Bool return null;                          // cpp: null can't be used as basic type Bool
}
```

历史上「构建通过」其实只编译了占位 InitState 的空壳，就是漏了这一步。

**注意**：不能直接沿用上面 neko 那条命令里的 `--macro "include('tools',true)"`——加上 `-lib hxcpp` 之后，
hxcpp 包自己的 `tools/`（`tools/build/Build.hx`、`tools/hxcpp/BuildTool.hx`）也进了 classpath，这两个是
没有 `package` 声明的老式路径模块，`include` 会报
`Invalid commandline class : tools.build.Build should be Build` 并直接中断检查。
改用 `coverage.CoverageCheck.run()`（只走工程自己的 `source/`），或写成 `include('tools',true,null,['source'])`。

### system.xml 语义与元数据解析冒烟测试（工作包 A）
```
bash HaxePort/tools_build/check_xml.sh --neko   # 约 40 秒：内联 XML 语义 + achievements 元数据链路
bash HaxePort/tools_build/check_xml.sh --cpp    # 与游戏同目标：额外把 38 个 Meta 资源全量解析一遍
```
- 覆盖 `.NET XmlNode/XmlDocument/XmlAttribute/XmlAttributeCollection/XmlNodeList/XmlReader` 的等价语义，
  以及 `TextAsset.bytes → MemoryStream → XMLHelper.ReadXmlDocumentFromStream → MetaXMLParser.LoadMetaList
  → AchievementMetaList.FromXmlNode` 这条真实链路（复刻 `ResourceManager.LoadSingleMetaList`，该方法为 private）。
- neko 下跳过 `MetaXMLParser`/`TalkMeta` 分派（neko 代码生成限制，见上）；cpp 下跑全量。

### 原生构建与运行
```
cd HaxePort && haxelib run lime build windows
cd export/windows/bin && ./MVZ2.exe
```
产物：`export/windows/bin/MVZ2.exe`（hxcpp + MSVC）。

- **启动进度看 boot-trace.log**：写在**进程工作目录**（即 `export/windows/bin/`）下，由
  `source/mvz2/states/BootTrace.hx` 写出。lime 的 Windows 程序是 GUI 子系统，`trace`/stdout/stderr 全部不可见，
  启动阶段唯一可见的输出就是这个文件；最后一行就是启动真正走到的位置。
- **空引用排查用 -debug 构建**：
  ```
  cd HaxePort && haxelib run lime build windows -debug
  ```
  `-debug` 会让 hxcpp 定义 `HXCPP_DEBUG`，而 `hxcpp.h:105` 里 `HXCPP_DEBUG` 会顺带定义
  `HXCPP_CHECK_POINTER`（等价于显式 `-D HXCPP_CHECK_POINTER`，无需改 `Project.xml`）：空引用的
  `operator->` 会抛**可捕获**的 `Null Object Reference`，`MainSceneState` 的 try/catch 捕获后降级到
  `ErrorState` 显示错误、进程不退出，并且 `ErrorState` 会打印 Haxe 调用栈
  （`Called from pkg.Class.method (file.hx line N)`）。默认（非 -debug）构建没有空指针检查，
  同样的空引用是直接访问违例（exit code `3221225477` = 0xC0000005）静默崩溃。
  这就是「缺资源/空引用不崩溃」降级路径的实现基础。
- 隔离的验证用工程：`tools_build/verify_pointer/`（复制自本文件的 Project.xml，只把 source/icon 改成相对路径、
  并去掉 943MB 的 `<assets>`；运行前在该目录的 `export/windows/bin` 下建一个指向 `HaxePort/assets` 的目录联接即可）。
- 一键复验（neko + cpp 类型检查 → 标准构建 → 运行 → 打印 boot-trace 末尾）：
  ```
  python tools_build/verify_release.py
  ```
- **`boot-trace.log` 只说明"走到哪一步"，定位不到"哪一行"**。要把卡点精确到文件:行，用启动链路插桩：
  ```
  python tools_build/probe_startup.py            # debug：空引用变可捕获异常，看调用链
  python tools_build/probe_startup.py --release   # release：复现静默段错误，定位真实卡点
  ```
  它把关键调用逐个包上 `BootTrace.step("PROBE …")` 写进**覆盖层** `%TEMP%/mvz2_cppfix`
  （`tools_build/verify_build/Project.xml` 已把它排在 `../../source` 之后；`verify_pointer` 的
  `Project.xml` 由脚本临时注入 `-cp` 再还原），**不改 `source/`**，因此可与其它 agent 并行。
  崩溃时最后一条 `PROBE` 就是出事的那次调用。
- **告警计数（判断属性注册表 / 定义扫描是否生效的核心指标）**：
  ```
  python tools_build/count_boot_warnings.py                 # 默认读 export/windows/bin/boot-trace.log
  python tools_build/count_boot_warnings.py <log1> <log2>   # 多份日志对比
  python tools_build/count_boot_warnings.py --json <log>    # 机器可读
  ```
  基线（2026-10-02，注册表缺失时）与 2026-10-05 第二轮实测：

  | 告警 | 基线 | 中间态（16:55） | 最终（17:30） |
  |---|---|---|---|
  | `Trying to set a property with an invalid key!` | 16331 | 58 | **0** |
  | `Property with name ... is not registered.` | 8563 | 0 | **0** |
  | `Cannot find entity behaviour with ID mvz2:*` | 1986 | 311 | **0** |
  | `Cannot find map element behaviour with ID mvz2:*` | 9 | 0 | **0** |
  | `Cannot create property ... of type "color"` | 0 | 0 | **0** |

  判据：注册表宏生效时前两项应大幅下降或归零；`boot-trace.log` 行数 27,013 → 495 → **129**。
  「中间态」那 311 条是**宏的次类型命名缺陷**：`classPath()` 对次类型发出 `pack.Module.Type`，
  而运行期 `Type.getClassName` 是 `pack.Type`，`getRecordOfClass` 查不到 → 6 个次类型的
  `defs/region/fields` 丢失（`EntityPhysicsBehaviour` 正是其中之一）。修好后归零；
  详见 `registry_macro_findings.md`「缺陷 D」与 `integration_report.md` §5.2。

### ⚠️ debug 与 release 的差别：debug 跑通 ≠ release 跑通（2026-10-02 集成验证实测）

`-debug` 下 `HXCPP_CHECK_POINTER` 让空引用变成**可捕获**的 Haxe 异常，这带来一个陷阱：

- 任何 `try { … } catch (e:Dynamic) {}` 里的空引用会被**静默吞掉**，流程继续往下走；
- release（标准构建）下同样的空引用是直接访问违例（exit code `3221225477` = `0xC0000005`），进程当场死。

实测现象：加探针的 **debug** 构建能一路跑完 `GameEntrance.Start`（`[done] GameEntrance.Start 完成`，
`update 循环` 跑到 3600 帧），而同一份 `source` 的 **release** 构建仍停在
`[step] GameEntrance.Start（main.Initialize + InitLoad）` 后静默段错误。

**所以：判断"哪里真的崩"必须用 release 构建（`probe_startup.py --release`）；`-debug` 只用来观察调用链。**

### hxcpp 启动期静态初始化约束（2026-10-02 工作包 C 补充）

hxcpp 会在 `main()` 之前执行**全部**静态字段初始化（生成的 `export/windows/obj/src/__boot__.cpp` 里的
`__boot_all()`），此时 `Global.Game` / `MainManager.Instance` 等运行期单例都还是 null。C# 的静态字段是
"首次使用时初始化"，所以同样的写法在 Unity 上没问题、在 hxcpp 上会直接段错误（lime 的 Windows 程序是
GUI 子系统，stdout/stderr 全丢，表现为双击闪退）。

移植时请遵守：

- **不要在静态字段初始化里读运行期单例**。`public static var x = new NamespaceID(Global.BuiltinNamespace, "x")`
  这类写法要改成惰性 getter（缓存到 private 静态字段，等价于 C# 的 `readonly static`）：
  ```haxe
  public static var x(get, never):NamespaceID;
  private static var _x:NamespaceID;
  static function get_x():NamespaceID
  {
      if (_x == null) _x = new NamespaceID(Global.BuiltinNamespace, "x");
      return _x;
  }
  ```
- 已经落地的兜底：`mvz2logic.Global.get_BuiltinNamespace()` 在 `Game == null` 时回退到
  `Global.BOOT_BUILTIN_NAMESPACE`（值等于 `MainManager.builtinNamespace` 的初值 `"mvz2"`，
  `Assets/Scripts/MVZ2/Managers/MainManager.cs:377`）。
- 排查工具：`python tools_build/pkgc_boot_probe.py -d export/windows` 给 `__boot_all()` 插桩、重链并运行，
  崩溃时打印最后一个完成的静态初始化序号与类名；`--restore` 撤销插桩并重链。
- 批量改写脚本：`python tools_build/pkgc_lazy_statics.py`（幂等，已转换的会跳过）。

### 本轮新发现的坑（2026-10-02 集成验证汇总）

1. **C# struct 的默认值不是 Haxe 的默认值（空引用重灾区）**
   C# 里 `Color` / `Vector2` / `Vector3` / `Rect` 等是 **struct**，字段默认值恒为"零值"（`new Color(0,0,0,0)`、
   `Vector2.zero`），**永远不为 null**；Haxe 侧 `unity.Color` 等是 `abstract over class`，
   未显式初始化的字段就是 `null`，一读就空引用（release 直接段错误）。
   移植规则：这类字段一律显式给零值初值 ——
   ```haxe
   public var backgroundColor:Color = new Color(0, 0, 0, 0);
   // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用
   ```
   已有落点（可 grep `C# Color 为 struct`）：`mvz2/metas/AlmanacTagMeta.hx`、`mvz2/models/LightController.hx`、
   `mvz2levels`/`mvz2/ui/**` 等 20 余处；`mvz2/metas/TalkCharacterVariant.hx` 是 Vector2 的同型问题。

2. **`Std.parseInt` / `Std.parseFloat` 比 .NET 宽容得多，不能直接替代 `int.TryParse`**
   | 输入 | Haxe `Std.parseInt` | C# `int.TryParse(…, NumberStyles.Integer, …)` |
   |---|---|---|
   | `"0x10"` | `16`（认十六进制） | `false` |
   | `"12abc"` | `12`（吃尾随垃圾） | `false` |
   | 溢出（`"9999999999"`） | 回绕成 Int32 值 | `false` |
   | `Std.parseFloat("1.5x")` | `1.5` | `false` |

   结论：XML/存档里的坏数据会被静默当成合法数字。数据解析统一走
   `mvz2logic.ParseHelper.TryParseInt/TryParseLong/TryParseFloat`（严格按 .NET 语法 + 范围校验），
   不要直接用 `Std.parseInt`。注意溢出**不能**用 `accum = accum * 10 + d` 判（Haxe 按 Int32 回绕，
   `214748364*10+8` 直接变成 `-2147483648`），要先用字符串比长度/字典序做范围校验。

3. **hxcpp 启动期静态初始化**：见上一节。判据是"崩在 `main()` 之前、boot-trace 一个字都没写出来"。

4. **`Project.xml` 的 flixel 输入 define 必须与原工程一致**：
   原工程用了鼠标右键/中键（`MVZ2/Map/MapController.cs:479-483`、`MVZ2/Managers/InputManager.cs:44-74`、
   `Logic/Inputs/InputHelper.cs:35-39`），所以**不能**定义 `FLX_NO_MOUSE_ADVANCED`（否则 release 下
   右键/中键静默失效）。对应代码用 `#if FLX_MOUSE_ADVANCED` 容纳该差异（`source/unity/KeyCodeMap.hx:163-215`）。
   `FLX_NO_KEYBOARD` 只在 mobile 定义，因此 `FlxG.keys` 的使用要写 `#if FLX_KEYBOARD`（见 `ErrorState.hx`）。

### 2026-10-05 第二轮集成验证（属性注册表宏落地后）

> 第一轮补充见本文件下方「第一轮补充要点」；本轮取代其结论。

**验证时点**：2026-10-05 16:46~17:50（`source/` 被并行 agent 持续改动，快照与并发说明见
`tools_build/integration_report.md` §1）。

| 阶段 | 结果 |
|---|---|
| neko 类型检查 | **exit 0**（含 `include` 宏全覆盖） |
| cpp 全覆盖检查 | **exit 0**，`[CoverageCheck] 模块总数=2486 类型化成功=2486 失败=0` |
| `haxelib run lime build windows` | **exit 0**（6m24s），产物 29,960,704 B、md5 `38d6631abd3de104cd45f2392c2c0b3a` |
| release 运行 | 仍段错误 `exit=139`（0xC0000005），存活约 14 s |
| **修复后复验**（17:29） | neko/cpp/lime **exit 0**；产物 30,065,664 B、md5 `8abe051268413693abb29a8bed01dbc3` |

**模块数已从 2478 增至 2486**（新增 `system/reflection/{DefinitionRegistry,DefinitionRegistryMacro}.hx`、
`mvz2/scenes/ScenePrefab*.hx` 等）。**产物从 23.7 MB 涨到 30.0 MB**：注册表宏为每个定义类发出直接类引用，
原先被 DCE 整批删掉的 900+ 个定义/行为类现在真的进了可执行文件（这正是
`Cannot find entity behaviour with ID mvz2:*` 的直接原因）。

#### 属性注册表宏（工作包①）——已落地，语义恢复正常

`source/system/reflection/DefinitionRegistryMacro.hx`（编译期扫描 `source/`，`@:build` 注入
`DefinitionRegistry`）+ `DefinitionRegistry.hx`（运行期注册表）+ `Assembly.hx`（`GetTypes` /
`IsAbstract` / `HasCustomAttribute` / `GetCustomAttributes` / `InvokeConstructor`）。
`@:` 前缀元数据运行期读不到，只能宏取；宏发出的 `attr` 是**类引用**而非字符串。

**告警计数对比（同一 `tools_build/count_boot_warnings.py` 统计口径）**：

| 告警 | 基线（2026-10-02） | 中间态（16:55） | **最终（17:30）** |
|---|---|---|---|
| `Trying to set a property with an invalid key!` | 16331 | 58 | **0** |
| `Property with name ... is not registered.` | 8563 | 0 | **0** |
| `Cannot find entity behaviour with ID mvz2:*` | 1986 | 311 | **0** |
| `Cannot create property ... of type "color"` | 0 | 0 | **0** |

`boot-trace.log`：**27,013 行 → 495 行 → 129 行**。属性键已实测非 0 且互不相同
（`EngineEntityProps.GRAVITY=1049525`、`TINT=1049522`、`LogicEntityProps.UNLOCK=1049363` …）。

#### 本轮修复：`LoadModModels` 等 3 处 release 崩溃（集成验证工作包）

`ResourceManager.hx` 的 `LoadLabeledResources(GameObject, …)` 里 `GameObject` 只是**类型参数**，
而 `ResourceManifest` 对 `Model/AreaModel/MapModel` 标签返回 **`haxe.io.Bytes`**（Unity prefab 专有格式
尚未转换），于是 `pair.resource.GetComponent(Model)` 在 Bytes 上取方法 → cpp 访问违例。
3 处（`:817` / `:1285` / `:1372`）都加了 `if (!Std.isOfType(pair.resource, GameObject)) continue;`
（沿用同文件 `:448` 已有的「无法还原 = 无匹配资源」约定；模型创建本来就走
`ModelBuilder → ModelPrefabLoader` 回退路径）。详见 `integration_report.md` §4。

**通用教训**：Haxe 无运行期泛型，`LoadLabeledResources<T>` 的 `T` 只在编译期存在 ——
凡是用它取 `GameObject` 再 `GetComponent` 的调用点，都要有类型守卫。

#### 启动卡点（修复后，比上一轮更靠后）

上一轮停在 `main.Initialize()` 的存档降级路径（`MVZ2SaveExt.hx:12` 的 `Object does not implement interface`）。
本轮该异常**已消失**，`main.InitLoad()` 的资源加载流水线**全部 6 个任务跑完**：

```
[step] GameEntrance.Start（main.Initialize + InitLoad）
[log] 加载Music Clips花费的时间：0.017
[log] 加载Sound Clips花费的时间：0.024
[log] 加载Sprites花费的时间：11.867
[log] 加载Models花费的时间：0.391        ← 修复前段错误于此
[log] 加载Map Models花费的时间：0.026
[log] 加载Area Models花费的时间：0.013
```

其后 `GameEntrance.StartGame → DisplayPage(Splash)` 段错误，debug 精确到
**`mvz2/map/MapController.hx:299`**（`mapCamera` 是 `@:serializeField`、从未注入）：

```
Called from mvz2.map.MapController.SetCameraBackgroundColor (MapController.hx line 299)
Called from mvz2.map.MapController.Hide (MapController.hx line 101)
Called from mvz2.scenes.MainSceneController.DisplayPage (MainSceneController.hx line 175)
```

（`ErrorState` 只打印 3 层栈；最外层调用者是 `GameEntrance.StartGame`
的 `main.Scene.DisplayPage(MainScenePageType.Splash)`，`source/mvz2/scenes/GameEntrance.hx:64`。）

数据齐备（`assets/scene_prefabs/Prefabs/Map/Map.json` node 14 带 `mapCamera={n:7,c:1}`），
**属工作包②**：把 `ScenePrefabInjector.ApplyTree` 接入 `MainGameScene` 即可（该文件已存在但无调用点）。

补充要点：

1. **改完必须重新跑类型检查，不要相信「改之前是绿的」。**
   2026-10-02 21:54 给 `MainGameScene.hx` 加了 `AudioManifest.mainMixer` 的使用，
   但漏了 `import mvz2.audios.AudioManifest;`，neko 与 cpp **双双**报
   `MainGameScene.hx:257 Type not found : AudioManifest`，而上一轮验证（21:14）早于该编辑，
   所以「基线不红」的结论对最终快照并不成立。**跨包引用新类型时，先补 import 再跑 §类型检查。**
   （同包引用如 `MusicManager` 不需要 import，容易漏。）

2. **release 卡点定位的两个可用手段**（本轮都用上了）：
   - `-debug` 构建（`tools_build/verify_startup`，隔离工程、无覆盖层）会把空引用变成可捕获异常，
     `ErrorState` 打印的 Haxe 调用栈直接给到 `文件:行`。本轮定位到
     `mvz2/ui/scene/MainSceneUI.hx:32`（`dialog.gameObject` 空引用），触发链是
     `GameEntrance.Start → CheckSaveDataStatus → ShowDialogMessageAsync`。
   - release 侧的「最后一条日志」用 `StartupError` 的实时镜像（`Application.logMessageReceived`
     逐条写进 boot-trace）观察，本轮末行为「无法读取用户0的MODmvz2的存档…创建一个新存档」。

3. **`try/catch` + 空引用 = release 静默死的经典组合**：`SaveManager.LoadInitialUserData`
   对 `LoadUserData(index)` 整体 `try { … } catch (e:Dynamic) { … }`。debug 下内部异常被吞、
   流程继续；release 下同一处直接 `0xC0000005`。**判定「哪里真的崩」仍必须以 release 为准。**

4. **`tools_build/verify_build` 的覆盖层 `%TEMP%/mvz2_cppfix` 是过期副本**（`probe_startup.py`
   留下的 12 个含 `PROBE` 插桩的文件，mtime 2026-10-02 21:45，比 `source/` 旧）。
   用 `verify_build` 复现前先 `python tools_build/make_cpp_overlay.py` 重建，或删除该目录。
   **标准构建 `export/windows/` 不加载任何覆盖层**，要验证真实 `source/` 请用它。

5. **跨域根因（**已修**，2026-10-05 第二轮）**：`system/reflection/Assembly.hx` 曾缺 `GetTypes`
   → `ModLoader.AssemblyGetTypes()` 恒返回 `[]` → `PropertyMapper` 从不注册 → 所有 `PropertyMeta`
   的 key 恒为 0，`PropertyDictionary`（`Map<Int,Dynamic>`）全部互相覆盖。表现为数万条
   `Cannot find entity behaviour with ID mvz2:*` 与 `Trying to set a property with an invalid key!`，
   并在 `mvz2/saves/MVZ2SaveExt.hx:12` 抛 `Object does not implement interface`。
   现已由编译期宏 `system/reflection/DefinitionRegistryMacro.hx` 修复（见上方第二轮小结与
   `integration_report.md` §5.1）。**教训**：`@:` 前缀元数据运行期读不到，只能编译期宏取
   （参照 `verify/coverage/CoverageCheck.hx`）；宏为定义类发出的**直接类引用**同时是防 DCE 的手段。

### 运行时资源
Unity 资源已按原目录结构镜像到 `HaxePort/assets/`（GameContent、Textures、Fonts、Animation、Models、Shaders、Materials、Mixers、Localization；已剔除 `.meta`/`.cs`）。Unity 专有格式（`.prefab`/`.anim`/`.asset`/FBX、Addressables 目录）仍需转换后接入 `ResourceManager`。

### 资源清单流水线（构建期脚本，按顺序运行）
```
python HaxePort/tools_build/build_manifest.py        # ① Addressables -> assets/resource_manifest.json（地址 -> 路径/type/kind/标签）
python HaxePort/tools_build/convert_sprites.py       # ③ *.png.meta + spritemanifests + spriteatlasv2 -> assets/sprites_manifest.json
python HaxePort/tools_build/verify_sprites.py        # ③ 独立性校验（不依赖 convert_sprites 的实现）
```
- **地址 -> 路径只保留 ① 一份来源**：`sprites_manifest.json` 的键就是 ① 的地址（`mvz2:<path>`），并在每条上带 `resourcePath`（取自 ① 的清单）；运行期 `mvz2.sprites.SpriteManifestLoader` 也优先按地址到 `resource_manifest.json` 取贴图路径，取不到才回退到清单内的 `assetPath`。
- 精灵的**帧矩形 / pivot / 像素比 / 图集成员**由 ③ 负责：`rect`/`pivot` 用 Unity 坐标系（左下角原点），`pivot` 已按 Unity 规则解析（`alignment != 9` 由 alignment 推导，`== 9`(Custom) 取 `.meta` 的 `spritePivot`）。
- 运行期接口：`SpriteManifestLoader.load()` → `getSpriteDefinition(path)` / `getSpriteSheetDefinition(path)`；`SpriteManifestRegistrar.populateModResource(mod)` 把结果灌进 `ModResource.Sprites`/`SpriteSheets`；像素由 `SpriteTextureCache.getBitmapData(texture)` 提供。
- `ResourceManager.LoadInitSpriteManifests` / `LoadMainSpriteManifests` 会按 `Init`/`Main` 标签从 `sprites_manifest.json` 重建等价 `SpriteManifest`（原 Addressables 资产在移植层不存在）。

### C# struct 默认值 vs Haxe null（2026-10-02 工作包 G 补充）

Unity 的 `Vector2/Vector3/Vector4/Color/Rect/Bounds/Quaternion/...` 在 C# 是 **struct**：字段即使不写初始化
表达式也**永远不为 null**，默认值是零值（`default(Color)` 即 `(0,0,0,0)` 透明黑）。移植层把这些类型做成了
`abstract over class`（引用类型），同一份声明在 Haxe 里就是 `null`，任何字段读取在 cpp 上都是空引用
（debug 构建 `Null Object Reference`、release 构建 `0xC0000005`）。

规则：

- **这些类型的字段一律显式写上 C# 的默认值**：`public var size:Vector2 = new Vector2(0, 0);`
  （`Color` 用 `new Color(0, 0, 0, 0)`；注意 shim 的 `new Color()` 默认 alpha=1，**不是** C# 的默认值）。
  若 C# 原声明带初始化表达式（如 `= Vector3.one * 0.5f`），必须按原值翻译，不要一律置零。
- **函数内局部变量不用改**：C# 的明确赋值规则保证它们在读之前一定被赋值，保持原有分支结构即安全。
- 判定工具：`python tools_build/check_struct_defaults.py --check`（扫描 `source/`，对照 `Assets/Scripts/`
  的同名类声明给出 C# 证据；发现仍未初始化的字段即退出码 1）。`--locals` 会额外列出函数内局部变量。
- hxcpp 侧的构造语义（已实测）：无构造函数的类只要**有基类构造函数可继承**，Haxe 会合成一个构造函数来
  执行字段初始化表达式（`class Sub extends Base { public var v:Vector2 = new Vector2(0,0); }` →
  `new Sub()` 与 `Type.createInstance(Sub, [])`/`GameObject.AddComponent` 都会跑初始化表达式）；
  只有 `Type.createEmptyInstance` / `Entity.CreateParams` 这类**不调用构造函数**的路径会跳过初始化表达式，
  对这些类的字段必须在构造点显式赋值。完全没有基类构造函数又没有自己的 `new()` 的类无法被 `new`
  （报 `X does not have a constructor`），只能用 `Type.createInstance`。
- **`[SerializeField]` 字段**在 Unity 里由 prefab/场景资产赋值（C# 默认值只是"数据缺失"时的兜底）。
  移植层目前只有 `mvz2.models.ModelPrefabLoader` 处理**模型** prefab，关卡/UI prefab 的序列化值还没有
  数据来源：显式初始化后这些字段会读出零值而不是崩溃，但真正需要的 prefab 值要等 prefab 转换接入。
