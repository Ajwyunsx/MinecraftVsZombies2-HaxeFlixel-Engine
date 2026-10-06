// Ported from: Assets/Scripts/Vanilla/GameContent/ProgressBars/VanillaProgressBarID.cs
package mvz2.gamecontent.progressbars;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaProgressBarID
{
    public static var frankenstein:NamespaceID = Get("frankenstein");
    public static var nightmare:NamespaceID = Get("nightmare");
    public static var seija:NamespaceID = Get("seija");
    public static var wither:NamespaceID = Get("wither");
    public static var theGiant:NamespaceID = Get("the_giant");
    public static var redDragon:NamespaceID = Get("red_dragon");
    public static var lockedChest:NamespaceID = Get("locked_chest");
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
