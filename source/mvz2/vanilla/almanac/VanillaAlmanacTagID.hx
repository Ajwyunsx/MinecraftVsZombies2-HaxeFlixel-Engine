// Ported from: Assets/Scripts/Vanilla/Frameworks/Almanac/VanillaAlmanacTagID.cs
package mvz2.vanilla.almanac;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaAlmanacTagID
{
    public static var placementBuried:NamespaceID = Get("placement_buried");
    public static var placementLand:NamespaceID = Get("placement_land");
    public static var placementAquatic:NamespaceID = Get("placement_aquatic");
    public static var placementSuspension:NamespaceID = Get("placement_suspension");

    public static var lightSource:NamespaceID = Get("light_source");
    public static var nocturnal:NamespaceID = Get("nocturnal");
    public static var defensive:NamespaceID = Get("defensive");
    public static var floorContraption:NamespaceID = Get("floor_contraption");
    public static var shortEnemy:NamespaceID = Get("short_enemy");
    public static var tall:NamespaceID = Get("tall");
    public static var flying:NamespaceID = Get("flying");
    public static var canTrigger:NamespaceID = Get("can_trigger");
    public static var fire:NamespaceID = Get("fire");
    public static var loyal:NamespaceID = Get("loyal");
    public static var drownproof:NamespaceID = Get("drownproof");
    public static var controlImmunity:NamespaceID = Get("control_immunity");
    public static var notUndead:NamespaceID = Get("not_undead");

    public static var shell:NamespaceID = Get("shell");
    public static var shellShield:NamespaceID = Get("shell_shield");
    public static var shellArmor:NamespaceID = Get("shell_armor");
    public static var mass:NamespaceID = Get("mass");

    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
