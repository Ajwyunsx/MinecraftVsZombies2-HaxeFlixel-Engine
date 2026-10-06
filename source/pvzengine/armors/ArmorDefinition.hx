// Ported from: Assets/Scripts/Engine/Level/Armors/ArmorDefinition.cs
// PORT-NOTE: C# 的重载 HasBehaviourID(ArmorBehaviourDefinition) / HasBehaviourID(NamespaceID)、
//   HasBehaviour(ArmorBehaviourDefinition) / HasBehaviour<T>() / HasBehaviour(NamespaceID)、
//   GetBehaviour<T>(), GetBehaviours<T>() 在 Haxe 中不支持重载与显式类型参数调用，
//   故统一为「一个方法名 + Dynamic 形参」（可为 Class<T> / ArmorBehaviourDefinition 实例 / NamespaceID），
//   与既有调用点 `.HasBehaviour(this)`、`.GetBehaviours(ICollectBehaviour)` 保持一致。
// PORT-NOTE: C# ColliderConstructor[] / IEnumerable<ColliderConstructor> → Haxe Array<ColliderConstructor>。
// PORT-NOTE: NamespaceID 是 abstract，不能作为运行期值用于 Std.isOfType，故改为
//   `Std.isOfType(key, String)`（NamespaceID 底层即 String，语义等价，见 NamespaceID.hx 的说明）。
package pvzengine.armors;

import pvzengine.EngineModelID;
import pvzengine.IGameContent;
import pvzengine.NamespaceID;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.base.Definition;
import pvzengine.base.ICachedDefinition;
import pvzengine.collisions.ColliderConstructor;
import pvzengine.definitions.EngineDefinitionTypes;
import pvzengine.entities.Entity;
using pvzengine.ContentProviderHelper;

class ArmorDefinition extends Definition implements ICachedDefinition
{
	public function new(nsp:String, name:String, constructors:Array<ColliderConstructor>)
	{
		super(nsp, name);
		colliderConstructors = constructors;
	}
	public function AddBehaviourID(behaviour:NamespaceID):Void
	{
		behaviours.push(behaviour);
	}
	public function RemoveBehaviourID(behaviour:NamespaceID):Bool
	{
		return behaviours.remove(behaviour);
	}
	// C#: bool HasBehaviourID(ArmorBehaviourDefinition behaviour) / bool HasBehaviourID(NamespaceID id)
	public function HasBehaviourID(key:Dynamic):Bool
	{
		if (Std.isOfType(key, String))
		{
			return behaviours.indexOf(cast key) >= 0;
		}
		var behaviour:ArmorBehaviourDefinition = cast key;
		return HasBehaviourID(behaviour.GetID());
	}
	// C#: bool HasBehaviour(ArmorBehaviourDefinition) / bool HasBehaviour<T>() / bool HasBehaviour(NamespaceID)
	public function HasBehaviour(key:Dynamic):Bool
	{
		if (Std.isOfType(key, String))
		{
			var id:NamespaceID = cast key;
			return Lambda.exists(behaviourCaches, b -> b.GetID() == id);
		}
		else if (Std.isOfType(key, ArmorBehaviourDefinition))
		{
			// C# 重载 HasBehaviour(ArmorBehaviourDefinition behaviour) → behaviourCaches.Contains(behaviour)
			return behaviourCaches.indexOf(cast key) >= 0;
		}
		return Lambda.exists(behaviourCaches, b -> Std.isOfType(b, key));
	}
	// C#: public T? GetBehaviour<T>() where T : ArmorBehaviourDefinition
	// PORT-NOTE: 调用点无法书写类型参数，改为传入类对象；未传入时返回第一个行为定义。
	public function GetBehaviour<T:ArmorBehaviourDefinition>(?type:Class<T>):Null<T>
	{
		if (type == null)
		{
			return behaviourCaches.length > 0 ? cast behaviourCaches[0] : null;
		}
		for (behaviour in behaviourCaches)
		{
			if (Std.isOfType(behaviour, type))
				return cast behaviour;
		}
		return null;
	}
	public function GetBehaviourAt(behaviour:Int):ArmorBehaviourDefinition
	{
		return behaviourCaches[behaviour];
	}
	public function GetBehaviourCount():Int
	{
		return behaviourCaches.length;
	}
	// C#: public T[] GetBehaviours<T>() where T : ArmorBehaviourDefinition
	public function GetBehaviours<T:ArmorBehaviourDefinition>(?type:Class<T>):Array<T>
	{
		var result:Array<T> = [];
		for (behaviour in behaviourCaches)
		{
			if (type == null || Std.isOfType(behaviour, type))
			{
				result.push(cast behaviour);
			}
		}
		return result;
	}
	public function PostUpdate(armor:Armor):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.PostUpdate(armor);
		}
	}
	// C#: void ICachedDefinition.CacheContents(IGameContent content)
	public function CacheContents(content:IGameContent):Void
	{
		behaviourCaches.resize(0);
		for (behaviourID in behaviours)
		{
			var behaviour = content.GetArmorBehaviourDefinition(behaviourID);
			if (behaviour == null)
				continue;
			behaviourCaches.push(behaviour);
		}
	}
	// C#: void ICachedDefinition.ClearCaches()
	public function ClearCaches():Void
	{
		behaviourCaches.resize(0);
	}
	public function GetModelID():NamespaceID
	{
		// PORT-NOTE: C# GetID().ToModelID(EngineModelID.TYPE_ARMOR) 为 EngineModelID 上的扩展方法，
		//   此处按 PORTING.md「扩展方法改为静态普通方法」使用静态调用形式。
		return EngineModelID.ToModelID(GetID(), EngineModelID.TYPE_ARMOR);
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
	// virtual
	public function GetColliderConstructors(entity:Entity, slotID:NamespaceID):Array<ColliderConstructor>
	{
		return colliderConstructors;
	}
	public override function GetDefinitionType():String
	{
		// C#: sealed override
		return EngineDefinitionTypes.ARMOR;
	}
	// C#: protected ColliderConstructor[] colliderConstructors
	private var colliderConstructors:Array<ColliderConstructor>;
	private var behaviours:Array<NamespaceID> = [];
	private var behaviourCaches:Array<ArmorBehaviourDefinition> = [];
}
