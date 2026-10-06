// Ported from: Assets/Scripts/MVZ2/Level/Components/LogicComponent.cs
package mvz2.level.components;

import mvz2.level.LevelController;
import mvz2logic.Global;
import mvz2logic.level.components.ComponentInterfaces.ILogicComponent;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import system.threading.tasks.Task;
import mvz2.level.LevelManager;
import Main;

class LogicComponent extends MVZ2Component implements ILogicComponent
{
	public function new(level:LevelEngine, controller:LevelController)
	{
		super(level, componentID, controller);
	}
	public function BeginLevel():Void
	{
		Controller.StartLevelIntroTransition();
	}
	public function StopLevel():Void
	{
		Controller.StopLevel();
	}
	public function SaveStateData():Void
	{
		Main.LevelManager.SaveLevel();
	}
	public function ReloadLevel():Task
	{
		return Controller.ReloadLevel();
	}
	public function IsGamePaused():Bool
	{
		return Controller.IsGamePaused();
	}
	public function IsGameStarted():Bool
	{
		return Controller.IsGameStarted();
	}
	public function IsGameOver():Bool
	{
		return Controller.IsGameOver();
	}
	public function IsGameRunning():Bool
	{
		return Controller.IsGameRunning();
	}
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var componentID(get, never):NamespaceID;
	private static var _componentID:NamespaceID;
	static function get_componentID():NamespaceID
	{
		if (_componentID == null) _componentID = new NamespaceID(Global.BuiltinNamespace, "logic");
		return _componentID;
	}
}
