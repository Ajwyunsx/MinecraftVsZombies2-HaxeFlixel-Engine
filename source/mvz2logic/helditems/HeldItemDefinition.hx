// Ported from: Assets/Scripts/Logic/HeldItems/HeldItemDefinition.cs
package mvz2logic.helditems;

import Lambda;
import mvz2logic.definitions.LogicDefinitionTypes;
import mvz2logic.games.LogicGameDefinitionsExt;
import mvz2logic.inputs.PointerData;
import mvz2logic.inputs.PointerInteraction;
import mvz2logic.inputs.PointerInteractionData;
import pvzengine.IGameContent;
import pvzengine.NamespaceID;
import pvzengine.base.Definition;
import pvzengine.base.ICachedDefinition;
import pvzengine.callbacks.CallbackResult;
import pvzengine.level.LevelEngine;
import pvzengine.models.IModelInterface;
import unity.Vector3;

// abstract
class HeldItemDefinition extends Definition implements ICachedDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	// C#: protected void AddBehaviour(NamespaceID behaviour)
	public function AddBehaviour(behaviour:NamespaceID):Void
	{
		behaviours.push(behaviour);
	}
	public function HasBehaviour(level:LevelEngine, data:IHeldItemData, behaviour:HeldItemBehaviourDefinition):Bool
	{
		var cached = GetBehaviours();
		return cached != null ? Lambda.has(cached, behaviour) : false;
	}
	public function Begin(level:LevelEngine, data:IHeldItemData):Void
	{
		for (behaviour in GetBehaviours())
		{
			behaviour.OnBegin(level, data);
		}
	}
	public function End(level:LevelEngine, data:IHeldItemData):Void
	{
		for (behaviour in GetBehaviours())
		{
			behaviour.OnEnd(level, data);
		}
	}
	public function Update(level:LevelEngine, data:IHeldItemData):Void
	{
		for (behaviour in GetBehaviours())
		{
			behaviour.OnUpdate(level, data);
		}
	}

	public function CacheContents(content:IGameContent):Void
	{
		for (id in behaviours)
		{
			var behaviour = LogicGameDefinitionsExt.GetHeldItemBehaviourDefinition(content, id);
			if (behaviour == null)
				continue;
			behavioursCache.push(behaviour);
		}
	}

	public function ClearCaches():Void
	{
		behavioursCache.resize(0);
	}
	public function GetHeldTargetMask(level:LevelEngine):HeldTargetFlag
	{
		var mask = HeldTargetFlag.None;
		for (behaviour in GetBehaviours())
		{
			mask |= behaviour.GetHeldTargetMask(level);
		}
		return mask;
	}
	public function IsValidFor(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerData):Bool
	{
		var interactionData = new PointerInteractionData();
		interactionData.pointer = pointer;
		interactionData.interaction = PointerInteraction.Hover;
		for (behaviour in GetBehaviours())
		{
			if (behaviour.IsValidFor(target, data, interactionData))
				return true;
		}
		return false;
	}
	public function GetHighlight(target:IHeldItemTarget, data:IHeldItemData, pointer:PointerData):HeldHighlight
	{
		var interactionData = new PointerInteractionData();
		interactionData.pointer = pointer;
		interactionData.interaction = PointerInteraction.Hover;
		for (behaviour in GetBehaviours())
		{
			if (behaviour.IsValidFor(target, data, interactionData))
			{
				var highlight = behaviour.GetHighlight(target, data, interactionData);
				if (highlight.mode != HeldHighlightMode.None)
					return highlight;
			}
		}
		return HeldHighlight.None;
	}
	public function DoPointerEvent(target:IHeldItemTarget, data:IHeldItemData, pointerParams:PointerInteractionData):Void
	{
		for (behaviour in GetBehaviours())
		{
			if (behaviour.IsValidFor(target, data, pointerParams))
			{
				behaviour.OnPointerEvent(target, data, pointerParams);
			}
		}
	}
	public function PostSetModel(level:LevelEngine, data:IHeldItemData, model:Null<IModelInterface>):Void
	{
		for (behaviour in GetBehaviours())
		{
			behaviour.OnSetModel(level, data, model);
		}
	}
	public function GetModelID(level:LevelEngine, data:IHeldItemData):Null<NamespaceID>
	{
		var callbackResult = new CallbackResult(null);
		for (behaviour in GetBehaviours())
		{
			if (callbackResult.IsBreakRequested)
				break;
			behaviour.GetModelID(level, data, callbackResult);
		}
		// TODO-PORT: C# 为 callbackResult.GetValue<NamespaceID>()，Haxe 无法在无参情况下推断泛型参数，按非泛型形式调用。
		return callbackResult.GetValue();
	}
	public function GetModelOffset(level:LevelEngine, data:IHeldItemData):Vector3
	{
		var callbackResult = new CallbackResult(null);
		for (behaviour in GetBehaviours())
		{
			if (callbackResult.IsBreakRequested)
				break;
			behaviour.GetModelOffset(level, data, callbackResult);
		}
		// TODO-PORT: C# 为 callbackResult.GetValue<Vector3>()，Haxe 无法在无参情况下推断泛型参数，按非泛型形式调用。
		return callbackResult.GetValue();
	}
	public function GetRadius(level:LevelEngine, data:IHeldItemData):Float
	{
		var callbackResult = new CallbackResult(0);
		for (behaviour in GetBehaviours())
		{
			if (callbackResult.IsBreakRequested)
				break;
			behaviour.GetRadius(level, data, callbackResult);
		}
		// TODO-PORT: C# 为 callbackResult.GetValue<float>()，Haxe 无法在无参情况下推断泛型参数，按非泛型形式调用。
		return callbackResult.GetValue();
	}
	// TODO-PORT: C# 泛型方法 GetBehaviour<T>()，Haxe 无法在无参情况下推断泛型参数，改为传入类型。
	public function GetBehaviour<T:HeldItemBehaviourDefinition>(type:Class<T>):T
	{
		return cast Lambda.find(behavioursCache, function(b) return Std.isOfType(b, type));
	}
	public function GetBehaviours():Array<HeldItemBehaviourDefinition>
	{
		return behavioursCache;
	}
	public override function GetDefinitionType():String return LogicDefinitionTypes.HELD_ITEM;

	// C#: public bool Exclusive { get; protected set; } = true;
	public var Exclusive:Bool = true;
	private var behaviours:Array<NamespaceID> = [];
	private var behavioursCache:Array<HeldItemBehaviourDefinition> = [];
}
