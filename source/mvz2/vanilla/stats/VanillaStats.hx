// Ported from: Assets/Scripts/Vanilla/Frameworks/Stats/VanillaStats.cs
package mvz2.vanilla.stats;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaStats
{
    public static var CATEGORY_CONTRAPTION_PLACE:NamespaceID = Get("contraption_place");
    public static var CATEGORY_CONTRAPTION_DESTROY:NamespaceID = Get("contraption_destroy");
    public static var CATEGORY_CONTRAPTION_EVOKE:NamespaceID = Get("contraption_evoke");
    public static var CATEGORY_ENEMY_SPAWN:NamespaceID = Get("enemy_spawn");
    public static var CATEGORY_ENEMY_NEUTRALIZE:NamespaceID = Get("enemy_neutralize");
    public static var CATEGORY_ENEMY_GAME_OVER:NamespaceID = Get("enemy_gameover");

    public static var CATEGORY_IZ_CONTRAPTION_DESTROY:NamespaceID = Get("iz_contraption_destroy");
    public static var CATEGORY_IZ_ENEMY_PLACE:NamespaceID = Get("iz_enemy_place");
    public static var CATEGORY_IZ_ENEMY_DEATH:NamespaceID = Get("iz_enemy_death");
    public static var CATEGORY_IZ_OBSERVER_TRIGGER:NamespaceID = Get("iz_observer_trigger");
    public static var CATEGORY_IZ_GAME_OVER:NamespaceID = Get("iz_game_over");
    public static function Get(path:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, path);
    }
}
