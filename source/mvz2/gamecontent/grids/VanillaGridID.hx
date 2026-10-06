// Ported from: Assets/Scripts/Vanilla/GameContent/Grids/VanillaGridID.cs
package mvz2.gamecontent.grids;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaGridNames
{
    public static inline var grass:String = "grass";
    public static inline var water:String = "water";
    public static inline var wood:String = "wood";
    public static inline var woodSlope:String = "wood_slope";
    public static inline var stone:String = "stone";
    public static inline var air:String = "air";
    public static inline var stoneSlab:String = "stone_slab";
}

class VanillaGridID
{
    public static var grass:NamespaceID = Get(VanillaGridNames.grass);
    public static var water:NamespaceID = Get(VanillaGridNames.water);
    public static var wood:NamespaceID = Get(VanillaGridNames.wood);
    public static var woodSlope:NamespaceID = Get(VanillaGridNames.woodSlope);
    public static var stone:NamespaceID = Get(VanillaGridNames.stone);
    public static var stoneSlab:NamespaceID = Get(VanillaGridNames.stoneSlab);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
