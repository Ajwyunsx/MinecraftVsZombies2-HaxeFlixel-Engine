// Ported from: Assets/Scripts/Vanilla/GameContent/Entities/Behaviours/VanillaEntityBehaviourNames.cs
package mvz2.vanilla.entities;

class VanillaEntityBehaviourNames
{
    public static inline var faction:String = "faction";
    public static inline var entityPhysics:String = "entity_physics";

    public static inline var setModelPropertyVariant:String = "set_model_property_variant";
    public static inline var setAnimationVariant:String = "set_animation_variant";

    public static inline var timeoutDeath:String = "timeout_death";
    public static inline var timeoutRemove:String = "timeout_remove";
    public static inline var timeoutRemoveWithoutParent:String = "timeout_remove_without_parent";
    public static inline var removeOnDeath:String = "remove_on_death";

    public static inline var removeWithoutParent:String = "remove_without_parent";
    public static inline var lightFadeout:String = "light_fadeout";
    public static inline var followParent:String = "follow_parent";
    public static inline var modelDamagePercent:String = "model_damage_percent";
    public static inline var fadeoutByTimeout:String = "fadeout_by_timeout";
    public static inline var fadeoutByMaxTimeout:String = "fadeout_by_max_timeout";
    public static inline var destroyOutsideWater:String = "destroy_outside_water";
    public static inline var burnAtDay:String = "burn_at_day";
    public static inline var explodeOnFireDeath:String = "explode_on_fire_death";
    public static inline var ignitable:String = "ignitable";
    public static inline var ignitable_Trigger:String = "ignitable/trigger";
    public static inline var ignitable_Evoke:String = "ignitable/evoke";

    public static inline var instakillByWind:String = "instakill_by_wind";
    public static inline var instakillByFire:String = "instakill_by_fire";
    public static inline var instakillByImpact:String = "instakill_by_impact";

    public static inline var balloon:String = "balloon";
    public static inline var randomChangeVelocity:String = "random_change_velocity";

    // #region Contraptions
    public static inline var contraptionCommon:String = "contraption_common";
    public static inline var contraptionShooterFireworkDispenser:String = "contraption_shooter_firework_dispenser";
    public static inline var contraptionEvokeFireworkDispenser:String = "contraption_evoke_firework_dispenser";

    public static inline var elasticCloud_Projectile:String = "elastic_cloud/projectile";
    public static inline var elasticCloud_Evocation:String = "elastic_cloud/evocation";
    public static inline var skywardBeacon_Trigger:String = "skyward_beacon/trigger";
    public static inline var skywardBeacon_Evoke:String = "skyward_beacon/evoke";
    public static inline var transfenser_Trigger:String = "transfenser/trigger";
    public static inline var gravelpult_Evoke:String = "gravelpult/evoke";
    public static inline var stoneEye_Evoke:String = "stone_eye/evoke";
    public static inline var brickCannon_Trigger:String = "brick_cannon/trigger";
    public static inline var brickCannon_Evoke:String = "brick_cannon/evoke";
    public static inline var amethystPylon_Lit:String = "amethyst_pylon/lit";
    public static inline var amethystPylon_Evoke:String = "amethyst_pylon/evoke";
    public static inline var netherReactorCore_Evoke:String = "nether_reactor_core/evoke";

    // #endregion

    // #region Enemies
    public static inline var enemyCommon:String = "enemy_common";
    public static inline var enemyCommonAnimation:String = "enemy_common_animation";
    public static inline var enemyState:String = "enemy_state";
    public static inline var enemyMelee:String = "enemy_melee";
    public static inline var enemyWalk:String = "enemy_walk";
    public static inline var enemyDeathDisappear:String = "enemy_death_disappear";
    public static inline var enemySelfRevival:String = "enemy_self_revival";

    public static inline var boatedEnemy:String = "boated_enemy";
    public static inline var rickrollDrownAchievement:String = "rickroll_drown_achievement";

    public static inline var humanoidAnimation:String = "humanoid_animation";

    public static inline var skeleton_State:String = "skeleton/state";
    public static inline var napstablook_Animation:String = "napstablook/animation";
    public static inline var napstablook_State:String = "napstablook/state";

    public static inline var spider_Animation:String = "spider/animation";
    public static inline var spider_State:String = "spider/state";
    public static inline var spider_Melee:String = "spider/melee";
    public static inline var ghast_State:String = "ghast/state";
    public static inline var ghast_Move:String = "ghast/move";

    public static inline var dullahan_State:String = "dullahan/state";
    public static inline var damageByGold:String = "damage_by_gold";
    public static inline var reverseSatellite_State:String = "reverse_satellite/state";
    public static inline var skeletonHorse_Animation:String = "skeleton_horse/animation";
    public static inline var skeletonHorse_State:String = "skeleton_horse/state";
    public static inline var skeletonHorse_Melee:String = "skeleton_horse/melee";

    public static inline var skeletonMage_State:String = "skeleton_mage/state";
    public static inline var wickedHermitZombie_State:String = "wicked_hermit_zombie/state";

    public static inline var undeadFlyingObject_State:String = "undead_flying_object/state";
    public static inline var popCaptain_Animation:String = "pop_captain/animation";

    public static inline var skeletonStatue_Animation:String = "skeleton_statue/animation";
    public static inline var skeletonStatue_Death:String = "skeleton_statue/death";
    public static inline var skeletonStatue_State:String = "skeleton_statue/state";
    public static inline var hacker_Animation:String = "hacker/animation";
    public static inline var hacker_State:String = "hacker/state";
    public static inline var zombieCat_Model:String = "zombie_cat/model";
    public static inline var wispFly_SelfDestruct:String = "wisp_fly/self_destruct";
    public static inline var crusherBall:String = "crusher_ball";
    public static inline var rollingGiantBlock:String = "rolling_giant_block";
    // #endregion

    // #region Obstacles
    public static inline var obstacleCommon:String = "obstacle_common";
    public static inline var obstacleDestroyContraption:String = "obstacle_destroy_contraption";
    // #endregion

    // #region Bosses
    public static inline var bossCommon:String = "boss_common";
    public static inline var bossResistance:String = "boss_resistance";
    public static inline var bossResistance_Seija:String = "boss_resistance_seija";
    public static inline var bossResistance_TheGiant:String = "boss_resistance_the_giant";
    // #endregion

    public static inline var cartCommon:String = "cart_common";


    public static inline var armorEntity:String = "armor_entity";
    public static inline var fragmented:String = "fragmented";
    public static inline var takeGrid:String = "take_grid";
    public static inline var lilyPadCarrier:String = "lily_pad_carrier";
    public static inline var hellfireIgnitedArrow:String = "hellfire_ignited_arrow";
    public static inline var energyPickup:String = "energy_pickup";
    public static inline var hellPlanet:String = "hell_planet";


    // #region Pickups
    public static inline var pickupTiming:String = "pickup_timing";
    public static inline var pickupAutoCollect:String = "pickup_auto_collect";
    public static inline var pickupLimitPosition:String = "pickup_limit_position";
    public static inline var pickupCollectArtifact:String = "pickup_collect_artifact";
    public static inline var pickupCollectBlueprint:String = "pickup_collect_blueprint";
    public static inline var pickupCollectClear:String = "pickup_collect_clear";
    public static inline var pickupCollectStarshard:String = "pickup_collect_starshard";
    public static inline var pickupCollectValue:String = "pickup_collect_value";
    public static inline var pickupCollectLockedChest:String = "pickup_collect_locked_chest";
    public static inline var pickupMotion:String = "pickup_motion";
    public static inline var pickupVanish:String = "pickup_vanish";
    public static inline var pickupStopOnLand:String = "pickup_stop_on_land";
    public static inline var pickupWithContent:String = "pickup_with_content";

    public static inline var gem:String = "gem";
    public static inline var gunpowderTwinkle:String = "gunpowder_twinkle";
    public static inline var mergePickup:String = "merge_pickup";
    // #endregion

    // #region Projectiles
    public static inline var projectileCommon:String = "projectile_common";
    public static inline var projectileExplode:String = "projectile_explode";
    public static inline var projectileExplodeMeteor:String = "projectile_explode_meteor";
    public static inline var projectileExplodeFirework:String = "projectile_explode_firework";
    public static inline var projectileExplodeCannonMissile:String = "projectile_explode_cannon_missile";
    public static inline var projectileRotating:String = "projectile_rotating";
    // #endregion

    // #region Effects
    public static inline var effectLaserScaling:String = "effect_laser_scaling";
    public static inline var gas:String = "gas";
    public static inline var gasBlown:String = "gas_blown";
    public static inline var waterStainBlown:String = "water_stain_blown";
    public static inline var stopParticlesWithoutParent:String = "stop_particles_without_parent";
    public static inline var skyBackground:String = "sky_background";
    public static inline var dotCollisionDamage:String = "dot_collision_damage";
    // #endregion
}
