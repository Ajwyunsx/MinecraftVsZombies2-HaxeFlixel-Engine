package mvz2.modding;

import mvz2.globalgames.GlobalGame;
import mvz2.level.LevelManager;
import mvz2.managers.MainManager;
import mvz2logic.modding.IModLogic;
import mvz2.modding.ModManager;
import unity.MonoBehaviour;
import unity.Task;
import unity.addressableassets.Addressables;
import Main;
import mvz2.modding.ModManager.IModManager;
import flixel.util.FlxSignal.FlxTypedSignal;

// Ported from: Assets/Scripts/MVZ2/Modding/ModManager.cs
class ModManager extends MonoBehaviour implements IModManager {
    public function LoadModInfos(game:GlobalGame):Task {
        // C#: var locator = await Addressables.InitializeAsync().Task;
        // PORT-NOTE: 移植层的 AsyncOperationHandle.Task 就是已完成的资源对象（没有异步调度），
        // 目录即 assets/resource_manifest.json（见 unity.addressableassets.ResourceManifest）。
        // PORT-NOTE: 在取目录之前先接入各资源管线自己的清单（音频清单见 mvz2.audios.AudioManifest）：
        // 它们会把语义对象登记进 Addressables 的进程内注册表，Addressables.LoadAssetAsync 优先命中注册表。
        // 后续新增的资源管线（精灵/模型/字体…）也应在此处接入。
        mvz2.audios.AudioManifest.attach();
        var locator:Dynamic = Addressables.InitializeAsync().Task;
        var info = new ModInfo(main.BuiltinNamespace, locator);
        info.LevelDataVersion = LevelManager.CURRENT_DATA_VERSION;
        info.DisplayName = "Vanilla";
        info.CatalogPath = null;
        info.IsBuiltin = true;
        modInfos.push(info);
        return Task.completedTask();
    }
    public function InitModLogics(game:GlobalGame):Void {
        OnRegisterMods.dispatch(this);

        for (modInfo in modInfos) {
            if (modInfo.Logic != null) modInfo.Logic.LateInit(game);
        }
    }
    public function LoadModLogics(game:GlobalGame):Void {
        for (modInfo in modInfos) {
            if (modInfo.Logic == null)
                continue;
            game.AddMod(modInfo.Logic);
        }
    }
    public function PostReloadMods(game:GlobalGame):Void {
        for (modInfo in GetAllModInfos()) {
            if (modInfo.Logic != null) modInfo.Logic.PostReloadMods(game);
        }
    }
    public function PostGameInit():Void {
        for (modInfo in GetAllModInfos()) {
            if (modInfo.Logic != null) modInfo.Logic.PostGameInit();
        }
    }
    public function RegisterMod(logic:IModLogic):Void {
        var modInfo = GetModInfo(logic.Namespace);
        if (modInfo == null)
            return;
        modInfo.Logic = logic;
    }
    public function GetModInfo(nsp:String):ModInfo {
        return Lambda.find(modInfos, m -> m.Namespace == nsp);
    }
    public function GetAllModInfos():Array<ModInfo> {
        return Lambda.array(modInfos);
    }
    public static var OnRegisterMods:FlxTypedSignal<IModManager->Void> = new FlxTypedSignal();
    public var Main(get, never):MainManager;
    inline function get_Main():MainManager return main;

    @:serializeField
    private var main:MainManager = null;
    private var modInfos:Array<ModInfo> = [];
}

interface IModManager {
    public function RegisterMod(logic:IModLogic):Void;
}
