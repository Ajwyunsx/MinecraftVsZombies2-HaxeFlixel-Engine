// Ported from: Assets/Scripts/Vanilla/GameContent/Fragments/VanillaFragmentID.cs
package mvz2.gamecontent.fragments;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaFragmentNames
{
    public static inline var furnace:String = "furnace";
    public static inline var obsidianArmor:String = "obsidian_armor";
    public static inline var reflectiveBarrier:String = "reflective_barrier";
    public static inline var hellfireCursed:String = "hellfire_cursed";
    public static inline var divineShield:String = "divine_shield";
    public static inline var cannon:String = "cannon";
    public static inline var skywardBeaconNight:String = "skyward_beacon_night";
    public static inline var gravelpult:String = "gravelpult";
    public static inline var woodenDropper:String = "wooden_dropper";
}

class VanillaFragmentID
{
    public static var furnace:NamespaceID = Get(VanillaFragmentNames.furnace);
    public static var obsidianArmor:NamespaceID = Get(VanillaFragmentNames.obsidianArmor);
    public static var reflectiveBarrier:NamespaceID = Get(VanillaFragmentNames.reflectiveBarrier);
    public static var hellfireCursed:NamespaceID = Get(VanillaFragmentNames.hellfireCursed);
    public static var divineShield:NamespaceID = Get(VanillaFragmentNames.divineShield);
    public static var cannon:NamespaceID = Get(VanillaFragmentNames.cannon);
    public static var skywardBeaconNight:NamespaceID = Get(VanillaFragmentNames.skywardBeaconNight);
    public static var gravelpult:NamespaceID = Get(VanillaFragmentNames.gravelpult);
    public static var woodenDropper:NamespaceID = Get(VanillaFragmentNames.woodenDropper);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
