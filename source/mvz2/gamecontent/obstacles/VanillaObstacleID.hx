// Ported from: Assets/Scripts/Vanilla/GameContent/Obstacles/VanillaObstacleID.cs
package mvz2.gamecontent.obstacles;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaObstacleNames
{
    public static inline var gargoyleStatue:String = "gargoyle_statue";
    public static inline var monsterSpawner:String = "monster_spawner";
}

class VanillaObstacleID
{
    public static var gargoyleStatue:NamespaceID = Get(VanillaObstacleNames.gargoyleStatue);
    public static var monsterSpawner:NamespaceID = Get(VanillaObstacleNames.monsterSpawner);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
