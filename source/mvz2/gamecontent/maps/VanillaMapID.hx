// Ported from: Assets/Scripts/Vanilla/GameContent/Maps/VanillaMapID.cs
package mvz2.gamecontent.maps;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaMapID
{
    public static var halloween:NamespaceID = Get("halloween");
    public static var dream:NamespaceID = Get("dream");
    public static var gensokyo:NamespaceID = Get("gensokyo");
    public static var castle:NamespaceID = Get("castle");
    public static var mausoleum:NamespaceID = Get("mausoleum");
    public static var ship:NamespaceID = Get("ship");
    public static var palace:NamespaceID = Get("palace");
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
