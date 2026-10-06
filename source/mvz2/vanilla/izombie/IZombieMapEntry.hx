// Ported from: Assets/Scripts/Vanilla/Frameworks/IZombie/IZombieMapEntry.cs
package mvz2.vanilla.izombie;

import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import unity.Vector3;

class IZombieMapEntry
{
    public function new(column:Int, lane:Int, entity:NamespaceID, takenLayers:Null<Array<NamespaceID>>)
    {
        this.column = column;
        this.lane = lane;
        this.entity = entity;
        this.takenLayers = takenLayers;
    }
    public function Apply(level:LevelEngine):Void
    {
        var x = level.GetEntityColumnX(column);
        var z = level.GetEntityLaneZ(lane);
        var y = level.GetGroundY(x, z);
        var pos = new Vector3(x, y, z);
        level.Spawn(entity, pos, null);
    }
    public var column:Int;
    public var lane:Int;
    public var entity:NamespaceID;
    public var takenLayers:Null<Array<NamespaceID>>;
}
