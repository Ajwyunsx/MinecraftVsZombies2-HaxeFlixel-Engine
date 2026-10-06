// Ported from: Assets/Scripts/MVZ2/Level/Components/HeldItemComponent.cs
package mvz2.level.components;

import mvz2.level.LevelController;
import mvz2logic.Global;
// PORT-NOTE: MissingDefinitionException 实际声明在 pvzengine/base/MissingDefinitionException.hx。
import pvzengine.base.MissingDefinitionException;
import mvz2logic.helditems.HeldItemBuilder;
import mvz2logic.helditems.HeldItemData;
import mvz2logic.helditems.HeldItemDefinition;
import mvz2logic.helditems.IHeldItemBuilder;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.LogicHeldTypes;
import mvz2logic.level.components.ComponentInterfaces.IHeldItemComponent;
import pvzengine.NamespaceID;
import pvzengine.level.ISerializableLevelComponent;
import pvzengine.level.LevelEngine;
import pvzengine.models.IModelInterface;
import pvzengine.Log;
// PORT-NOTE: C# 的扩展方法（this 参数形式）在 Haxe 中需显式 using 才能以 `obj.Method()` 调用。
using mvz2logic.games.LogicGameDefinitionsExt;     // GetHeldItemDefinition(this IGameContent, heldType)
using mvz2logic.helditems.LogicHeldItemExt;        // GetDefinition(this IHeldItemData, level)

class HeldItemComponent extends MVZ2Component implements IHeldItemComponent
{
	public function new(level:LevelEngine, controller:LevelController)
	{
		super(level, componentID, controller);
		info = new HeldItemData(LogicHeldTypes.none);
	}
	override public function PostAttach(level:LevelEngine):Void
	{
		super.PostAttach(level);
		ResetHeldItem();
	}
	override public function Update():Void
	{
		super.Update();
		var definition = GetHeldItemDefinition();
		if (definition != null)
		{
			definition.Update(Level, Data);
		}
	}
	public function IsHoldingItem():Bool
	{
		var type = Data.Type;
		return NamespaceID.IsValid(type) && type != LogicHeldTypes.none;
	}
	public function SetHeldItem(builder:IHeldItemBuilder):Void
	{
		if (IsHoldingItem() && info.Priority > builder.Priority)
			return;
		var definition = Level.Content.GetHeldItemDefinition(builder.Type);
		if (definition == null)
		{
			var exception = new MissingDefinitionException('Trying to set a missing held item definition ${builder.Type}.');
			Log.LogException(exception);
			return;
		}

		var before = GetHeldItemDefinition();
		if (before != null)
			before.End(Level, Data);

		info.Build(builder);
		Controller.SetHeldItemUI(info);

		definition.Begin(Level, Data);
		Controller.UpdateEntityHeldTargetColliders(definition.GetHeldTargetMask(Level));
	}
	public function GetHeldItemModelInterface():IModelInterface
	{
		return Controller.GetHeldItemModelInterface();
	}
	public function ResetHeldItem():Void
	{
		var type = LogicHeldTypes.none;
		var definition = Level.Content.GetHeldItemDefinition(type);
		if (definition == null)
		{
			var exception = new MissingDefinitionException('Trying to set a missing held item definition $type.');
			Log.LogException(exception);
			return;
		}
		var before = GetHeldItemDefinition();
		if (before != null)
			before.End(Level, Data);

		var builder = new HeldItemBuilder(type, 0);
		info.Build(builder);
		Controller.SetHeldItemUI(info);

		Controller.UpdateEntityHeldTargetColliders(definition.GetHeldTargetMask(Level));
	}
	public function CancelHeldItem():Bool
	{
		if (!IsHoldingItem() || info.CannotCancel())
			return false;
		ResetHeldItem();
		return true;
	}
	private function GetHeldItemDefinition():HeldItemDefinition
	{
		return Data.GetDefinition(Level);
	}
	public var Data(get, never):IHeldItemData;
	function get_Data():IHeldItemData return info;
	private var info:HeldItemData;
	// PORT-NOTE: C# 的 static readonly 字段是首次使用时才初始化；hxcpp 会在 main() 之前执行全部静态初始化
	// （__boot_all()），那时 Global.Game / MainManager.Instance 仍为 null，直接求值会段错误。
	// 此处改为惰性 getter（结果缓存一次，等价于 C# 的 readonly static），还原 C# 语义。
	public static var componentID(get, never):NamespaceID;
	private static var _componentID:NamespaceID;
	static function get_componentID():NamespaceID
	{
		if (_componentID == null) _componentID = new NamespaceID(Global.BuiltinNamespace, "heldItem");
		return _componentID;
	}
}

class EmptySerializableLevelComponent implements ISerializableLevelComponent
{
	public function new() {}
}
