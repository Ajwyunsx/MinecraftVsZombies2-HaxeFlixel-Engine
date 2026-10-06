// Ported from: Assets/Scripts/Vanilla/GameContent/Audios/VanillaMusicID.cs
package mvz2.vanilla.audios;

import mvz2.vanilla.VanillaMod;
import mvz2logic.audios.LogicMusicID;
import pvzengine.NamespaceID;

class VanillaMusicID
{
    public static var mainmenu:NamespaceID = LogicMusicID.mainmenu;
    public static var choosing:NamespaceID = LogicMusicID.choosing;
    public static var day:NamespaceID = Get("day");
    public static var halloween:NamespaceID = Get("halloween");
    public static var halloweenBoss:NamespaceID = Get("halloween_boss");
    public static var dreamLevel:NamespaceID = Get("dream_level");
    public static var nightmareLevel:NamespaceID = Get("nightmare_level");
    public static var nightmareBoss:NamespaceID = Get("nightmare_boss");
    public static var nightmareBoss2:NamespaceID = Get("nightmare_boss2");
    public static var seija:NamespaceID = Get("seija");
    public static var witherBoss:NamespaceID = Get("wither_boss");
    public static var mausoleumBoss:NamespaceID = Get("mausoleum_boss");
    public static var mausoleumBoss2:NamespaceID = Get("mausoleum_boss_2");
    public static var shipBoss:NamespaceID = Get("ship_boss");
    public static var palaceBoss:NamespaceID = Get("palace_boss");
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
