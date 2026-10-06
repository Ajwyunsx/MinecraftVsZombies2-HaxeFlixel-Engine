// Ported from: Assets/Scripts/Engine/Level/Entities/EntityDefinition.cs
package pvzengine.entities;

import pvzengine.EngineModelID;
import pvzengine.IGameContent;
import pvzengine.NamespaceID;
import pvzengine.armors.Armor;
import pvzengine.armors.ArmorDestroyInfo;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.base.Definition;
import pvzengine.base.ICachedDefinition;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DamageInput;
import pvzengine.damages.DamageOutput;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EngineDefinitionTypes;
import pvzengine.modifiers.PropertyModifier;
import unity.Debug;
using pvzengine.ContentProviderHelper;
import unity.Vector3;

// PORT-NOTE: C# 的 `HasBehaviour` / `HasBehaviourID` / `GetBehaviour<T>` / `GetBehaviours<T>` 系列在 Haxe 中
//   不能重载，且调用点无法书写显式类型参数：既有调用点写作 HasBehaviour(this)、HasBehaviour(EnemyMeleeBehaviour)、
//   GetBehaviour(IEmptyHandClickBehaviour)、GetBehaviours()、GetBehaviours(IContraptionEvokeBehaviour)。
//   因此：
//     * HasBehaviour 形参为 Dynamic，按「实例 / Class<T>」运行期分派；
//     * GetBehaviour / GetBehaviours 改为可选 Class<T> 形参（省略时返回全部 / 第一个）；
//     * C# 按 NamespaceID 的重载改名 HasBehaviourIDByID / HasBehaviourByID。
@:using(pvzengine.entities.EngineEntityProps)
class EntityDefinition extends Definition implements ICachedDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public function AddBehaviourID(behaviour:NamespaceID):Void
	{
		behaviours.push(behaviour);
	}
	public function RemoveBehaviourID(behaviour:NamespaceID):Bool
	{
		return behaviours.remove(behaviour);
	}
	public function HasBehaviourID(behaviour:EntityBehaviourDefinition):Bool
	{
		return HasBehaviourIDByID(behaviour.GetID());
	}
	public function HasBehaviourIDByID(id:NamespaceID):Bool
	{
		return behaviours.indexOf(id) >= 0;
	}
	// PORT-NOTE: C# 重载 HasBehaviour(EntityBehaviourDefinition) / HasBehaviour<T>() 合并。
	public function HasBehaviour(behaviour:Dynamic):Bool
	{
		if (behaviour == null)
			return false;
		if (Std.isOfType(behaviour, EntityBehaviourDefinition))
		{
			return Lambda.indexOf(behaviourCaches, cast behaviour) >= 0;
		}
		var cls:Class<Dynamic> = cast behaviour;
		return Lambda.exists(behaviourCaches, b -> Std.isOfType(b, cls));
	}
	// PORT-NOTE: C# 重载 HasBehaviour(NamespaceID) 改名。
	public function HasBehaviourByID(id:NamespaceID):Bool
	{
		return Lambda.exists(behaviourCaches, b -> b.GetID() == id);
	}
	// C#: void ICachedDefinition.CacheContents(IGameContent content)
	public function CacheContents(content:IGameContent):Void
	{
		behaviourCaches = [];
		for (behaviourID in behaviours)
		{
			var behaviour = content.GetEntityBehaviourDefinition(behaviourID);
			if (behaviour == null)
			{
				Debug.LogWarning('Cannot find entity behaviour with ID ${behaviourID}');
				continue;
			}
			behaviourCaches.push(behaviour);
		}
	}
	public function ClearCaches():Void
	{
		behaviourCaches = [];
	}
	// PORT-NOTE: C# 泛型 GetBehaviour<T>()；调用点写作 GetBehaviour() 或 GetBehaviour(SomeBehaviourClass)。
	public function GetBehaviour<T:EntityBehaviourDefinition>(?type:Class<T>):Null<T>
	{
		for (behaviour in behaviourCaches)
		{
			if (type == null || Std.isOfType(behaviour, type))
				return cast behaviour;
		}
		return null;
	}
	public function GetBehaviourAt(index:Int):EntityBehaviourDefinition
	{
		return behaviourCaches[index];
	}
	public function GetBehaviourCount():Int
	{
		return behaviourCaches.length;
	}
	// PORT-NOTE: C# 泛型 GetBehaviours<T>()；调用点写作 GetBehaviours() 或 GetBehaviours(SomeInterfaceClass)。
	public function GetBehaviours<T:EntityBehaviourDefinition>(?type:Class<T>):Array<T>
	{
		var result:Array<T> = [];
		for (behaviour in behaviourCaches)
		{
			if (type == null || Std.isOfType(behaviour, type))
				result.push(cast behaviour);
		}
		return result;
	}
	public function Init(entity:Entity):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.Init(entity);
		}
	}
	public function Update(entity:Entity):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.Update(entity);
		}
	}
	public function PreTakeDamage(input:DamageInput, result:CallbackResult):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.PreTakeDamage(input, result);
			if (result.IsBreakRequested)
				break;
		}
	}
	public function PostTakeDamage(result:DamageOutput):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.PostTakeDamage(result);
		}
	}
	public function PostContactGround(entity:Entity, velocity:Vector3):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.PostContactGround(entity, velocity);
		}
	}
	public function PostLeaveGround(entity:Entity):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.PostLeaveGround(entity);
		}
	}
	public function PreCollision(collision:EntityCollision, callbackResult:CallbackResult):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.PreCollision(collision, callbackResult);
			if (callbackResult.IsBreakRequested)
				break;
		}
	}
	public function PostCollision(collision:EntityCollision, state:Int):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.PostCollision(collision, state);
		}
	}
	public function PreDeath(entity:Entity, deathInfo:DeathInfo, result:CallbackResult):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.PreDeath(entity, deathInfo, result);
		}
	}
	public function PostDeath(entity:Entity, deathInfo:DeathInfo):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.PostDeath(entity, deathInfo);
		}
	}
	public function PostRemove(entity:Entity):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.PostRemove(entity);
		}
	}
	public function PostEquipArmor(entity:Entity, slot:NamespaceID, armor:Armor):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.PostEquipArmor(entity, slot, armor);
		}
	}
	public function PostDestroyArmor(entity:Entity, slot:NamespaceID, armor:Armor, damage:ArmorDestroyInfo):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.PostDestroyArmor(entity, slot, armor, damage);
		}
	}
	public function PostRemoveArmor(entity:Entity, slot:NamespaceID, armor:Armor):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.PostRemoveArmor(entity, slot, armor);
		}
	}
	public function GetModelID():NamespaceID
	{
		var id:NamespaceID = null;
		var out:{value:NamespaceID} = {value: null};
		if (!TryGetProperty(EngineEntityProps.MODEL_ID, out) || !NamespaceID.IsValid(out.value))
		{
			id = EngineModelID.ToModelID(GetID(), EngineModelID.TYPE_ENTITY);
		}
		else
		{
			id = out.value;
		}
		for (behaviour in behaviourCaches)
		{
			id = behaviour.GetModelID(id);
		}
		return id;
	}
	public function GetAuras():Array<AuraEffectDefinition>
	{
		var result:Array<AuraEffectDefinition> = [];
		for (behaviour in behaviourCaches)
		{
			for (aura in behaviour.GetAuras())
			{
				result.push(aura);
			}
		}
		return result;
	}
	public function GetModifiers():Array<PropertyModifier>
	{
		var result:Array<PropertyModifier> = [];
		for (behaviour in behaviourCaches)
		{
			for (modifier in behaviour.GetModifiers())
			{
				result.push(modifier);
			}
		}
		return result;
	}
	override public function GetDefinitionType():String
	{
		return EngineDefinitionTypes.ENTITY;
	}
	// C#: public abstract int Type { get; }
	public var Type(get, never):Int;
	function get_Type():Int
	{
		throw "abstract";
	}
	// PORT-NOTE: C# 的 protected 在 Haxe 中写作 private（Haxe 的 private 对子类可见）。
	private var behaviours:Array<NamespaceID> = [];
	private var behaviourCaches:Array<EntityBehaviourDefinition> = [];
}
