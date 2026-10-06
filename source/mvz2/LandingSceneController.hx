// Ported from: Assets/Scripts/Loader/LandingSceneController.cs

package mvz2;

import mvz2.managers.MainManager;
import mvz2.modding.ModManager;
import mvz2.modding.ModLoader;
import mvz2.vanilla.VanillaMod;
import mvz2logic.LogicMain;
import unity.MonoBehaviour;
import unity.scenemanagement.LoadSceneMode;
import unity.scenemanagement.SceneManager;
import system.reflection.Assembly;
import mvz2.gamecontent.commands.Load;
import Main;
import mvz2.modding.ModManager.IModManager;

class LandingSceneController extends MonoBehaviour {
	private function Start():Void {
		// PORT-NOTE: C# 事件 `ModManager.OnRegisterMods += RegisterMod`（Action<IModManager>）→ flixel FlxTypedSignal。
		ModManager.OnRegisterMods.add(RegisterMod);
		// PORT-NOTE: 原代码为 Addressables.LoadSceneAsync("Main", LoadSceneMode.Single)；
		// 移植层没有 Addressables 场景目录，改为等价的场景名→FlxState 切换（PORTING.md §SceneManager）。
		SceneManager.LoadSceneAsync("Main", LoadSceneMode.Single);
	}

	private static function RegisterMod(manager:IModManager):Void {
		var mod = new VanillaMod();
		// PORT-NOTE: C# Assembly.GetAssembly(typeof(X)) → system.reflection.Assembly shim（以类型名占位）。
		var assemblies:Array<system.reflection.Assembly> = [
			system.reflection.Assembly.GetAssembly(VanillaMod),
			system.reflection.Assembly.GetAssembly(LogicMain)
		];
		var main = MainManager.Instance;
		var game = main.Game;
		var modLoader = new ModLoader(main);
		modLoader.Load(mod, assemblies);
		mod.Init(game);
		manager.RegisterMod(mod);
	}
}
