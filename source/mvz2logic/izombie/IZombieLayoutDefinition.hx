// Ported from: Assets/Scripts/Logic/IZombie/IZombieLayoutDefinition.cs
package mvz2logic.izombie;

import mvz2logic.definitions.LogicDefinitionTypes;
import pvzengine.NamespaceID;
import pvzengine.base.Definition;
import tools.RandomGenerator;
import unity.Vector2Int;
using tools.EnumerableExt;

// abstract
class IZombieLayoutDefinition extends Definition
{
	public function new(nsp:String, name:String, columns:Int)
	{
		super(nsp, name);
		Columns = columns;
	}
	// abstract
	public function Fill(map:IIZombieMap, rng:RandomGenerator):Void
	{
		throw "abstract";
	}
	// PORT-NOTE: C# 扩展方法（IEnumerable.Where）改为显式循环；map.CanInsert(Vector2Int, ...) 默认接口实现改为 3 参数调用。
	public function RandomFill(map:IIZombieMap, entityID:NamespaceID, rng:RandomGenerator):Void
	{
		var allGrids = map.GetAllGridPositions();
		var grids:Array<Vector2Int> = [];
		for (g in allGrids)
		{
			if (map.CanInsert(g.x, g.y, entityID))
				grids.push(g);
		}
		RandomFillAtGrids(map, grids, entityID, grids.length, rng);
	}
	// PORT-NOTE: C# 的 RandomFill(map, entityID, int count, rng) 重载改名为 RandomFillWithCount（Haxe 不支持重载）。
	public function RandomFillWithCount(map:IIZombieMap, entityID:NamespaceID, count:Int, rng:RandomGenerator):Void
	{
		var allGrids = map.GetAllGridPositions();
		var grids:Array<Vector2Int> = [];
		for (g in allGrids)
		{
			if (map.CanInsert(g.x, g.y, entityID))
				grids.push(g);
		}
		RandomFillAtGrids(map, grids, entityID, count, rng);
	}
	public function RandomFillAtLane(map:IIZombieMap, lane:Int, entityID:NamespaceID, count:Int, rng:RandomGenerator):Void
	{
		var allGrids = map.GetAllGridPositions();
		var grids:Array<Vector2Int> = [];
		for (g in allGrids)
		{
			if (g.y == lane && map.CanInsert(g.x, g.y, entityID))
				grids.push(g);
		}
		RandomFillAtGrids(map, grids, entityID, count, rng);
	}
	public function RandomFillAtColumn(map:IIZombieMap, column:Int, entityID:NamespaceID, count:Int, rng:RandomGenerator):Void
	{
		var allGrids = map.GetAllGridPositions();
		var grids:Array<Vector2Int> = [];
		for (g in allGrids)
		{
			if (g.x == column && map.CanInsert(g.x, g.y, entityID))
				grids.push(g);
		}
		RandomFillAtGrids(map, grids, entityID, count, rng);
	}
	// PORT-NOTE: C# 的 RandomFill(map, Vector2Int[] grids, entityID, count, rng) 重载改名为 RandomFillAtGrids（Haxe 不支持重载）。
	public function RandomFillAtGrids(map:IIZombieMap, grids:Array<Vector2Int>, entityID:NamespaceID, count:Int, rng:RandomGenerator):Void
	{
		if (grids.length <= 0)
			return;
		var validGrids = grids.RandomTake(count, rng);
		for (grid in validGrids)
		{
			InsertAt(map, grid, entityID);
		}
	}
	public function FillColumn(map:IIZombieMap, column:Int, entityID:NamespaceID):Void
	{
		var allGrids = map.GetAllGridPositions();
		var grids:Array<Vector2Int> = [];
		for (g in allGrids)
		{
			if (g.x == column && map.CanInsert(g.x, g.y, entityID))
				grids.push(g);
		}
		for (grid in grids)
		{
			InsertAt(map, grid, entityID);
		}
	}
	public function FillLane(map:IIZombieMap, lane:Int, entityID:NamespaceID):Void
	{
		var allGrids = map.GetAllGridPositions();
		var grids:Array<Vector2Int> = [];
		for (g in allGrids)
		{
			if (g.y == lane && map.CanInsert(g.x, g.y, entityID))
				grids.push(g);
		}
		for (grid in grids)
		{
			InsertAt(map, grid, entityID);
		}
	}
	public function Insert(map:IIZombieMap, x:Int, y:Int, entityID:NamespaceID):Void
	{
		map.InsertEntity(x, y, entityID);
	}
	// PORT-NOTE: C# Insert(map, Vector2Int position, NamespaceID) 重载改名为 InsertAt（Haxe 不支持重载）。
	public function InsertAt(map:IIZombieMap, position:Vector2Int, entityID:NamespaceID):Void
	{
		map.InsertEntity(position.x, position.y, entityID);
	}
	public var Columns(default, null):Int;
	// PORT-NOTE: C# Blueprints { get; protected set; } -> Haxe 无 protected set，改为公开 set。
	public var Blueprints(default, set):Null<Array<NamespaceID>>;
	private function set_Blueprints(value:Null<Array<NamespaceID>>):Null<Array<NamespaceID>>
	{
		return Blueprints = value;
	}
	public override function GetDefinitionType():String
	{
		return LogicDefinitionTypes.I_ZOMBIE_LAYOUT;
	}
}
