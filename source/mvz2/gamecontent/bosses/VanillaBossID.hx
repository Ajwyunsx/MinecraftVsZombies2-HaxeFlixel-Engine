// Ported from: Assets/Scripts/Vanilla/GameContent/Bosses/VanillaBossID.cs
package mvz2.gamecontent.bosses;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaBossNames
{
    public static inline var frankenstein:String = "frankenstein";
    public static inline var slenderman:String = "slenderman";
    public static inline var nightmareaper:String = "nightmareaper";
    public static inline var seija:String = "seija";
    public static inline var wither:String = "wither";
    public static inline var theGiant:String = "the_giant";
    public static inline var theGiantSnakeTail:String = "the_giant_snake_tail";
    public static inline var redDragon:String = "red_dragon";
    public static inline var lockedChest:String = "locked_chest";
    public static inline var pinkWither:String = "pink_wither";
}

class VanillaBossID
{
    public static var frankenstein:NamespaceID = Get(VanillaBossNames.frankenstein);
    public static var slenderman:NamespaceID = Get(VanillaBossNames.slenderman);
    public static var nightmareaper:NamespaceID = Get(VanillaBossNames.nightmareaper);
    public static var seija:NamespaceID = Get(VanillaBossNames.seija);
    public static var wither:NamespaceID = Get(VanillaBossNames.wither);
    public static var theGiant:NamespaceID = Get(VanillaBossNames.theGiant);
    public static var theGiantSnakeTail:NamespaceID = Get(VanillaBossNames.theGiantSnakeTail);
    public static var redDragon:NamespaceID = Get(VanillaBossNames.redDragon);
    public static var lockedChest:NamespaceID = Get(VanillaBossNames.lockedChest);
    public static var pinkWither:NamespaceID = Get(VanillaBossNames.pinkWither);
    private static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
