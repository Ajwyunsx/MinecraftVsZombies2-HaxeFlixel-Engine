// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/VanillaBuffID.cs
// PORT-NOTE: C# 的 VanillaBuffID 用嵌套静态类（Level/Grid/Entity/Armor/Contraption/...）组织常量。
// Haxe 不支持嵌套类；而“模块名.子类型.静态字段”这种写法在 import 了模块之后会被解析为
// 对主类型的字段访问（VanillaBuffID 无此字段），无法编译。
// 因此这里把每个子类实现为同模块的顶层类 VanillaBuffID_<组名>，并在 VanillaBuffID 上暴露
// 同名的静态实例字段，使各处已使用的 VanillaBuffID.Contraption.xxx 调用形式保持不变。
// 名称常量类 VanillaBuffNames 被拆到同目录的 VanillaBuffNames.hx（同一包内两个模块不能声明同名子类型，
// 且名称常量按 FrameworksBuffNames 的做法平铺为 <组名>_<成员名>）。
// PORT-NOTE: Get 在 C# 中为 private static，Haxe 中同模块的其它类无法访问 private 成员，故改为 public。
package mvz2.gamecontent.buffs;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.VanillaMod;
import pvzengine.NamespaceID;

class VanillaBuffID
{
    public static var Level:VanillaBuffID_Level = new VanillaBuffID_Level();
    public static var Grid:VanillaBuffID_Grid = new VanillaBuffID_Grid();
    public static var Entity:VanillaBuffID_Entity = new VanillaBuffID_Entity();
    public static var Armor:VanillaBuffID_Armor = new VanillaBuffID_Armor();
    public static var Contraption:VanillaBuffID_Contraption = new VanillaBuffID_Contraption();
    public static var Enemy:VanillaBuffID_Enemy = new VanillaBuffID_Enemy();
    public static var Obstacle:VanillaBuffID_Obstacle = new VanillaBuffID_Obstacle();
    public static var Boss:VanillaBuffID_Boss = new VanillaBuffID_Boss();
    public static var Cart:VanillaBuffID_Cart = new VanillaBuffID_Cart();
    public static var Pickup:VanillaBuffID_Pickup = new VanillaBuffID_Pickup();
    public static var Projectile:VanillaBuffID_Projectile = new VanillaBuffID_Projectile();
    public static var Effect:VanillaBuffID_Effect = new VanillaBuffID_Effect();
    public static var SeedPack:VanillaBuffID_SeedPack = new VanillaBuffID_SeedPack();

    public static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
}

class VanillaBuffID_Level
{
    public function new() {}
    // Difficulty
    public var levelEasy:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_levelEasy);
    public var levelHard:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_levelHard);
    public var iZombieEasy:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_iZombieEasy);
    public var iZombieHard:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_iZombieHard);

    // Debug
    public var debugGodmode:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_debugGodmode);
    public var debugNoRecharge:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_debugNoRecharge);
    public var debugStarshard:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_debugStarshard);
    public var debugEnergy:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_debugEnergy);

    // Tutorial
    public var tutorialPickaxeDisable:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_tutorialPickaxeDisable);
    public var tutorialTriggerDisable:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_tutorialTriggerDisable);

    // Chapter 1
    public var swordParalyzed:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_swordParalyzed);
    public var thunder:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_thunder);
    public var frankensteinStage:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_frankensteinStage);

    // Chapter 2
    public var pagodaBranchLevel:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_pagodaBranchLevel);
    public var taintedSun:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_taintedSun);
    public var nightmareLevel:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_nightmareLevel);
    public var nightmareDecrepify:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_nightmareDecrepify);
    public var nightmareaperDarkness:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_nightmareaperDarkness);
    public var slendermanTransition:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_slendermanTransition);
    public var nightmareaperTransition:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_nightmareaperTransition);
    public var nightmareCleared:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_nightmareCleared);

    // Chapter 3
    public var reverseSatellite:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_reverseSatellite);
    public var littleZombieLevel:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_littleZombieLevel);
    public var battleRespite:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_battleRespite);
    public var witherTransition:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_witherTransition);
    public var witherCleared:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_witherCleared);

    // Chapter 4
    public var delayedSpawnerTrigger:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_delayedSpawnerTrigger);
    public var spiritUniverseNight:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_spiritUniverseNight);
    public var theGiantTransition:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_theGiantTransition);
    public var theGiantCleared:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_theGiantCleared);
    public var greedyVacuum:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_greedyVacuum);

    // Chapter 5
    public var ufoSpawn:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_ufoSpawn);
    public var beaconMeteor:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_beaconMeteor);
    public var sorcerersScrollStarshard:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_sorcerersScrollStarshard);
    public var skywardNight:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_skywardNight);

    // Random China
    public var superRecharge:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_superRecharge);
    public var ancientEgypt:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Level_ancientEgypt);
}

class VanillaBuffID_Grid
{
    public function new() {}
    // Chapter 5
    public var waterStainWet:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Grid_waterStainWet);
    public var goldenGrid:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Grid_goldenGrid);
    public var shipBrokenGrid:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Grid_shipBrokenGrid);
}

class VanillaBuffID_Entity
{
    public function new() {}
    // Core
    public var changeLane:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_changeLane);
    public var temporaryUpdateBeforeGame:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_temporaryUpdateBeforeGame);
    public var destroyConflictGridEntitiesOnLand:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_destroyConflictGridEntitiesOnLand);

    // Chapter 2
    public var inWater:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_inWater);
    public var whiteFlash:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_whiteFlash);
    public var parabot:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_parabot);

    // Chapter 3
    public var charm:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_charm);
    public var withered:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_withered);

    // Chapter 4
    public var divineShield:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_divineShield);
    public var divineShieldCooldown:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_divineShieldCooldown);

    // Chapter 5
    public var aboveCloud:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_aboveCloud);
    public var dragonTooth:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_dragonTooth);

    // Chapter 6
    public var transfenserGlowing:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_transfenserGlowing);
    public var stoneEyeSlowing:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_stoneEyeSlowing);
    public var petrified:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_petrified);
    public var draggedByBalloon:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_draggedByBalloon);
    public var burning:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_burning);

    // Random China
    public var worldwideCelebration:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Entity_worldwideCelebration);
}

class VanillaBuffID_Armor
{
    public function new() {}
    // Difficulty
    public var easyArmor:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Armor_easyArmor);

    // Core
    public var armorDamageColor:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Armor_armorDamageColor);

    // Chapter 2
    public var darkMatterArmorInvisible:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Armor_darkMatterArmorInvisible);

    // Chapter 3
    public var littleZombieArmor:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Armor_littleZombieArmor);
    public var bigTroubleArmor:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Armor_bigTroubleArmor);

    // Chapter 4
    public var iZombieSkeletonWarriorArmor:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Armor_iZombieSkeletonWarriorArmor);
}

class VanillaBuffID_Contraption
{
    public function new() {}
    // Difficulty
    public var easyContraption:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_easyContraption);

    // Prologue
    public var obsidianArmor:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_obsidianArmor);
    public var mineTNTInvincible:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_mineTNTInvincible);

    // Chapter 1
    public var moonlightSensorLaunching:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_moonlightSensorLaunching);
    public var moonlightSensorEvoked:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_moonlightSensorEvoked);
    public var glowstoneEvoke:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_glowstoneEvoke);
    public var tntIgnited:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_tntIgnited);
    public var tntCharged:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_tntCharged);
    public var sacrificed:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_sacrificed);
    public var magichestInvincible:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_magichestInvincible);
    public var frankensteinShocked:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_frankensteinShocked);
    public var dreamKeyShield:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_dreamKeyShield);

    // Chapter 2
    public var nocturnal:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_nocturnal);
    public var carriedByLilyPad:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_carriedByLilyPad);
    public var carryingOther:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_carryingOther);
    public var lilyPadEvocation:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_lilyPadEvocation);
    public var dreamButterflyShield:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_dreamButterflyShield);
    public var darkMatterProduction:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_darkMatterProduction);
    public var vortexHopperSpin:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_vortexHopperSpin);
    public var vortexHopperEvoked:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_vortexHopperEvoked);
    public var dreamCrystalEvocation:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_dreamCrystalEvocation);
    public var dreamSilk:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_dreamSilk);
    public var bottledBlackholeDamage:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_bottledBlackholeDamage);

    // Chapter 3
    public var stoneShieldProtected:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_stoneShieldProtected);
    public var glowstoneProtected:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_glowstoneProtected);
    public var ironCurtain:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_ironCurtain);
    public var miracleMalletReplicaDamage:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_miracleMalletReplicaDamage);
    public var brokenLantern:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_brokenLantern);

    // Chapter 4
    public var eyeOfTheGiant:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_eyeOfTheGiant);
    public var noteBlockLoud:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_noteBlockLoud);
    public var lightningOrbEvoked:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_lightningOrbEvoked);
    public var devourerInvincible:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_devourerInvincible);
    public var hellfireCursed:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_hellfireCursed);
    public var imitated:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_imitated);
    public var noteBlockCharged:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_noteBlockCharged);

    // Chapter 5
    public var fireworkDispenserEvoked:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_fireworkDispenserEvoked);
    public var hfpdUpgraded:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_hfpdUpgraded);
    public var stolenByUFO:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_stolenByUFO);
    public var woodenFanBlow:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_woodenFanBlow);
    public var elasticCloudBounceCooldown:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_elasticCloudBounceCooldown);
    public var elasticCloudEvocation:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_elasticCloudEvocation);
    public var skywardBeaconNight:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_skywardBeaconNight);

    // Chapter 6
    public var psychicShackled:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Contraption_psychicShackled);
}

class VanillaBuffID_Enemy
{
    public function new() {}
    // Difficulty
    public var hardEnemy:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_hardEnemy);

    // Core
    public var randomEnemySpeed:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_randomEnemySpeed);

    // Prologue
    public var gemCarrier:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_gemCarrier);

    // Chapter 1
    public var punchtonAchievement:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_punchtonAchievement);
    public var starshardCarrier:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_starshardCarrier);
    public var redstoneCarrier:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_redstoneCarrier);
    public var ghost:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_ghost);
    public var stun:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_stun);
    public var minigameEnemySpeed:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_minigameEnemySpeed);
    public var napstablookAngry:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_napstablookAngry);
    public var frankensteinTransformer:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_frankensteinTransformer);

    // Chapter 2
    public var boat:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_boat);
    public var spiderClimb:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_spiderClimb);
    public var motherTerrorLaid:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_motherTerrorLaid);
    public var terrorParasitized:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_terrorParasitized);
    public var gravityPadGravity:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_gravityPadGravity);
    public var vortexHopperDrag:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_vortexHopperDrag);
    public var fly:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_fly);
    public var enemyWeakness:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_enemyWeakness);
    public var forcePadDrag:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_forcePadDrag);
    public var nightmareComeTrue:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_nightmareComeTrue);
    public var darkMatterInvisible:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_darkMatterInvisible);

    // Chapter 3
    public var littleZombie:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_littleZombie);
    public var bigTrouble:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_bigTrouble);
    public var soulsandSummoned:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_soulsandSummoned);
    public var seijaMesmerizer:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_seijaMesmerizer);

    // Chapter 4
    public var wickedHermitWarp:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_wickedHermitWarp);
    public var wickedHermitWarpped:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_wickedHermitWarpped);
    public var necrotombstoneRising:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_necrotombstoneRising);
    public var slow:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_slow);
    public var iZombieAttackBooster:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_iZombieAttackBooster);
    public var iZombieImp:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_iZombieImp);
    public var iZombieSkeletonWarrior:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_iZombieSkeletonWarrior);
    public var shikaisenRevive:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_shikaisenRevive);

    // Chapter 5
    public var paratroop:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_paratroop);
    public var summonedByUFO:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_summonedByUFO);
    public var ufoBlueAbsorb:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_ufoBlueAbsorb);
    public var heavyCannon:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_heavyCannon);
    public var waterStainSlide:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_waterStainSlide);
    public var blownByWoodenFan:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_blownByWoodenFan);

    // Chapter 6
    public var gravelOnFace:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_gravelOnFace);
    public var controlRodUnstable:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Enemy_controlRodUnstable);
}

class VanillaBuffID_Obstacle
{
    public function new() {}
}

class VanillaBuffID_Boss
{
    public function new() {}
    public var bossRevenge:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Boss_bossRevenge);

    // Chapter 1
    public var frankensteinSteel:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Boss_frankensteinSteel);
    public var frankensteinTransforming:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Boss_frankensteinTransforming);

    // Chapter 2
    public var nightmareaperFall:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Boss_nightmareaperFall);
    public var nightmareaperEnraged:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Boss_nightmareaperEnraged);

    // Chapter 3
    public var seijaFabric:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Boss_seijaFabric);
    public var seijaGap:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Boss_seijaGap);

    // Chapter 4
    public var theGiantInactive:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Boss_theGiantInactive);
    public var theGiantPacman:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Boss_theGiantPacman);
    public var theGiantPacmanKilled:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Boss_theGiantPacmanKilled);
    public var theGiantSnake:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Boss_theGiantSnake);
    public var theGiantPhase3:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Boss_theGiantPhase3);
}

class VanillaBuffID_Cart
{
    public function new() {}
    // Prologue
    public var cartFadeIn:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Cart_cartFadeIn);
}

class VanillaBuffID_Pickup
{
    public function new() {}
    // Chapter 5
    public var absorbedByUFO:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Pickup_absorbedByUFO);
}

class VanillaBuffID_Projectile
{
    public function new() {}
    // Chapter 1
    public var projectileWait:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Projectile_projectileWait);

    // Chapter 2
    public var projectileKnockback:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Projectile_projectileKnockback);
    public var ghastFireCharge:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Projectile_ghastFireCharge);

    // Chapter 3
    public var invertedMirror:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Projectile_invertedMirror);

    // Chapter 4
    public var hellfireIgnited:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Projectile_hellfireIgnited);

    // Chapter 5
    public var beaconMeteorNoDestroy:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Projectile_beaconMeteorNoDestroy);
}

class VanillaBuffID_Effect
{
    public function new() {}
    // Chapter 2
    public var breakoutBoardUpgrade:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Effect_breakoutBoardUpgrade);

    // Chapter 5
    public var waterStainFrozen:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.Effect_waterStainFrozen);
}

class VanillaBuffID_SeedPack
{
    public function new() {}
    // Difficulty
    public var easyBlueprint:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.SeedPack_easyBlueprint);

    // Stages
    public var tutorialDisable:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.SeedPack_tutorialBlueprintDisable);
    public var upgradeEndlessCost:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.SeedPack_upgradeEndlessCost);

    // Chapter 1
    public var theCreaturesHeartReduceCost:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.SeedPack_theCreaturesHeartReduceCost);

    // Chapter 2
    public var slendermanMindSwap:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.SeedPack_slendermanMindSwap);

    // Chapter 6
    public var controlRodRecharge:NamespaceID = VanillaBuffID.Get(VanillaBuffNames.SeedPack_controlRodRecharge);
}
