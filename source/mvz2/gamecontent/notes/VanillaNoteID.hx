// Ported from: Assets/Scripts/Vanilla/GameContent/Notes/VanillaNoteID.cs
package mvz2.gamecontent.notes;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaNoteNames
{
    public static inline var help:String = "help";
    public static inline var prologue:String = "prologue";
    public static inline var halloween:String = "halloween";
    public static inline var dream:String = "dream";
    public static inline var castle:String = "castle";
    public static inline var mausoleum:String = "mausoleum";
    public static inline var ship:String = "ship";
    public static inline var palace:String = "palace";
}

class VanillaNoteID
{
    public static var help:NamespaceID = Get(VanillaNoteNames.help);
    public static var prologue:NamespaceID = Get(VanillaNoteNames.prologue);
    public static var halloween:NamespaceID = Get(VanillaNoteNames.halloween);
    public static var dream:NamespaceID = Get(VanillaNoteNames.dream);
    public static var castle:NamespaceID = Get(VanillaNoteNames.castle);
    public static var mausoleum:NamespaceID = Get(VanillaNoteNames.mausoleum);
    public static var ship:NamespaceID = Get(VanillaNoteNames.ship);
    public static var palace:NamespaceID = Get(VanillaNoteNames.palace);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
