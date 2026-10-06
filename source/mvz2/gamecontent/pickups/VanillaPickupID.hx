// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/VanillaPickupID.cs
package mvz2.gamecontent.pickups;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaPickupID
{
    public static var redstone:NamespaceID = Get(VanillaPickupNames.redstone);
    public static var gunpowder:NamespaceID = Get(VanillaPickupNames.gunpowder);
    public static var furiousGunpowder:NamespaceID = Get(VanillaPickupNames.furiousGunpowder);
    public static var emerald:NamespaceID = Get(VanillaPickupNames.emerald);
    public static var ruby:NamespaceID = Get(VanillaPickupNames.ruby);
    public static var sapphire:NamespaceID = Get(VanillaPickupNames.sapphire);
    public static var diamond:NamespaceID = Get(VanillaPickupNames.diamond);
    public static var clearPickup:NamespaceID = Get(VanillaPickupNames.clearPickup);
    public static var starshard:NamespaceID = Get(VanillaPickupNames.starshard);
    public static var artifactPickup:NamespaceID = Get(VanillaPickupNames.artifactPickup);
    public static var blueprintPickup:NamespaceID = Get(VanillaPickupNames.blueprintPickup);
    public static var lockedChestPickup:NamespaceID = Get(VanillaPickupNames.lockedChestPickup);
    private static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
