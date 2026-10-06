// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/VanillaPlacementID.cs
package mvz2.gamecontent.placements;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaPlacementNames
{
    public static inline var any:String = "any";
    public static inline var normal:String = "normal";
    public static inline var buried:String = "buried";
    public static inline var aquatic:String = "aquatic";
    public static inline var pad:String = "pad";
    public static inline var dreamSilk:String = "dream_silk";
    public static inline var devourer:String = "devourer";
    public static inline var suspension:String = "suspension";
    public static inline var upgrade:String = "upgrade";
    public static inline var forcePad:String = "force_pad";
    public static inline var brickCannon:String = "brick_cannon";
    public static inline var drivenser:String = "drivenser";
    public static inline var enemy:String = "enemy";
    public static inline var coolingCell:String = "cooling_cell";
}

class VanillaPlacementID
{
    public static var any:NamespaceID = Get(VanillaPlacementNames.any);
    public static var normal:NamespaceID = Get(VanillaPlacementNames.normal);
    public static var buried:NamespaceID = Get(VanillaPlacementNames.buried);
    public static var aquatic:NamespaceID = Get(VanillaPlacementNames.aquatic);
    public static var pad:NamespaceID = Get(VanillaPlacementNames.pad);
    public static var dreamSilk:NamespaceID = Get(VanillaPlacementNames.dreamSilk);
    public static var devourer:NamespaceID = Get(VanillaPlacementNames.devourer);
    public static var suspension:NamespaceID = Get(VanillaPlacementNames.suspension);
    public static var upgrade:NamespaceID = Get(VanillaPlacementNames.upgrade);
    public static var forcePad:NamespaceID = Get(VanillaPlacementNames.forcePad);
    public static var brickCannon:NamespaceID = Get(VanillaPlacementNames.brickCannon);
    public static var drivenser:NamespaceID = Get(VanillaPlacementNames.drivenser);
    public static var enemy:NamespaceID = Get(VanillaPlacementNames.enemy);
    public static var coolingCell:NamespaceID = Get(VanillaPlacementNames.coolingCell);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
