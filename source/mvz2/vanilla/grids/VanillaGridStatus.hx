// Ported from: Assets/Scripts/Vanilla/Frameworks/Grids/VanillaGridStatus.cs
package mvz2.vanilla.grids;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaGridStatus
{
    public static var gridDisabled:NamespaceID = Get("grid_disabled");
    public static var alreadyTaken:NamespaceID = Get("already_taken");
    public static var outOfBounds:NamespaceID = Get("out_of_bounds");
    public static var notOnStatues:NamespaceID = Get("not_on_statues");
    public static var notOnSpawners:NamespaceID = Get("not_on_spawners");
    public static var needLilypad:NamespaceID = Get("need_lilypad");
    public static var notOnWater:NamespaceID = Get("not_on_water");
    public static var notOnPlane:NamespaceID = Get("not_on_plane");
    public static var notOnLand:NamespaceID = Get("not_on_land");
    public static var notOnAir:NamespaceID = Get("not_on_air");
    public static var onlyCanSleep:NamespaceID = Get("only_can_sleep");
    public static var onlyCanMill:NamespaceID = Get("only_can_mill");
    public static var onlyUpgrade:NamespaceID = Get("only_upgrade");
    public static var onlyDrivenser:NamespaceID = Get("only_drivenser");
    public static var firstAid:NamespaceID = Get("first_aid");
    public static var notUnlocked:NamespaceID = Get("not_unlocked");
    public static var rightOfLine:NamespaceID = Get("right_of_line");
    public static var onlyCanCool:NamespaceID = Get("only_can_cool");
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
