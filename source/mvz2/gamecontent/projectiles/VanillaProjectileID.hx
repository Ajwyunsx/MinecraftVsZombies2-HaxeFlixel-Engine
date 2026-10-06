// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/VanillaProjectileID.cs
package mvz2.gamecontent.projectiles;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaProjectileID
{
    public static var arrow:NamespaceID = Get(VanillaProjectileNames.arrow);
    public static var mineTNTSeed:NamespaceID = Get(VanillaProjectileNames.mineTNTSeed);
    public static var snowball:NamespaceID = Get(VanillaProjectileNames.snowball);
    public static var largeSnowball:NamespaceID = Get(VanillaProjectileNames.largeSnowball);
    public static var flyingTNT:NamespaceID = Get(VanillaProjectileNames.flyingTNT);
    public static var soulfireBall:NamespaceID = Get(VanillaProjectileNames.soulfireBall);
    public static var spiceGas:NamespaceID = Get(VanillaProjectileNames.spiceGas);
    public static var knife:NamespaceID = Get(VanillaProjectileNames.knife);
    public static var bullet:NamespaceID = Get(VanillaProjectileNames.bullet);
    public static var missile:NamespaceID = Get(VanillaProjectileNames.missile);

    public static var largeArrow:NamespaceID = Get(VanillaProjectileNames.largeArrow);
    public static var breakoutPearl:NamespaceID = Get(VanillaProjectileNames.breakoutPearl);
    public static var spike:NamespaceID = Get(VanillaProjectileNames.spike);
    public static var spikeBall:NamespaceID = Get(VanillaProjectileNames.spikeBall);
    public static var parabot:NamespaceID = Get(VanillaProjectileNames.parabot);
    public static var fireCharge:NamespaceID = Get(VanillaProjectileNames.fireCharge);
    public static var dart:NamespaceID = Get(VanillaProjectileNames.dart);
    public static var poisonJavelin:NamespaceID = Get(VanillaProjectileNames.poisonJavelin);
    public static var weaknessGas:NamespaceID = Get(VanillaProjectileNames.weaknessGas);

    public static var woodenBall:NamespaceID = Get(VanillaProjectileNames.woodenBall);
    public static var cobble:NamespaceID = Get(VanillaProjectileNames.cobble);
    public static var boulder:NamespaceID = Get(VanillaProjectileNames.boulder);
    public static var goldenBall:NamespaceID = Get(VanillaProjectileNames.goldenBall);
    public static var diamondCaltrop:NamespaceID = Get(VanillaProjectileNames.diamondCaltrop);
    public static var compellingOrb:NamespaceID = Get(VanillaProjectileNames.compellingOrb);
    public static var seijaMagicBomb:NamespaceID = Get(VanillaProjectileNames.seijaMagicBomb);
    public static var seijaBullet:NamespaceID = Get(VanillaProjectileNames.seijaBullet);
    public static var witherSkull:NamespaceID = Get(VanillaProjectileNames.witherSkull);

    public static var crossbowBolt:NamespaceID = Get(VanillaProjectileNames.crossbowBolt);
    public static var reflectionBullet:NamespaceID = Get(VanillaProjectileNames.reflectionBullet);
    public static var note:NamespaceID = Get(VanillaProjectileNames.note);
    public static var fireball:NamespaceID = Get(VanillaProjectileNames.fireball);
    public static var iceBolt:NamespaceID = Get(VanillaProjectileNames.iceBolt);
    public static var chargedBolt:NamespaceID = Get(VanillaProjectileNames.chargedBolt);

    public static var hellPlanetOtherworld:NamespaceID = Get(VanillaProjectileNames.hellPlanetOtherworld);
    public static var hellPlanetEarth:NamespaceID = Get(VanillaProjectileNames.hellPlanetEarth);
    public static var hellPlanetMoon:NamespaceID = Get(VanillaProjectileNames.hellPlanetMoon);
    public static var shuriken:NamespaceID = Get(VanillaProjectileNames.shuriken);
    public static var beaconMeteor:NamespaceID = Get(VanillaProjectileNames.beaconMeteor);
    public static var firework:NamespaceID = Get(VanillaProjectileNames.firework);
    public static var fireworkBig:NamespaceID = Get(VanillaProjectileNames.fireworkBig);
    public static var fallingStar:NamespaceID = Get(VanillaProjectileNames.fallingStar);
    public static var explosiveLargeFireball:NamespaceID = Get(VanillaProjectileNames.explosiveLargeFireball);

    public static var spectralArrow:NamespaceID = Get(VanillaProjectileNames.spectralArrow);
    public static var flint:NamespaceID = Get(VanillaProjectileNames.flint);
    public static var gravel:NamespaceID = Get(VanillaProjectileNames.gravel);
    public static var cannonMissile:NamespaceID = Get(VanillaProjectileNames.cannonMissile);
    public static var lockedChestTrash:NamespaceID = Get(VanillaProjectileNames.lockedChestTrash);
    public static var explosiveSoul:NamespaceID = Get(VanillaProjectileNames.explosiveSoul);
    private static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
