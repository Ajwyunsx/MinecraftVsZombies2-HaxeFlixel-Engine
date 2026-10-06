// Ported from: Assets/Scripts/MVZ2/Level/Components/TalkComponent.cs
package mvz2.level.components;

import mvz2.level.LevelController;
import mvz2logic.Global;
import mvz2logic.level.components.ComponentInterfaces.ITalkComponent;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;

class TalkComponent extends MVZ2Component implements ITalkComponent
{
	public function new(level:LevelEngine, controller:LevelController)
	{
		super(level, componentID, controller);
	}
	public function StartTalk(id:NamespaceID, section:Int, delay:Float = 1, onEnd:Void->Void = null):Void
	{
		Controller.StartTalk(id, section, delay, onEnd);
	}
	public function WillSkipTalk(id:NamespaceID, section:Int):Bool
	{
		return Controller.WillSkipTalk(id, section);
	}
	public function AutoSkipTalks(id:NamespaceID, section:Int, onSkipped:Void->Void = null):Void
	{
		Controller.AutoSkipTalks(id, section, onSkipped);
	}
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var componentID(get, never):NamespaceID;
	private static var _componentID:NamespaceID;
	static function get_componentID():NamespaceID
	{
		if (_componentID == null) _componentID = new NamespaceID(Global.BuiltinNamespace, "talk");
		return _componentID;
	}
}
