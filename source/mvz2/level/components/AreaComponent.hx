// Ported from: Assets/Scripts/MVZ2/Level/Components/AreaComponent.cs
package mvz2.level.components;

import mvz2.level.LevelController;
import mvz2logic.Global;
import mvz2logic.level.components.ComponentInterfaces.IAreaComponent;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import pvzengine.models.IModelInterface;

class AreaComponent extends MVZ2Component implements IAreaComponent
{
	public function new(level:LevelEngine, controller:LevelController)
	{
		super(level, componentID, controller);
	}
	public function GetAreaModelInterface():IModelInterface
	{
		return Controller.GetAreaModelInterface();
	}
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var componentID(get, never):NamespaceID;
	private static var _componentID:NamespaceID;
	static function get_componentID():NamespaceID
	{
		if (_componentID == null) _componentID = new NamespaceID(Global.BuiltinNamespace, "area");
		return _componentID;
	}
}
