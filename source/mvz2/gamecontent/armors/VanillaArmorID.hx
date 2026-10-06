// Ported from: Assets/Scripts/Vanilla/GameContent/Armors/VanillaArmorID.cs
package mvz2.gamecontent.armors;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaArmorNames
{
    public static inline var leatherCap:String = "leather_cap";
    public static inline var ironHelmet:String = "iron_helmet";
    public static inline var mesmerizerCrown:String = "mesmerizer_crown";
    public static inline var berserkerHelmet:String = "berserker_helmet";
    public static inline var bedserkerHelmet:String = "bedserker_helmet";
    public static inline var reflectiveBarrier:String = "reflective_barrier";
    public static inline var wickedHermitHat:String = "wicked_hermit_hat";
    public static inline var skeletonWarriorHelmet:String = "skeleton_warrior_helmet";
    public static inline var skeletonWarriorShield:String = "skeleton_warrior_shield";
    public static inline var emperorCrown:String = "emperor_crown";
    public static inline var umbrellaShield:String = "umbrella_shield";
    public static inline var cannon:String = "cannon";
}

class VanillaArmorID
{
    public static var leatherCap:NamespaceID = Get(VanillaArmorNames.leatherCap);
    public static var ironHelmet:NamespaceID = Get(VanillaArmorNames.ironHelmet);
    public static var mesmerizerCrown:NamespaceID = Get(VanillaArmorNames.mesmerizerCrown);
    public static var bersekerHelmet:NamespaceID = Get(VanillaArmorNames.berserkerHelmet);
    public static var bedserkerHelmet:NamespaceID = Get(VanillaArmorNames.bedserkerHelmet);
    public static var reflectiveBarrier:NamespaceID = Get(VanillaArmorNames.reflectiveBarrier);
    public static var wickedHermitHat:NamespaceID = Get(VanillaArmorNames.wickedHermitHat);
    public static var skeletonWarriorHelmet:NamespaceID = Get(VanillaArmorNames.skeletonWarriorHelmet);
    public static var skeletonWarriorShield:NamespaceID = Get(VanillaArmorNames.skeletonWarriorShield);
    public static var emperorCrown:NamespaceID = Get(VanillaArmorNames.emperorCrown);
    public static var umbrellaShield:NamespaceID = Get(VanillaArmorNames.umbrellaShield);
    public static var cannon:NamespaceID = Get(VanillaArmorNames.cannon);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
