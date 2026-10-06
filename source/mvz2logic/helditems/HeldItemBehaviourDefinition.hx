// Ported from: Assets/Scripts/Logic/HeldItems/HeldItemBehaviourDefinition.cs
package mvz2logic.helditems;

import mvz2logic.definitions.LogicDefinitionTypes;
import mvz2logic.inputs.PointerInteractionData;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.base.Definition;
import pvzengine.callbacks.CallbackResult;
import pvzengine.level.LevelEngine;
import pvzengine.models.IModelInterface;

// abstract
class HeldItemBehaviourDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public function GetHeldTargetMask(level:LevelEngine):HeldTargetFlag
	{
		return HeldTargetFlag.None;
	}
	public function IsValidFor(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerInteractionData):Bool
	{
		return false;
	}
	public function GetHighlight(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerInteractionData):HeldHighlight
	{
		return HeldHighlight.None;
	}
	public function OnBegin(level:LevelEngine, data:IHeldItemData):Void
	{
	}
	public function OnEnd(level:LevelEngine, data:IHeldItemData):Void
	{
	}
	public function OnUpdate(level:LevelEngine, data:IHeldItemData):Void
	{
	}
	public function OnPointerEvent(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Void
	{
	}
	public function OnSetModel(level:LevelEngine, data:IHeldItemData, model:Null<IModelInterface>):Void
	{
	}
	public function GetModelID(level:LevelEngine, data:IHeldItemData, result:CallbackResult):Void
	{
	}
	public function GetModelOffset(level:LevelEngine, data:IHeldItemData, result:CallbackResult):Void
	{
	}
	public function GetRadius(level:LevelEngine, data:IHeldItemData, result:CallbackResult):Void
	{
	}
	public function ResetHeldItemIfType(level:LevelEngine, type:NamespaceID):Void
	{
		if (!NamespaceID.IsValid(type))
			return;
		if (LogicLevelExt.GetHeldItemType(level) == type)
		{
			LogicLevelExt.ResetHeldItem(level);
		}
	}
	public override function GetDefinitionType():String return LogicDefinitionTypes.HELD_ITEM_BEHAVIOUR;
}
