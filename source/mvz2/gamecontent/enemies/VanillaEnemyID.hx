// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/VanillaEnemyID.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaEnemyID
{
    public static var zombie:NamespaceID = Get(VanillaEnemyNames.zombie);
    public static var flagZombie:NamespaceID = Get(VanillaEnemyNames.flagZombie);
    public static var leatherCappedZombie:NamespaceID = Get(VanillaEnemyNames.leatherCappedZombie);
    public static var ironHelmettedZombie:NamespaceID = Get(VanillaEnemyNames.ironHelmettedZombie);
    public static var diamondHelmettedZombie:NamespaceID = Get(VanillaEnemyNames.diamondHelmettedZombie);

    public static var skeleton:NamespaceID = Get(VanillaEnemyNames.skeleton);
    public static var gargoyle:NamespaceID = Get(VanillaEnemyNames.gargoyle);
    public static var ghost:NamespaceID = Get(VanillaEnemyNames.ghost);
    public static var mummy:NamespaceID = Get(VanillaEnemyNames.mummy);
    public static var necromancer:NamespaceID = Get(VanillaEnemyNames.necromancer);

    public static var spider:NamespaceID = Get(VanillaEnemyNames.spider);
    public static var caveSpider:NamespaceID = Get(VanillaEnemyNames.caveSpider);
    public static var ghast:NamespaceID = Get(VanillaEnemyNames.ghast);
    public static var motherTerror:NamespaceID = Get(VanillaEnemyNames.motherTerror);
    public static var parasiteTerror:NamespaceID = Get(VanillaEnemyNames.parasiteTerror);

    public static var mesmerizer:NamespaceID = Get(VanillaEnemyNames.mesmerizer);
    public static var berserker:NamespaceID = Get(VanillaEnemyNames.berserker);
    public static var dullahan:NamespaceID = Get(VanillaEnemyNames.dullahan);
    public static var hellChariot:NamespaceID = Get(VanillaEnemyNames.hellChariot);
    public static var anubisand:NamespaceID = Get(VanillaEnemyNames.anubisand);

    public static var reflectiveBarrierZombie:NamespaceID = Get(VanillaEnemyNames.reflectiveBarrierZombie);
    public static var talismanZombie:NamespaceID = Get(VanillaEnemyNames.talismanZombie);
    public static var wickedHermitZombie:NamespaceID = Get(VanillaEnemyNames.wickedHermitZombie);
    public static var shikaisenZombie:NamespaceID = Get(VanillaEnemyNames.shikaisenZombie);
    public static var emperorZombie:NamespaceID = Get(VanillaEnemyNames.emperorZombie);

    public static var undeadFlyingObject:NamespaceID = Get(VanillaEnemyNames.undeadFlyingObject);
    public static var ufo:NamespaceID = undeadFlyingObject;
    public static var zombieCloud:NamespaceID = Get(VanillaEnemyNames.zombieCloud);
    public static var cannoneerZombie:NamespaceID = Get(VanillaEnemyNames.cannoneerZombie);
    public static var cannonballZombie:NamespaceID = Get(VanillaEnemyNames.cannonballZombie);
    public static var popCaptain:NamespaceID = Get(VanillaEnemyNames.popCaptain);

    public static var shadowCell:NamespaceID = Get(VanillaEnemyNames.shadowCell);
    public static var skeletonStatue:NamespaceID = Get(VanillaEnemyNames.skeletonStatue);
    public static var hacker:NamespaceID = Get(VanillaEnemyNames.hacker);
    public static var zombieCat:NamespaceID = Get(VanillaEnemyNames.zombieCat);
    public static var wispFly:NamespaceID = Get(VanillaEnemyNames.wispFly);

    public static var mutantZombie:NamespaceID = Get(VanillaEnemyNames.mutantZombie);
    public static var megaMutantZombie:NamespaceID = Get(VanillaEnemyNames.megaMutantZombie);
    public static var imp:NamespaceID = Get(VanillaEnemyNames.imp);

    public static var boneWall:NamespaceID = Get(VanillaEnemyNames.boneWall);
    public static var napstablook:NamespaceID = Get(VanillaEnemyNames.napstablook);
    public static var reverseSatellite:NamespaceID = Get(VanillaEnemyNames.reverseSatellite);
    public static var skeletonHorse:NamespaceID = Get(VanillaEnemyNames.skeletonHorse);
    public static var dullahanHead:NamespaceID = Get(VanillaEnemyNames.dullahanHead);
    public static var soulsand:NamespaceID = Get(VanillaEnemyNames.soulsand);
    public static var seijaCursedDoll:NamespaceID = Get(VanillaEnemyNames.seijaCursedDoll);
    public static var bedserker:NamespaceID = Get(VanillaEnemyNames.bedserker);
    public static var skeletonWarrior:NamespaceID = Get(VanillaEnemyNames.skeletonWarrior);
    public static var skeletonMage:NamespaceID = Get(VanillaEnemyNames.skeletonMage);
    public static var shikaisenStaff:NamespaceID = Get(VanillaEnemyNames.shikaisenStaff);
    public static var netherHunter:NamespaceID = Get(VanillaEnemyNames.netherHunter);
    public static var netherMage:NamespaceID = Get(VanillaEnemyNames.netherMage);
    public static var rollingHayBale:NamespaceID = Get(VanillaEnemyNames.rollingHayBale);
    public static var rollingWood:NamespaceID = Get(VanillaEnemyNames.rollingWood);
    public static var rollingStone:NamespaceID = Get(VanillaEnemyNames.rollingStone);
    public static var lockedChestBalloon:NamespaceID = Get(VanillaEnemyNames.lockedChestBalloon);
    static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}
