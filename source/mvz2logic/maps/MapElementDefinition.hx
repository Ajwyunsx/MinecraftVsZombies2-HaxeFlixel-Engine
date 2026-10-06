// Ported from: Assets/Scripts/Logic/Maps/MapElementDefinition.cs
package mvz2logic.maps;

import mvz2logic.definitions.LogicDefinitionTypes;
import pvzengine.IGameContent;
import pvzengine.NamespaceID;
import pvzengine.base.Definition;
import pvzengine.base.ICachedDefinition;
import unity.Debug;
using mvz2logic.games.LogicGameDefinitionsExt;

// abstract
class MapElementDefinition extends Definition implements ICachedDefinition
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
	public function HasBehaviourIDFromDefinition(behaviour:MapElementBehaviourDefinition):Bool
	{
		return HasBehaviourID(behaviour.GetID());
	}
	public function HasBehaviourID(id:NamespaceID):Bool
	{
		return behaviours.indexOf(id) >= 0;
	}
	public function HasBehaviour(behaviour:MapElementBehaviourDefinition):Bool
	{
		return behaviourCaches.indexOf(behaviour) >= 0;
	}
	// PORT-NOTE: C# 泛型方法 HasBehaviour<T>()，Haxe 无显式类型实参，改为传入类对象（同 pvzengine.level.StageDefinition.GetBehaviour）。
	public function HasBehaviourOfType<T>(typeClass:Class<T>):Bool
	{
		for (b in behaviourCaches)
		{
			if (Std.isOfType(b, typeClass))
				return true;
		}
		return false;
	}
	public function HasBehaviourByID(id:NamespaceID):Bool
	{
		for (b in behaviourCaches)
		{
			if (b.GetID() == id)
				return true;
		}
		return false;
	}
	// PORT-NOTE: C# 显式接口实现 -> Haxe 普通公开方法
	public function CacheContents(content:IGameContent):Void
	{
		behaviourCaches = [];
		for (behaviourID in behaviours)
		{
			var behaviour = content.GetMapElementBehaviourDefinition(behaviourID);
			if (behaviour == null)
			{
				Debug.LogWarning('Cannot find map element behaviour with ID ${behaviourID}');
				continue;
			}
			behaviourCaches.push(behaviour);
		}
	}
	public function ClearCaches():Void
	{
		behaviourCaches = [];
	}
	// PORT-NOTE: C# 泛型方法 GetBehaviour<T>()，Haxe 无显式类型实参，改为传入类对象。
	public function GetBehaviour<T>(typeClass:Class<T>):Null<T>
	{
		for (behaviour in behaviourCaches)
		{
			if (Std.isOfType(behaviour, typeClass))
				return cast behaviour;
		}
		return null;
	}
	public function GetBehaviourAt(behaviour:Int):MapElementBehaviourDefinition
	{
		return behaviourCaches[behaviour];
	}
	public function GetBehaviourCount():Int
	{
		return behaviourCaches.length;
	}
	// PORT-NOTE: C# 泛型方法 GetBehaviours<T>()，Haxe 无显式类型实参，改为传入类对象。
	public function GetBehaviours<T>(typeClass:Class<T>):Array<T>
	{
		var result:Array<T> = [];
		for (b in behaviourCaches)
		{
			if (Std.isOfType(b, typeClass))
				result.push(cast b);
		}
		return result;
	}
	public function OnClick(element:IMapElement):Void
	{
		for (behaviour in behaviourCaches)
		{
			behaviour.OnClick(element);
		}
	}
	public override function GetDefinitionType():String
	{
		return LogicDefinitionTypes.MAP_ELEMENT;
	}
	private var behaviours:Array<NamespaceID> = [];
	private var behaviourCaches:Array<MapElementBehaviourDefinition> = [];
}
