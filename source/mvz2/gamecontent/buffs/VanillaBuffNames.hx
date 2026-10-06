// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/VanillaBuffID.cs
// PORT-NOTE: C# 用嵌套静态类 VanillaBuffNames.Level / .Grid / .Armor / .Contraption ... 组织名称常量。
// Haxe 不支持嵌套类，且同一包内两个模块不能声明同名子类型（VanillaBuffID 已占用 Level/Armor/... 等子类型名），
// 因此名称常量平铺为 "<Group>_<name>" 形式（与 FrameworksBuffNames 的处理保持一致），
// VanillaBuffID 的各子类型会引用这些常量。
package mvz2.gamecontent.buffs;

class VanillaBuffNames
{
    // Level / Difficulty
    public static inline var Level_levelEasy:String = "level_easy";
    public static inline var Level_levelHard:String = "level_hard";
    public static inline var Level_iZombieEasy:String = "i_zombie_easy";
    public static inline var Level_iZombieHard:String = "i_zombie_hard";

    // Level / Debug
    public static inline var Level_debugGodmode:String = "debug_godmode";
    public static inline var Level_debugNoRecharge:String = "debug_no_recharge";
    public static inline var Level_debugStarshard:String = "debug_starshard";
    public static inline var Level_debugEnergy:String = "debug_energy";

    // Level / Tutorial
    public static inline var Level_tutorialPickaxeDisable:String = "tutorial_pickaxe_disable";
    public static inline var Level_tutorialTriggerDisable:String = "tutorial_trigger_disable";

    // Level / Chapter 1
    public static inline var Level_swordParalyzed:String = "sword_paralyzed";
    public static inline var Level_thunder:String = "thunder";
    public static inline var Level_frankensteinStage:String = "frankenstein_stage";

    // Level / Chapter 2
    public static inline var Level_pagodaBranchLevel:String = "pagoda_branch_level";
    public static inline var Level_taintedSun:String = "tainted_sun";
    public static inline var Level_nightmareLevel:String = "nightmare_level";
    public static inline var Level_nightmareDecrepify:String = "nightmare_decrepify";
    public static inline var Level_nightmareaperDarkness:String = "nightmareaper_darkness";
    public static inline var Level_slendermanTransition:String = "slenderman_transition";
    public static inline var Level_nightmareaperTransition:String = "nightmareaper_transition";
    public static inline var Level_nightmareCleared:String = "nightmare_cleared";

    // Level / Chapter 3
    public static inline var Level_reverseSatellite:String = "reverse_satellite";
    public static inline var Level_littleZombieLevel:String = "little_zombie_level";
    public static inline var Level_battleRespite:String = "battle_respite";
    public static inline var Level_witherTransition:String = "wither_transition";
    public static inline var Level_witherCleared:String = "wither_cleared";

    // Level / Chapter 4
    public static inline var Level_delayedSpawnerTrigger:String = "delayed_spawner_trigger";
    public static inline var Level_spiritUniverseNight:String = "spirit_universe_night";
    public static inline var Level_theGiantTransition:String = "the_giant_transition";
    public static inline var Level_theGiantCleared:String = "the_giant_cleared";

    // Level / Chapter 5
    public static inline var Level_ufoSpawn:String = "ufo_spawn";
    public static inline var Level_beaconMeteor:String = "beacon_meteor";
    public static inline var Level_sorcerersScrollStarshard:String = "sorcerers_scroll_starshard";
    public static inline var Level_skywardNight:String = "skyward_night";
    public static inline var Level_redDragonStage:String = "red_dragon_stage";
    public static inline var Level_redDragonTransition:String = "red_dragon_transition";
    public static inline var Level_redDragonCleared:String = "red_dragon_cleared";

    // Level / Chapter 6
    public static inline var Level_lockedChestStage:String = "locked_chest_stage";
    public static inline var Level_levelEnemiesCleared:String = "level_enemies_cleared";

    // Level / Random China
    public static inline var Level_greedyVacuum:String = "greedy_vacuum";
    public static inline var Level_superRecharge:String = "super_recharge";
    public static inline var Level_ancientEgypt:String = "ancient_egypt";

    // Grid / Chapter 5
    public static inline var Grid_waterStainWet:String = "water_stain_wet";
    public static inline var Grid_goldenGrid:String = "golden_grid";
    public static inline var Grid_shipBrokenGrid:String = "ship_broken_grid";

    // Grid / Chapter 6
    public static inline var Grid_brokenTile:String = "broken_tile";

    // Entity / Core
    public static inline var Entity_changeLane:String = "change_lane";
    public static inline var Entity_changeGrid:String = "change_grid";
    public static inline var Entity_temporaryUpdateBeforeGame:String = "temporary_update_before_game";
    public static inline var Entity_destroyConflictGridEntitiesOnLand:String = "destroy_conflict_grid_entities_on_land";

    // Entity / Chapter 1
    public static inline var Entity_lightFadeout:String = "light_fadeout";

    // Entity / Chapter 2
    public static inline var Entity_inWater:String = "in_water";
    public static inline var Entity_whiteFlash:String = "white_flash";
    public static inline var Entity_parabot:String = "parabot";

    // Entity / Chapter 3
    public static inline var Entity_charm:String = "charm";
    public static inline var Entity_withered:String = "withered";

    // Entity / Chapter 4
    public static inline var Entity_divineShield:String = "divine_shield";
    public static inline var Entity_divineShieldCooldown:String = "divine_shield_cooldown";

    // Entity / Chapter 5
    public static inline var Entity_aboveCloud:String = "above_cloud";
    public static inline var Entity_dragonTooth:String = "dragon_tooth";
    public static inline var Entity_clearGridOnLand:String = "clear_grid_on_land";

    // Entity / Chapter 6
    public static inline var Entity_transfenserGlowing:String = "transfenser_glowing";
    public static inline var Entity_cursedCandle:String = "cursed_candle";
    public static inline var Entity_stoneEyeSlowing:String = "stone_eye_slowing";
    public static inline var Entity_petrified:String = "petrified";
    public static inline var Entity_draggedByBalloon:String = "dragged_by_balloon";
    public static inline var Entity_releasedfromLockedChest:String = "released_from_locked_chest";
    public static inline var Entity_burning:String = "burning";

    // Entity / Random China
    public static inline var Entity_worldwideCelebration:String = "worldwide_celebration";

    // Armor / Difficulty
    public static inline var Armor_easyArmor:String = "easy_armor";

    // Armor / Core
    public static inline var Armor_armorDamageColor:String = "armor_damage_color";

    // Armor / Chapter 2
    public static inline var Armor_darkMatterArmorInvisible:String = "dark_matter_armor_invisible";

    // Armor / Chapter 3
    public static inline var Armor_littleZombieArmor:String = "little_zombie_armor";
    public static inline var Armor_bigTroubleArmor:String = "big_trouble_armor";

    // Armor / Chapter 4
    public static inline var Armor_iZombieSkeletonWarriorArmor:String = "i_zombie_skeleton_warrior_armor";

    // Contraption / Difficulty
    public static inline var Contraption_easyContraption:String = "easy_contraption";

    // Contraption / Prologue
    public static inline var Contraption_obsidianArmor:String = "obsidian_armor";
    public static inline var Contraption_mineTNTInvincible:String = "mine_tnt_invincible";

    // Contraption / Chapter 1
    public static inline var Contraption_moonlightSensorLaunching:String = "moonlight_sensor_launching";
    public static inline var Contraption_moonlightSensorEvoked:String = "moonlight_sensor_evoked";
    public static inline var Contraption_glowstoneEvoke:String = "glowstone_evoke";
    public static inline var Contraption_tntIgnited:String = "tnt_ignited";
    public static inline var Contraption_tntCharged:String = "tnt_charged";
    public static inline var Contraption_sacrificed:String = "sacrificed";
    public static inline var Contraption_magichestInvincible:String = "magichest_invincible";
    public static inline var Contraption_frankensteinShocked:String = "frankenstein_shocked";
    public static inline var Contraption_dreamKeyShield:String = "dream_key_shield";

    // Contraption / Chapter 2
    public static inline var Contraption_nocturnal:String = "nocturnal";
    public static inline var Contraption_carriedByLilyPad:String = "carried_by_lily_pad";
    public static inline var Contraption_carryingOther:String = "carrying_other";
    public static inline var Contraption_lilyPadEvocation:String = "lily_pad_evocation";
    public static inline var Contraption_dreamButterflyShield:String = "dream_butterfly_shield";
    public static inline var Contraption_darkMatterProduction:String = "dark_matter_production";
    public static inline var Contraption_vortexHopperSpin:String = "vortex_hopper_spin";
    public static inline var Contraption_vortexHopperEvoked:String = "vortex_hopper_evoked";
    public static inline var Contraption_dreamCrystalEvocation:String = "dream_crystal_evocation";
    public static inline var Contraption_dreamSilk:String = "dream_silk";
    public static inline var Contraption_bottledBlackholeDamage:String = "bottled_blackhole_damage";

    // Contraption / Chapter 3
    public static inline var Contraption_stoneShieldProtected:String = "stone_shield_protected";
    public static inline var Contraption_glowstoneProtected:String = "glowstone_protected";
    public static inline var Contraption_ironCurtain:String = "iron_curtain";
    public static inline var Contraption_miracleMalletReplicaDamage:String = "miracle_mallet_replica_damage";
    public static inline var Contraption_brokenLantern:String = "broken_lantern";

    // Contraption / Chapter 4
    public static inline var Contraption_eyeOfTheGiant:String = "eye_of_the_giant";
    public static inline var Contraption_noteBlockLoud:String = "note_block_loud";
    public static inline var Contraption_lightningOrbEvoked:String = "lightning_orb_evoked";
    public static inline var Contraption_devourerInvincible:String = "devourer_invincible";
    public static inline var Contraption_hellfireCursed:String = "hellfire_cursed";
    public static inline var Contraption_imitated:String = "imitated";
    public static inline var Contraption_noteBlockCharged:String = "note_block_charged";

    // Contraption / Chapter 5
    public static inline var Contraption_fireworkDispenserEvoked:String = "firework_dispenser_evoked";
    public static inline var Contraption_hfpdUpgraded:String = "hfpd_upgraded";
    public static inline var Contraption_stolenByUFO:String = "stolen_by_ufo";
    public static inline var Contraption_woodenFanBlow:String = "wooden_fan_blow";
    public static inline var Contraption_elasticCloudBounceCooldown:String = "elastic_cloud_bounce_cooldown";
    public static inline var Contraption_elasticCloudEvocation:String = "elastic_cloud_evocation";
    public static inline var Contraption_skywardBeaconNight:String = "skyward_beacon_night";

    // Contraption / Chapter 6
    public static inline var Contraption_psychicShackled:String = "psychic_shackled";
    public static inline var Contraption_stoneEyeCharged:String = "stone_eye_charged";

    // Enemy / Difficulty
    public static inline var Enemy_hardEnemy:String = "hard_enemy";

    // Enemy / Core
    public static inline var Enemy_randomEnemySpeed:String = "random_enemy_speed";

    // Enemy / Prologue
    public static inline var Enemy_gemCarrier:String = "gem_carrier";

    // Enemy / Chapter 1
    public static inline var Enemy_punchtonAchievement:String = "punchton_achievement";
    public static inline var Enemy_starshardCarrier:String = "starshard_carrier";
    public static inline var Enemy_redstoneCarrier:String = "redstone_carrier";
    public static inline var Enemy_ghost:String = "ghost";
    public static inline var Enemy_stun:String = "stun";
    public static inline var Enemy_minigameEnemySpeed:String = "minigame_enemy_speed";
    public static inline var Enemy_napstablookAngry:String = "napstablook_angry";
    public static inline var Enemy_frankensteinTransformer:String = "frankenstein_transformer";

    // Enemy / Chapter 2
    public static inline var Enemy_boat:String = "boat";
    public static inline var Enemy_spiderClimb:String = "spider_climb";
    public static inline var Enemy_motherTerrorLaid:String = "mother_terror_laid";
    public static inline var Enemy_terrorParasitized:String = "terror_parasitized";
    public static inline var Enemy_gravityPadGravity:String = "gravity_pad_gravity";
    public static inline var Enemy_vortexHopperDrag:String = "vortex_hopper_drag";
    public static inline var Enemy_fly:String = "fly";
    public static inline var Enemy_enemyWeakness:String = "enemy_weakness";
    public static inline var Enemy_forcePadDrag:String = "force_pad_drag";
    public static inline var Enemy_nightmareComeTrue:String = "nightmare_come_true";
    public static inline var Enemy_darkMatterInvisible:String = "dark_matter_invisible";

    // Enemy / Chapter 3
    public static inline var Enemy_littleZombie:String = "little_zombie";
    public static inline var Enemy_bigTrouble:String = "big_trouble";
    public static inline var Enemy_soulsandSummoned:String = "soulsand_summoned";
    public static inline var Enemy_seijaMesmerizer:String = "seija_mesmerizer";

    // Enemy / Chapter 4
    public static inline var Enemy_wickedHermitWarp:String = "wicked_hermit_warp";
    public static inline var Enemy_wickedHermitWarpped:String = "wicked_hermit_warpped";
    public static inline var Enemy_necrotombstoneRising:String = "necrotombstone_rising";
    public static inline var Enemy_slow:String = "slow";
    public static inline var Enemy_iZombieAttackBooster:String = "i_zombie_attack_booster";
    public static inline var Enemy_iZombieImp:String = "i_zombie_imp";
    public static inline var Enemy_iZombieSkeletonWarrior:String = "i_zombie_skeleton_warrior";
    public static inline var Enemy_shikaisenRevive:String = "shikaisen_revive";

    // Enemy / Chapter 5
    public static inline var Enemy_paratroop:String = "paratroop";
    public static inline var Enemy_summonedByUFO:String = "summoned_by_ufo";
    public static inline var Enemy_ufoBlueAbsorb:String = "ufo_blue_absorb";
    public static inline var Enemy_heavyCannon:String = "heavy_cannon";
    public static inline var Enemy_waterStainSlide:String = "water_stain_slide";
    public static inline var Enemy_blownByWoodenFan:String = "blown_by_wooden_fan";

    // Enemy / Chapter 6
    public static inline var Enemy_gravelOnFace:String = "gravel_on_face";
    public static inline var Enemy_smallShadowCell:String = "small_shadow_cell";
    public static inline var Enemy_controlRodUnstable:String = "control_rod_unstable";

    // Boss
    public static inline var Boss_bossRevenge:String = "boss_revenge";

    // Boss / Chapter 1
    public static inline var Boss_frankensteinSteel:String = "frankenstein_steel";
    public static inline var Boss_frankensteinTransforming:String = "frankenstein_transforming";

    // Boss / Chapter 2
    public static inline var Boss_nightmareaperFall:String = "nightmareaper_fall";
    public static inline var Boss_nightmareaperEnraged:String = "nightmareaper_enraged";

    // Boss / Chapter 3
    public static inline var Boss_seijaFabric:String = "seija_fabric";
    public static inline var Boss_seijaGap:String = "seija_gap";

    // Boss / Chapter 4
    public static inline var Boss_theGiantInactive:String = "the_giant_inactive";
    public static inline var Boss_theGiantPacman:String = "the_giant_pacman";
    public static inline var Boss_theGiantPacmanKilled:String = "the_giant_pacman_killed";
    public static inline var Boss_theGiantSnake:String = "the_giant_snake";
    public static inline var Boss_theGiantPhase3:String = "the_giant_phase3";

    // Boss / Chapter 6
    public static inline var Boss_lockedChestInvincible:String = "locked_chest_invincible";

    // Cart / Prologue
    public static inline var Cart_cartFadeIn:String = "cart_fade_in";

    // Pickup / Chapter 5
    public static inline var Pickup_absorbedByUFO:String = "absorbed_by_ufo";

    // Projectile / Chapter 1
    public static inline var Projectile_projectileWait:String = "projectile_wait";

    // Projectile / Chapter 2
    public static inline var Projectile_projectileKnockback:String = "projectile_knockback";
    public static inline var Projectile_ghastFireCharge:String = "ghast_fire_charge";

    // Projectile / Chapter 3
    public static inline var Projectile_invertedMirror:String = "inverted_mirror";

    // Projectile / Chapter 4
    public static inline var Projectile_hellfireIgnited:String = "hellfire_ignited";

    // Projectile / Chapter 5
    public static inline var Projectile_beaconMeteorNoDestroy:String = "beacon_meteor_no_destroy";

    // Effect / Chapter 2
    public static inline var Effect_breakoutBoardUpgrade:String = "breakout_board_upgrade";

    // Effect / Chapter 5
    public static inline var Effect_waterStainFrozen:String = "water_stain_frozen";

    // SeedPack / Difficulty
    public static inline var SeedPack_easyBlueprint:String = "easy_blueprint";

    // SeedPack / Stages
    public static inline var SeedPack_tutorialBlueprintDisable:String = "tutorial_blueprint_disable";
    public static inline var SeedPack_upgradeEndlessCost:String = "upgrade_endless_cost";

    // SeedPack / Chapter 1
    public static inline var SeedPack_theCreaturesHeartReduceCost:String = "the_creatures_heart_reduce_cost";

    // SeedPack / Chapter 2
    public static inline var SeedPack_slendermanMindSwap:String = "slenderman_mind_swap";

    // SeedPack / Chapter 6
    public static inline var SeedPack_blueprintLock:String = "blueprint_lock";
    public static inline var SeedPack_controlRodRecharge:String = "control_rod_recharge";
}
