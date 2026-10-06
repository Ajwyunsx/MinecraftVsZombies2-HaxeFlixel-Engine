// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/VanillaRandomChinaEventID.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaRandomChinaEventID
{
    public static var obsidianPrison:NamespaceID = Get(VanillaRandomChinaEventNames.obsidianPrison);
    public static var chinaTown:NamespaceID = Get(VanillaRandomChinaEventNames.chinaTown);
    public static var theTower:NamespaceID = Get(VanillaRandomChinaEventNames.theTower);
    public static var redstoneReady:NamespaceID = Get(VanillaRandomChinaEventNames.redstoneReady);
    public static var aceOfDiamonds:NamespaceID = Get(VanillaRandomChinaEventNames.aceOfDiamonds);
    public static var hellMetal:NamespaceID = Get(VanillaRandomChinaEventNames.hellMetal);

    public static var ancientEgypt:NamespaceID = Get(VanillaRandomChinaEventNames.ancientEgypt);
    private static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
