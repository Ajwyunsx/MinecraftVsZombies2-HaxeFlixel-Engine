# Minecraft VS Zombies 2 · Haxe 移植版

将 Unity 版《Minecraft VS Zombies 2》（Unity 2022.3 / C#）1:1 移植到 **Haxe + HaxeFlixel + OpenFL/Lime** 的游戏工程。

- 原作版本对应：`0.4.5`（`com.cuerzor58.mvz2`，作者 Cuerzor）
- 移植目标：类名 / 接口名 / 字段名 / 方法名与原版保持一致，C# 源码逐文件映射为 Haxe 源码
- 移植规范与踩坑记录见 [`PORTING.md`](PORTING.md)

## 技术栈

| 组件 | 说明 |
|---|---|
| Haxe 4.3+ | 编译到 hxcpp（Windows 桌面）、neko（类型检查）、html5 / mobile 目标 |
| HaxeFlixel | flixel 5.8.0 / flixel-addons 3.2.3 / flixel-ui 2.6.1（`hmm.json` 锁定版本） |
| OpenFL / Lime | 渲染与窗口层；桌面目标带 `hxvlc` 视频 |
| unity 兼容层 | `source/unity/` 下的 UnityEngine shim：`Vector3`、`Coroutine`、`MonoBehaviour`、`Animator` 等 |
| 表达式引擎 | `source/expressionevaluator/`（原版 ExpressionEvaluator 的逐文件移植） |
| 序列化 | newtonsoft（JSON）、nbtutility（Minecraft NBT）、mukioi18n（i18n）、tmpro（TextMeshPro）、ngettext、system（.NET BCL 风格工具） |

## 目录结构

```
HaxePort/
├── Project.xml            # lime/openfl 工程文件
├── hmm.json               # haxelib 依赖锁定
├── source/                # Haxe 源码（1:1 移植）
│   ├── Main.hx            # 入口（InitState → 标题界面 → 主游戏场景）
│   ├── mvz2/              # namespace MVZ2.*（原 Assets/Scripts/MVZ2、View、Vanilla）
│   ├── mvz2logic/         # namespace MVZ2Logic.*（原 Assets/Scripts/Logic）
│   ├── pvzengine/         # namespace PVZEngine.*
│   ├── expressionevaluator/
│   ├── unity/             # UnityEngine API 兼容层（shims）
│   ├── mongodb/ mukioi18n/ nbtutility/ newtonsoft/ ngettext/
│   ├── system/ tmpro/     # 原 C# 依赖库的 Haxe 移植
│   └── tools/
├── assets/                # 游戏资源（音频、字体、模型清单、着色器等）
├── art/                   # 图标
├── tools_build/           # 构建 / 验证 / 审计 Python 工具链（含报告 .md）
├── verify/                # 冒烟测试用 Haxe 工程
├── hxshadow/              # shadow loop 批量补丁工具
└── PORTING.md             # Unity → Haxe 移植规范（C#/Haxe 映射表、协程语义、shim 约定）
```

## 构建与运行

前置：Haxe 4.3+、haxelib、hmm（依赖安装）、MSVC（hxcpp 桌面目标）。

```bash
# 安装 hmm.json 锁定的依赖
haxelib --global install hmm && hmm install

# 构建 Windows 桌面版
haxelib run lime build windows

# 运行
cd export/windows/bin && ./MVZ2.exe
```

调试说明：

- 启动阶段输出写在**运行目录**的 `boot-trace.log`（lime 的 Windows GUI 子系统会丢弃 stdout，这是唯一可见的启动日志，最后一行即卡点）。
- 空引用排查用 `haxelib run lime build windows -debug`：hxcpp 启用空指针检查，异常可被捕获并降级到 `ErrorState` 显示调用栈。
- 本机 lime 需为定制分支（`-D lime_use_old_deltatime`，见 `Project.xml` 注释）。

## 工具链

- `tools_build/` — 一百多个 Python 脚本：场景/精灵/字体/注册表/音频构建与审计、启动探针、发布复验（`python tools_build/verify_release.py` 一键跑 neko + cpp 类型检查 → 构建 → 运行 → 检查 boot-trace）。
- `verify/` — 隔离的冒烟测试工程（XML 链路、模型、协程、渲染桥、点击链路等）。
- `hxshadow/` — shadow loop：把源码批量复制到影子目录打补丁后交类型检查器验证的工具。

## 免责声明

本项目为**粉丝移植 / 学习研究用途**的非官方工程。《Minecraft VS Zombies 2》及相关资源（美术、音乐、数据）版权归原作者 Cuerzor 及相关权利方所有，仓库中的 `assets/` 仅用于移植验证，不授予任何资源版权。

## 许可证

代码部分以 [GNU General Public License v3.0](LICENSE) 授权，详见 `LICENSE`。游戏资源版权如上所述归原作者所有，不受 GPL 覆盖。
