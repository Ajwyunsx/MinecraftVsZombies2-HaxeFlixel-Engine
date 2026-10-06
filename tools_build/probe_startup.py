"""启动链路插桩探针（集成验证工作包，2026-10-02 新增）。

用途
----
`boot-trace.log` 只能告诉你"启动走到哪一步断了"，无法定位到具体是哪一行空引用。
本脚本把启动链路上的关键调用逐个包上 `BootTrace.step("PROBE …")`，写进**覆盖层**
（`%TEMP%/mvz2_cppfix`，由 `tools_build/verify_build/Project.xml` 与本脚本临时注入的
`tools_build/verify_pointer/Project.xml` 在 `../../source` 之后引用），再构建、运行、
把 boot-trace 末尾打印出来。崩溃时最后一条 PROBE 就是出事的那次调用。

**为什么要用覆盖层**：只改 `%TEMP%` 下的副本，不动 `source/` 里任何文件，因此多个 agent
可以并行排查而互不覆盖；source 一改，重新跑一次本脚本即可重新生成。

**release 与 debug 的差别（重要）**：`-debug` 会让 hxcpp 定义 `HXCPP_CHECK_POINTER`，
空引用变成**可捕获**的 Haxe 异常。这有两个后果：
  1. 好处：`MainSceneState` 的 try/catch 能接住，进程不退出，`--debug` 模式下的探针能一路走到底；
  2. 陷阱：任何 `try { … } catch (e) { }` 里的空引用都会被**静默吞掉**，于是
     "debug 构建能跑到底、release 构建在同一位置静默段错误"是常见现象。
     因此**最终判断必须以 release（标准构建）为准**：`--release` 模式跑一遍，
     最后一条 PROBE 才是 release 真正的卡点。

用法（在 HaxePort/ 下执行）
--------------------------
    python tools_build/probe_startup.py                 # debug：可捕获空引用，看调用链走到哪
    python tools_build/probe_startup.py --release       # release：复现静默段错误，定位真实卡点
    python tools_build/probe_startup.py --no-build      # 复用上一次构建，只重新运行
    python tools_build/probe_startup.py --restore       # 还原 verify_pointer/Project.xml 里注入的 -cp

产物与日志：`%TEMP%/mvz2_boot_probe/`（覆盖层源码 + 运行日志）
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)                      # HaxePort/
SOURCE = os.path.join(ROOT, "source")
OUT = os.path.join(os.environ.get("TEMP", "."), "mvz2_cppfix")
LOG_DIR = os.path.join(os.environ.get("TEMP", "."), "mvz2_boot_probe")
NL = "\n"

POINTER = os.path.join(HERE, "verify_pointer")    # debug 工程（自带 -debug -DHXCPP_CHECK_POINTER 用法）
BUILD = os.path.join(HERE, "verify_build")        # release 工程（Project.xml 已带覆盖层 -cp）


# ---------------------------------------------------------------- 覆盖层生成
def read_source(rel):
    with open(os.path.join(SOURCE, rel.replace("/", os.sep)), encoding="utf-8") as f:
        return f.read().replace("\r\n", "\n")


def read_overlay(rel):
    with open(os.path.join(OUT, rel.replace("/", os.sep)), encoding="utf-8") as f:
        return f.read()


def write_overlay(rel, content):
    dst = os.path.join(OUT, rel.replace("/", os.sep))
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    with open(dst, "w", encoding="utf-8", newline=NL) as f:
        f.write(content)
    print("  探针覆盖层:", rel)


def probe(name):
    return 'mvz2.states.BootTrace.step("PROBE %s");' % name


def patch(rel, pairs, base="source"):
    """base='source' 以仓库源码为底；base='overlay' 以本次已写入的覆盖层副本为底。"""
    s = read_source(rel) if base == "source" else read_overlay(rel)
    for old, new in pairs:
        old = old.replace("\r\n", "\n")
        new = new.replace("\r\n", "\n")
        if old not in s:
            print("  !! 没找到锚点 %s:\n     %s" % (rel, old[:160]))
            return False
        s = s.replace(old, new, 1)
    write_overlay(rel, s)
    return True


def make_overlay():
    if os.path.isdir(OUT):
        shutil.rmtree(OUT)
    os.makedirs(OUT, exist_ok=True)
    ok = True

    # MainManager：Initialize / LoadManagersInit 的每一步
    ok &= patch("mvz2/managers/MainManager.hx", [
        ("""	public function Initialize():Task
	{
		InitGameSettings();
		InitSerializable();
		LogInformations();""",
         """	public function Initialize():Task
	{
		%s
		InitGameSettings();
		%s
		InitSerializable();
		%s
		LogInformations();
		%s""" % (probe("Initialize.InitGameSettings.before"), probe("InitSerializable.before"),
                 probe("LogInformations.before"), probe("LoadManagersInit.before"))),
        ("""		var loadTask = LoadManagersInit();
		ModManager.PostGameInit();
		initialized = true;
		Scene.Init();
		return loadTask;""",
         """		var loadTask = LoadManagersInit();
		%s
		ModManager.PostGameInit();
		%s
		initialized = true;
		%s
		Scene.Init();
		%s
		return loadTask;""" % (probe("LoadManagersInit.after"), probe("PostGameInit.after"),
                               probe("Scene.Init.before"), probe("Scene.Init.after"))),
        ("""		GraphicsManager.Init();
		FontManager.Init();
		InputManager.InitKeys();
		OptionsManager.InitOptions();""",
         """		%s
		GraphicsManager.Init();
		%s
		FontManager.Init();
		%s
		InputManager.InitKeys();
		%s
		OptionsManager.InitOptions();
		%s""" % (probe("GraphicsManager.Init.before"), probe("FontManager.Init.before"),
                 probe("InputManager.InitKeys.before"), probe("OptionsManager.InitOptions.before"),
                 probe("OptionsManager.InitOptions.after"))),
        ("""		var task:Task = cast ModManager.LoadModInfos(Game);
""",
         """		%s
		var task:Task = cast ModManager.LoadModInfos(Game);
		%s
""" % (probe("ModManager.LoadModInfos.before"), probe("ModManager.LoadModInfos.after"))),
        ("""		ResourceManager.Init();
		LanguageManager.InitLanguagePacks();""",
         """		%s
		ResourceManager.Init();
		%s
		LanguageManager.InitLanguagePacks();
		%s""" % (probe("ResourceManager.Init.before"), probe("ResourceManager.Init.after"),
                 probe("LanguageManager.InitLanguagePacks.after"))),
        ("""		ModManager.InitModLogics(Game);
		ModManager.LoadModLogics(Game);
		ModManager.PostReloadMods(Game);
		OptionsManager.LoadOptions();""",
         """		%s
		ModManager.InitModLogics(Game);
		%s
		ModManager.LoadModLogics(Game);
		%s
		ModManager.PostReloadMods(Game);
		%s
		OptionsManager.LoadOptions();
		%s""" % (probe("ModManager.InitModLogics.after"), probe("ModManager.LoadModLogics.after"),
                 probe("ModManager.PostReloadMods.after"), probe("OptionsManager.LoadOptions.before"),
                 probe("OptionsManager.LoadOptions.after"))),
        ("""		SaveManager.Load();
		DebugManager.LoadCommandParameterSuggestions();
		return task;""",
         """		%s
		SaveManager.Load();
		%s
		DebugManager.LoadCommandParameterSuggestions();
		%s
		return task;""" % (probe("SaveManager.Load.before"), probe("SaveManager.Load.after"),
                           probe("DebugManager.LoadCommandParameterSuggestions.after"))),
    ])

    # GameEntrance.Start：Initialize / CheckSaveDataStatus / StartGame
    ok &= patch("mvz2/scenes/GameEntrance.hx", [
        ("""        if (!Initialize().awaitResult())
            return;

        CheckSaveDataStatus().awaitResult();
        StartGame().awaitResult();""",
         """        mvz2.states.BootTrace.step("PROBE GameEntrance.Initialize.before");
        if (!Initialize().awaitResult())
            return;
        mvz2.states.BootTrace.step("PROBE GameEntrance.Initialize.after");

        mvz2.states.BootTrace.step("PROBE GameEntrance.CheckSaveDataStatus.before");
        CheckSaveDataStatus().awaitResult();
        mvz2.states.BootTrace.step("PROBE GameEntrance.CheckSaveDataStatus.after");
        mvz2.states.BootTrace.step("PROBE GameEntrance.StartGame.before");
        StartGame().awaitResult();
        mvz2.states.BootTrace.step("PROBE GameEntrance.StartGame.after");"""),
    ])

    # OptionsManager：逐条 option（id + 类型）+ 每条选项的派发
    ok &= patch("mvz2/options/OptionsManager.hx", [
        ("""            var meta = Main.ResourceManager.GetOptionItemMeta(id);
            if (meta == null)
                continue;""",
         """            var meta = Main.ResourceManager.GetOptionItemMeta(id);
            mvz2.states.BootTrace.step('PROBE option id=${id} type=${meta == null ? "null" : Std.string(meta.Type)}');
            if (meta == null)
                continue;"""),
        ("""    private function CallOptionChangedInt(id:NamespaceID, value:Int):Void {
        OnOptionChangedInt.dispatch(id, value);""",
         """    private function CallOptionChangedInt(id:NamespaceID, value:Int):Void {
        mvz2.states.BootTrace.step('PROBE CallOptionChangedInt id=${id} value=${value}');
        OnOptionChangedInt.dispatch(id, value);
        mvz2.states.BootTrace.step('PROBE CallOptionChangedInt.done id=${id}');"""),
    ])

    # 选项回调（Int/Float/Bool/String 四类的监听者入口）
    ok &= patch("mvz2/managers/PerformanceManager.hx", [
        ("""	private function UpdateFPSMode(mode:Int):Void
	{
		var fpsActive = mode != FPSModes.DISABLED;
		Main.Scene.SetFPSEnabled(fpsActive);""",
         """	private function UpdateFPSMode(mode:Int):Void
	{
		mvz2.states.BootTrace.step('PROBE UpdateFPSMode mode=${mode} Main=${Main} scene=${Main.Scene}');
		var fpsActive = mode != FPSModes.DISABLED;
		Main.Scene.SetFPSEnabled(fpsActive);
		mvz2.states.BootTrace.step('PROBE UpdateFPSMode SetFPSEnabled.done');"""),
    ])
    ok &= patch("mvz2/audios/SoundManager.hx", [
        ("""    public function SetGlobalVolume(volume:Float):Void {
        mixer.SetFloat("SoundVolume", AudioHelper.PercentageToDbA(volume));""",
         """    public function SetGlobalVolume(volume:Float):Void {
        mvz2.states.BootTrace.step('PROBE SoundManager.SetGlobalVolume volume=${volume} mixer=${mixer}');
        mixer.SetFloat("SoundVolume", AudioHelper.PercentageToDbA(volume));"""),
        ("""    private function OnOptionChangedFloatCallback(id:NamespaceID, value:Float):Void {""",
         """    private function OnOptionChangedFloatCallback(id:NamespaceID, value:Float):Void {
        mvz2.states.BootTrace.step('PROBE SoundManager.OnOptionChangedFloat id=${id}');"""),
    ])
    ok &= patch("mvz2/audios/MusicManager.hx", [
        ("""    private function OnOptionChangedFloatCallback(id:NamespaceID, value:Float):Void {""",
         """    private function OnOptionChangedFloatCallback(id:NamespaceID, value:Float):Void {
        mvz2.states.BootTrace.step('PROBE MusicManager.OnOptionChangedFloat id=${id} mixer=${mixer}');"""),
    ])
    ok &= patch("mvz2/localization/LanguageManager.hx", [
        ("""    private function OnOptionChangedStringCallback(id:NamespaceID, value:String):Void {""",
         """    private function OnOptionChangedStringCallback(id:NamespaceID, value:String):Void {
        mvz2.states.BootTrace.step('PROBE LanguageManager.OnOptionChangedString id=${id} value=${value}');"""),
    ])
    ok &= patch("mvz2/cameras/ResolutionManager.hx", [
        ("""	private function OnOptionChangedBoolCallback(id:NamespaceID, value:Bool):Void
	{""",
         """	private function OnOptionChangedBoolCallback(id:NamespaceID, value:Bool):Void
	{
		mvz2.states.BootTrace.step('PROBE ResolutionManager.OnOptionChangedBool id=${id} value=${value}');"""),
    ])
    ok &= patch("mvz2/models/GraphicsManager.hx", [
        ("""	private function OnOptionChangedBoolCallback(id:NamespaceID, value:Bool):Void
	{""",
         """	private function OnOptionChangedBoolCallback(id:NamespaceID, value:Bool):Void
	{
		mvz2.states.BootTrace.step('PROBE GraphicsManager.OnOptionChangedBool id=${id} value=${value}');"""),
    ])

    # InitLoad：MOD 主资源加载管线
    ok &= patch("mvz2/managers/ResourceManager.hx", [
        ("""		var infos = main.ModManager.GetAllModInfos();""",
         """		mvz2.states.BootTrace.step('PROBE LoadAllModResourcesMain mods=${main.ModManager.GetAllModInfos().length}');
		var infos = main.ModManager.GetAllModInfos();"""),
        ("""			progress.SetCurrentTaskName('Mod $nsp');
			task = LoadModResourcesMain(nsp, modResource, childProgresses[i]);""",
         """			progress.SetCurrentTaskName('Mod $nsp');
			mvz2.states.BootTrace.step('PROBE LoadModResourcesMain.before nsp=$nsp');
			task = LoadModResourcesMain(nsp, modResource, childProgresses[i]);
			mvz2.states.BootTrace.step('PROBE LoadModResourcesMain.after nsp=$nsp');"""),
    ])
    ok &= patch("mvz2/managers/ResourceManager.hx", [
        ("""			var name = task.GetName();
			progress.SetCurrentTaskName(name);
			task.Run();""",
         """			var name = task.GetName();
			progress.SetCurrentTaskName(name);
			mvz2.states.BootTrace.step('PROBE LoadModResourceTask.before $name');
			task.Run();
			mvz2.states.BootTrace.step('PROBE LoadModResourceTask.after $name');"""),
    ], base="overlay")
    ok &= patch("mvz2/supporters/SponsorManager.hx", [
        ("""    public function PullSponsors(progress:TaskProgress):Task {""",
         """    public function PullSponsors(progress:TaskProgress):Task {
        mvz2.states.BootTrace.step("PROBE SponsorManager.PullSponsors.enter");"""),
    ])

    # SaveManager：存档加载（release 下实测在此段错误）
    ok &= patch("mvz2/saves/SaveManager.hx", [
        ("""    public function Load():Void {
        var rootDirectory = GetSaveDataRoot();""",
         """    public function Load():Void {
        mvz2.states.BootTrace.step("PROBE SaveManager.Load.enter");
        var rootDirectory = GetSaveDataRoot();
        mvz2.states.BootTrace.step('PROBE SaveManager.GetSaveDataRoot=${rootDirectory} 存在=${system.io.Directory.Exists(rootDirectory)}');"""),
        ("""        userDataList = LoadUserList();
        LoadInitialUserData(userDataList);""",
         """        mvz2.states.BootTrace.step("PROBE SaveManager.LoadUserList.before");
        userDataList = LoadUserList();
        mvz2.states.BootTrace.step('PROBE SaveManager.LoadUserList.after list=${userDataList}');
        mvz2.states.BootTrace.step("PROBE SaveManager.LoadInitialUserData.before");
        LoadInitialUserData(userDataList);
        mvz2.states.BootTrace.step("PROBE SaveManager.LoadInitialUserData.after");"""),
        ("""    public function LoadUserData(index:Int):Void {
        modSaveDatas = [];
        var modInfos = Main.ModManager.GetAllModInfos();
        for (mod in modInfos) {
            LoadModData(index, mod);
        }
        EvaluateUnlocks(true);
        for (mod in modInfos) {
            PostAllModDataLoaded(index, mod);
        }""",
         """    public function LoadUserData(index:Int):Void {
        mvz2.states.BootTrace.step('PROBE LoadUserData.enter index=${index}');
        modSaveDatas = [];
        var modInfos = Main.ModManager.GetAllModInfos();
        mvz2.states.BootTrace.step('PROBE LoadUserData mods=${modInfos.length}');
        for (mod in modInfos) {
            mvz2.states.BootTrace.step('PROBE LoadModData.before ${mod.Namespace}');
            LoadModData(index, mod);
            mvz2.states.BootTrace.step('PROBE LoadModData.after ${mod.Namespace}');
        }
        mvz2.states.BootTrace.step("PROBE EvaluateUnlocks.before");
        EvaluateUnlocks(true);
        mvz2.states.BootTrace.step("PROBE EvaluateUnlocks.after");
        for (mod in modInfos) {
            mvz2.states.BootTrace.step('PROBE PostAllModDataLoaded.before ${mod.Namespace}');
            PostAllModDataLoaded(index, mod);
            mvz2.states.BootTrace.step('PROBE PostAllModDataLoaded.after ${mod.Namespace}');
        }"""),
        ("""        OnUserLoad.dispatch(index, userName);
        Main.Game.RunCallback(LogicCallbacks.POST_USER_LOAD, param);""",
         """        mvz2.states.BootTrace.step('PROBE OnUserLoad.dispatch before userName=${userName}');
        OnUserLoad.dispatch(index, userName);
        mvz2.states.BootTrace.step("PROBE Main.Game.RunCallback before");
        Main.Game.RunCallback(LogicCallbacks.POST_USER_LOAD, param);
        mvz2.states.BootTrace.step("PROBE Main.Game.RunCallback after");"""),
        ("""            } catch (e:Dynamic) {
                // 加载存档失败，弹出警告。
                status.AddCorruptedUserIndex(index);""",
         """            } catch (e:Dynamic) {
                mvz2.states.BootTrace.step('PROBE LoadInitialUserData 捕获异常 index=${index}：${Std.string(e)}');
                // 加载存档失败，弹出警告。
                status.AddCorruptedUserIndex(index);"""),
        ("""            if (!MVZ2SaveExt.IsNullOrMeetsConditions(unlockConditions, Main.SaveManager))
                continue;""",
         """            mvz2.states.BootTrace.step('PROBE 解锁条件判定 save=${Main.SaveManager}');
            if (!MVZ2SaveExt.IsNullOrMeetsConditions(unlockConditions, Main.SaveManager))
            {
                mvz2.states.BootTrace.step('PROBE 解锁条件不满足 → continue');
                continue;
            }
            mvz2.states.BootTrace.step('PROBE 解锁条件满足（未 continue）');"""),
        ("""    private function EvaluateUnlockedEntities():Void {
        unlockedContraptionsCache = [];
        unlockedEnemiesCache = [];
        var resourceManager = Main.ResourceManager;
        var entities = Main.Game.GetAllEntityDefinitions();
        for (def in entities) {
            if (def == null)
                continue;
            var unlockConditions = def.GetEntityUnlock();""",
         """    private function EvaluateUnlockedEntities():Void {
        mvz2.states.BootTrace.step("PROBE EvaluateUnlockedEntities.enter");
        unlockedContraptionsCache = [];
        unlockedEnemiesCache = [];
        var resourceManager = Main.ResourceManager;
        mvz2.states.BootTrace.step('PROBE EvaluateUnlockedEntities resourceManager=${resourceManager} game=${Main.Game}');
        var entities = Main.Game.GetAllEntityDefinitions();
        mvz2.states.BootTrace.step('PROBE EvaluateUnlockedEntities entities=${entities == null ? "null" : Std.string(entities.length)}');
        var probed = 0;
        for (def in entities) {
            if (def == null)
                continue;
            if (probed < 3) { mvz2.states.BootTrace.step('PROBE entity def id=${def.GetID()}'); probed++; }
            var unlockConditions = def.GetEntityUnlock();
            mvz2.states.BootTrace.step('PROBE entity unlock fetched ok=${unlockConditions == null ? "null" : Std.string(unlockConditions)}');"""),
        ("""            var id = def.GetID();
            if (def.Type == EntityTypes.PLANT) {
                unlockedContraptionsCache.push(id);
            } else if (def.Type == EntityTypes.ENEMY) {
                unlockedEnemiesCache.push(id);
            }
        }
    }""",
         """            var id = def.GetID();
            mvz2.states.BootTrace.step('PROBE entity type ok=${def.Type}');
            if (def.Type == EntityTypes.PLANT) {
                unlockedContraptionsCache.push(id);
            } else if (def.Type == EntityTypes.ENEMY) {
                unlockedEnemiesCache.push(id);
            }
        }
        mvz2.states.BootTrace.step('PROBE EvaluateUnlockedEntities.done plants=${unlockedContraptionsCache.length} enemies=${unlockedEnemiesCache.length}');
    }"""),
        ("""    private function EvaluateUnlockedArtifacts():Void {
        unlockedArtifactsCache = [];""",
         """    private function EvaluateUnlockedArtifacts():Void {
        mvz2.states.BootTrace.step("PROBE EvaluateUnlockedArtifacts.enter");
        unlockedArtifactsCache = [];"""),
        ("""    private function EvaluateUnlockedProducts():Void {
        unlockedProductsCache = [];""",
         """    private function EvaluateUnlockedProducts():Void {
        mvz2.states.BootTrace.step("PROBE EvaluateUnlockedProducts.enter");
        unlockedProductsCache = [];"""),
        ("""    private function EvaluateUnlockedAchievements(initial:Bool):Void {
        var resourceManager = Main.ResourceManager;""",
         """    private function EvaluateUnlockedAchievements(initial:Bool):Void {
        mvz2.states.BootTrace.step("PROBE EvaluateUnlockedAchievements.enter");
        var resourceManager = Main.ResourceManager;"""),
        ("""        mvz2.states.BootTrace.step("PROBE EvaluateUnlockedArtifacts.enter");
        unlockedArtifactsCache = [];
        var game = Main.Game;
        var artifacts = game.GetAllArtifactDefinitions();""",
         """        mvz2.states.BootTrace.step("PROBE EvaluateUnlockedArtifacts.enter");
        unlockedArtifactsCache = [];
        var game = Main.Game;
        mvz2.states.BootTrace.step('PROBE EvaluateUnlockedArtifacts game=${game}');
        var artifacts = game.GetAllArtifactDefinitions();
        mvz2.states.BootTrace.step('PROBE EvaluateUnlockedArtifacts artifacts=${artifacts == null ? "null" : Std.string(artifacts.length)}');"""),
    ])
    return ok


# ---------------------------------------------------------------- 工程接线
OVERLAY_LINE = '\t<source path="C:/Users/34275/AppData/Local/Temp/mvz2_cppfix" />'


def inject_cp(project_dir):
    """给 verify_pointer 的 Project.xml 临时加一行覆盖层 -cp（自带备份）。"""
    path = os.path.join(project_dir, "Project.xml")
    s = open(path, encoding="utf-8").read()
    if OVERLAY_LINE.strip() in s:
        return False
    bak = path + ".probe-bak"
    if not os.path.exists(bak):
        shutil.copyfile(path, bak)
    s = s.replace('\t<source path="../../source" />',
                  '\t<source path="../../source" />\n' + OVERLAY_LINE, 1)
    open(path, "w", encoding="utf-8", newline=NL).write(s)
    print("已把覆盖层 -cp 注入", path, "（备份：Project.xml.probe-bak）")
    return True


def restore_cp(project_dir):
    path = os.path.join(project_dir, "Project.xml")
    bak = path + ".probe-bak"
    if not os.path.exists(bak):
        print("没有备份，无需还原")
        return
    shutil.copyfile(bak, path)
    os.remove(bak)
    print("已还原", path)


# ---------------------------------------------------------------- 构建 / 运行
def build(project_dir, release):
    cmd = ["haxelib", "run", "lime", "build", "windows"]
    if not release:
        cmd += ["-debug", "-DHXCPP_CHECK_POINTER"]
    log = os.path.join(LOG_DIR, "build.log")
    print(">>", " ".join(cmd), "（cwd=%s）" % project_dir)
    with open(log, "w", encoding="utf-8", errors="replace") as f:
        p = subprocess.run(cmd, cwd=project_dir, stdout=f, stderr=subprocess.STDOUT,
                           shell=(os.name == "nt"))
    print("   构建 exit=%d  log=%s" % (p.returncode, log))
    return p.returncode == 0


def run(project_dir, seconds):
    bin_dir = os.path.join(project_dir, "export", "windows", "bin")
    exe = os.path.join(bin_dir, "MVZ2.exe")
    trace = os.path.join(bin_dir, "boot-trace.log")
    if os.path.exists(trace):
        os.remove(trace)
    print(">>", exe, "（cwd=%s，运行 %ds 后结束）" % (bin_dir, seconds))
    p = subprocess.Popen([exe], cwd=bin_dir,
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    t0 = time.time()
    while time.time() - t0 < seconds:
        time.sleep(0.5)
        if p.poll() is not None:
            break
    alive = p.poll() is None
    if alive:
        p.kill()
    print("   进程 exit=%s（%s）存活=%.1fs" % (p.poll(), "未退出/被结束" if alive else "自行退出",
                                             time.time() - t0))
    if not os.path.exists(trace):
        print("   !! 没有 boot-trace.log")
        return
    lines = [l for l in open(trace, encoding="utf-8", errors="replace").read().splitlines() if l.strip()]
    print("   boot-trace 末尾 25 行：")
    for line in lines[-25:]:
        print("     " + line)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--release", action="store_true", help="用 verify_build（release）复现静默段错误")
    ap.add_argument("--no-build", action="store_true")
    ap.add_argument("--restore", action="store_true")
    ap.add_argument("--run-seconds", type=int, default=45)
    args = ap.parse_args()

    os.makedirs(LOG_DIR, exist_ok=True)
    project_dir = BUILD if args.release else POINTER

    if args.restore:
        restore_cp(POINTER)
        return 0

    src_hash = subprocess.run(
        "find source -name '*.hx' | sort | xargs md5sum | md5sum",
        cwd=ROOT, shell=True, capture_output=True, text=True).stdout.split()[0][:16]
    print("source hash =", src_hash)

    if not args.no_build:
        print("生成探针覆盖层 ->", OUT)
        if not make_overlay():
            print("!! 覆盖层生成失败（source 结构变了？），已终止")
            return 1
        if not args.release:
            inject_cp(POINTER)
        if not build(project_dir, args.release):
            return 1
    run(project_dir, args.run_seconds)
    return 0


if __name__ == "__main__":
    sys.exit(main())
