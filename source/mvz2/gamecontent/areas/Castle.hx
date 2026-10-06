// Ported from: Assets/Scripts/Vanilla/GameContent/Areas/Castle.cs
package mvz2.gamecontent.areas;

import mvz2.gamecontent.areas.VanillaAreaID;
import mvz2.gamecontent.areas.VanillaAreaID.VanillaAreaNames;
import mvz2.gamecontent.enemies.VanillaEnemyID;
import pvzengine.NamespaceID;
import pvzengine.definitions.AreaDefinition;
import pvzengine.level.LevelEngine;
import unity.Mathf;
import unity.Vector3;

@:autoAreaDefinition(VanillaAreaNames.castle)
class Castle extends AreaDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostHugeWaveEvent(level:LevelEngine):Void
    {
        super.PostHugeWaveEvent(level);
        var x = level.GetEnemySpawnX();
        var z = level.GetEntityLaneZ(Std.int(level.GetMaxLaneCount() / 2));
        var y = level.GetGroundY(x, z);
        var pos = new Vector3(x, y, z);
        level.Spawn(VanillaEnemyID.reverseSatellite, pos, null);
    }
    public override function GetGroundY(level:LevelEngine, x:Float, z:Float):Float
    {
        if (x < 660)
        {
            return Mathf.Lerp(80, 0, (x - 260) / 400);
        }
        if (x > 1060)
        {
            return Mathf.Lerp(0, 80, (x - 1060) / 400);
        }
        return super.GetGroundY(level, x, z);
    }
    static var ID:NamespaceID = VanillaAreaID.castle;
}
