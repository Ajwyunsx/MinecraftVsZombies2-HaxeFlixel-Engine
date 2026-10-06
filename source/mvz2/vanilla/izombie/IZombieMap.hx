// Ported from: Assets/Scripts/Vanilla/Frameworks/IZombie/IZombieMap.cs
package mvz2.vanilla.izombie;

import mvz2logic.entities.LogicEntityProps;
import mvz2logic.izombie.IIZombieMap;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import unity.Vector2Int;

class IZombieMap implements IIZombieMap
{
    public function new(level:LevelEngine, columns:Int, lanes:Int, rounds:Int)
    {
        _level = level;
        _columns = columns;
        _lanes = lanes;
        _rounds = rounds;
    }
    public function Apply():Void
    {
        for (entry in entries)
        {
            entry.Apply(Level);
        }
    }
    public function InsertEntity(column:Int, lane:Int, entity:NamespaceID):Void
    {
        if (column < 0 || column >= Columns)
            return;
        if (lane < 0 || lane >= Lanes)
            return;
        var definition = Level.Content.GetEntityDefinition(entity);
        if (definition == null)
            return;
        // PORT-NOTE: C# 的 definition.GetGridLayersToTake() 扩展方法在移植层更名为 GetGridLayersToTakeOfDefinition。
        var value = new IZombieMapEntry(column, lane, entity, LogicEntityProps.GetGridLayersToTakeOfDefinition(definition));
        entries.push(value);
    }
    public function CanInsert(column:Int, lane:Int, entity:NamespaceID):Bool
    {
        if (column >= Columns)
            return false;
        var definition = Level.Content.GetEntityDefinition(entity);
        if (definition == null)
            return false;
        var layers = LogicEntityProps.GetGridLayersToTakeOfDefinition(definition);
        var entries = GetEntriesAt(column, lane);
        for (entry in entries)
        {
            if (entry.takenLayers != null && Intersect(entry.takenLayers, layers).length > 0)
            {
                return false;
            }
        }
        return true;
    }
    // C#: CanInsert(Vector2Int position, NamespaceID entity)
    // PORT-NOTE: Haxe has no method overloading; renamed overload to CanInsertAt.
    public function CanInsertAt(position:Vector2Int, entity:NamespaceID):Bool
    {
        return CanInsert(position.x, position.y, entity);
    }
    public function GetAllGridPositions():Array<Vector2Int>
    {
        var positions:Array<Vector2Int> = [];
        for (y in 0...Lanes)
        {
            for (x in 0...Columns)
            {
                positions.push(new Vector2Int(x, y));
            }
        }
        return positions;
    }
    public function GetEntriesAt(column:Int, lane:Int):Array<IZombieMapEntry>
    {
        return Lambda.array(Lambda.filter(entries, function(e) return e.column == column && e.lane == lane));
    }
    // C#: GetEntriesAt(Vector2Int position)
    public function GetEntriesAtPosition(position:Vector2Int):Array<IZombieMapEntry>
    {
        return GetEntriesAt(position.x, position.y);
    }
    public function GetEntry(column:Int, lane:Int):IZombieMapEntry
    {
        return Lambda.find(entries, function(e) return e.column == column && e.lane == lane);
    }
    // C#: GetEntry(Vector2Int position)
    public function GetEntryAt(position:Vector2Int):IZombieMapEntry
    {
        return GetEntry(position.x, position.y);
    }
    // PORT-NOTE: C# 的只读自动属性 (get;) → Haxe 属性访问器（IIZombieMap 接口要求 get_ 访问器）。
    public var Level(get, never):LevelEngine;
    public var Columns(get, never):Int;
    public var Lanes(get, never):Int;
    public var Rounds(get, never):Int;
    private var _level:LevelEngine;
    private var _columns:Int;
    private var _lanes:Int;
    private var _rounds:Int;
    private function get_Level():LevelEngine return _level;
    private function get_Columns():Int return _columns;
    private function get_Lanes():Int return _lanes;
    private function get_Rounds():Int return _rounds;
    private var entries:Array<IZombieMapEntry> = [];

    // C# LINQ Intersect(layers).Count() > 0
    private static function Intersect(a:Array<NamespaceID>, b:Array<NamespaceID>):Array<NamespaceID>
    {
        var result:Array<NamespaceID> = [];
        for (x in a)
        {
            for (y in b)
            {
                if (x == y)
                {
                    result.push(x);
                    break;
                }
            }
        }
        return result;
    }
}
