// Ported from: Assets/Scripts/Vanilla/GameContent/Seeds/VanillaBlueprintID.cs
package mvz2.gamecontent.seeds;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaBlueprintNames
{
    public static inline var returnPearl:String = "return_pearl";
    public static inline var lengthenBoard:String = "lengthen_board";
    public static inline var addPearl:String = "add_pearl";
    public static inline var heavyWeaponFlashbang:String = "heavy_weapon_flashbang";
    public static inline var heavyWeaponNuke:String = "heavy_weapon_nuke";
    public static inline var heavyWeaponSpread:String = "heavy_weapon_spread";
    public static inline var heavyWeaponRapid:String = "heavy_weapon_rapid";

    public static inline var skeletonMageFire:String = "skeleton_mage_fire";
    public static inline var skeletonMageFrost:String = "skeleton_mage_frost";
    public static inline var skeletonMageLightning:String = "skeleton_mage_lightning";

    public static inline var undeadFlyingObjectRed:String = "undead_flying_object_red";
    public static inline var undeadFlyingObjectGreen:String = "undead_flying_object_green";
    public static inline var undeadFlyingObjectBlue:String = "undead_flying_object_blue";
    public static inline var undeadFlyingObjectRainbow:String = "undead_flying_object_rainbow";
    public static inline var ufoRed:String = undeadFlyingObjectRed;
    public static inline var ufoGreen:String = undeadFlyingObjectGreen;
    public static inline var ufoBlue:String = undeadFlyingObjectBlue;
    public static inline var ufoRainbow:String = undeadFlyingObjectRainbow;
}

class VanillaBlueprintID
{
    public static var returnPearl:NamespaceID = Get(VanillaBlueprintNames.returnPearl);
    public static var lengthenBoard:NamespaceID = Get(VanillaBlueprintNames.lengthenBoard);
    public static var addPearl:NamespaceID = Get(VanillaBlueprintNames.addPearl);
    public static var heavyWeaponFlashbang:NamespaceID = Get(VanillaBlueprintNames.heavyWeaponFlashbang);
    public static var heavyWeaponNuke:NamespaceID = Get(VanillaBlueprintNames.heavyWeaponNuke);
    public static var heavyWeaponSpread:NamespaceID = Get(VanillaBlueprintNames.heavyWeaponSpread);
    public static var heavyWeaponRapid:NamespaceID = Get(VanillaBlueprintNames.heavyWeaponRapid);

    public static var skeletonMageFire:NamespaceID = Get(VanillaBlueprintNames.skeletonMageFire);
    public static var skeletonMageFrost:NamespaceID = Get(VanillaBlueprintNames.skeletonMageFrost);
    public static var skeletonMageLightning:NamespaceID = Get(VanillaBlueprintNames.skeletonMageLightning);

    public static var undeadFlyingObjectRed:NamespaceID = Get(VanillaBlueprintNames.undeadFlyingObjectRed);
    public static var undeadFlyingObjectGreen:NamespaceID = Get(VanillaBlueprintNames.undeadFlyingObjectGreen);
    public static var undeadFlyingObjectBlue:NamespaceID = Get(VanillaBlueprintNames.undeadFlyingObjectBlue);
    public static var undeadFlyingObjectRainbow:NamespaceID = Get(VanillaBlueprintNames.undeadFlyingObjectRainbow);
    public static var ufoRed:NamespaceID = Get(VanillaBlueprintNames.ufoRed);
    public static var ufoGreen:NamespaceID = Get(VanillaBlueprintNames.ufoGreen);
    public static var ufoBlue:NamespaceID = Get(VanillaBlueprintNames.ufoBlue);
    public static var ufoRainbow:NamespaceID = Get(VanillaBlueprintNames.ufoRainbow);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
