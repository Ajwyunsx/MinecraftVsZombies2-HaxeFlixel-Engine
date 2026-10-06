// Ported from: Assets/Scripts/Engine/Level/Placements/PlacementDefinition.cs
package pvzengine.placements;

import pvzengine.NamespaceID;
import pvzengine.base.Definition;
import pvzengine.definitions.EngineDefinitionTypes;
import pvzengine.entities.EntityDefinition;
import pvzengine.grids.LawnGrid;

// PORT-NOTE: C# 为 `abstract class PlacementDefinition`。Haxe 无 C# 语义的抽象类关键字
//   （`abstract class` 会被解析成不可直接构造的 abstract 类型，且非标准写法），
//   按 PORTING.md「抽象类仍写 class」改写为普通 class。
class PlacementDefinition extends Definition
{
	public function new(nsp:String, name:String, condition:SpawnCondition)
	{
		super(nsp, name);
		spawnCondition = condition;
	}
	public function AddMethod(method:PlaceMethod):Void
	{
		methods.push(method);
	}
	public function RemoveMethod(method:PlaceMethod):Bool
	{
		return methods.remove(method);
	}
	// PORT-NOTE: C# 泛型方法 GetMethod<T>()，Haxe 调用点无法书写类型参数
	//   （见 mvz2/gamecontent/helditems/BlueprintHeldItemBehaviour.hx: `placementDef.GetMethod(IEntityTwinklePlaceMethod)`），
	//   按工程既有约定改为传入类型对象（Class<T>）。
	public function GetMethod<T>(cls:Class<T>):Null<T>
	{
		for (method in methods)
		{
			if (Std.isOfType(method, cls))
				return cast method;
		}
		return null;
	}
	public function ValidateSpawn(grid:LawnGrid, entity:EntityDefinition):Bool
	{
		var e = spawnCondition.GetSpawnError(this, grid, entity);
		return !NamespaceID.IsValid(e);
	}
	public function GetSpawnError(grid:LawnGrid, entity:EntityDefinition):Null<NamespaceID>
	{
		return spawnCondition.GetSpawnError(this, grid, entity);
	}
	public function GetPlaceError(grid:LawnGrid, entity:EntityDefinition):Null<NamespaceID>
	{
		var error:Null<NamespaceID> = null;
		for (method in methods)
		{
			var e = method.GetPlaceError(this, grid, entity);
			if (!NamespaceID.IsValid(e))
			{
				return null;
			}
			if (error == null)
			{
				error = e;
			}
		}
		return error;
	}
	public function PlaceEntity(grid:LawnGrid, entity:EntityDefinition, param:PlaceParams):PlaceOutput
	{
		for (method in methods)
		{
			var e = method.GetPlaceError(this, grid, entity);
			if (!NamespaceID.IsValid(e))
			{
				return method.PlaceEntity(this, grid, entity, param);
			}
		}
		return PlaceOutput.InvalidOutput;
	}
	public override function GetDefinitionType():String return EngineDefinitionTypes.PLACEMENT;
	private var spawnCondition:SpawnCondition;
	private var methods:Array<PlaceMethod> = [];
}
