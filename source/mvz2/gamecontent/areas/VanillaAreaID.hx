// Ported from: Assets/Scripts/Vanilla/GameContent/Areas/VanillaAreaID.cs
package mvz2.gamecontent.areas;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaAreaNames
{
    public static inline var day:String = "day";
    public static inline var halloween:String = "halloween";
    public static inline var dream:String = "dream";
    public static inline var castle:String = "castle";
    public static inline var mausoleum:String = "mausoleum";
    public static inline var mausoleumMinigame:String = "mausoleum_minigame";
    public static inline var ship:String = "ship";
    public static inline var palace:String = "palace";
}

class VanillaAreaID
{
    public static var day:NamespaceID = Get(VanillaAreaNames.day);
    public static var halloween:NamespaceID = Get(VanillaAreaNames.halloween);
    public static var dream:NamespaceID = Get(VanillaAreaNames.dream);
    public static var castle:NamespaceID = Get(VanillaAreaNames.castle);
    public static var mausoleum:NamespaceID = Get(VanillaAreaNames.mausoleum);
    public static var mausoleumMinigame:NamespaceID = Get(VanillaAreaNames.mausoleumMinigame);
    public static var ship:NamespaceID = Get(VanillaAreaNames.ship);
    public static var palace:NamespaceID = Get(VanillaAreaNames.palace);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
