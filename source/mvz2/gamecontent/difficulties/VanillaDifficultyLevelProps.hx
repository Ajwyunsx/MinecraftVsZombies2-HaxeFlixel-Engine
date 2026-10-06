// Ported from: Assets/Scripts/Vanilla/GameContent/Difficulties/VanillaDifficultyLevelProps.cs
package mvz2.gamecontent.difficulties;

import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.properties.VanillaDifficultyPropertyMeta;
import mvz2logic.blueprints.LogicBlueprintID;
import pvzengine.NamespaceID;
import pvzengine.PropertyRegions;
import pvzengine.level.LevelEngine;

@:propertyRegistryRegion(PropertyRegions.level)
class VanillaDifficultyLevelProps
{
    public static function Get<T>(name:String, ?defaultValue:T):VanillaDifficultyPropertyMeta<T>
    {
        return new VanillaDifficultyPropertyMeta<T>(name, defaultValue);
    }
    // Contraptions
    public static var GUNPOWDER_DAMAGE_MULTIPLIER:VanillaDifficultyPropertyMeta<Float> = Get("gunpowderDamageMultiplier", 1.0);
    public static function GetGunpowderDamageMultiplier(level:LevelEngine):Float return level.GetProperty(GUNPOWDER_DAMAGE_MULTIPLIER);
    public static var ELASTIC_CLOUD_BOUNCE_DAMAGE_MULTIPLIER:VanillaDifficultyPropertyMeta<Float> = Get("elastic_cloud_bounce_damage", 1.0);
    public static function GetElasticCloudBounceDamageMultiplier(level:LevelEngine):Float return level.GetProperty(ELASTIC_CLOUD_BOUNCE_DAMAGE_MULTIPLIER);

    // Enemies
    public static var NAPSTABLOOK_PARALYSIS_TIME:VanillaDifficultyPropertyMeta<Int> = Get("napstablookParalysisTime", 45);
    public static var GHAST_DAMAGE_MULTIPLIER:VanillaDifficultyPropertyMeta<Float> = Get("ghastDamageMultiplier", 1.0);
    public static var MOTHER_TERROR_EGG_COUNT:VanillaDifficultyPropertyMeta<Int> = Get("motherTerrorEggCount", 1);
    public static var PARASITIZED_TERROR_COUNT:VanillaDifficultyPropertyMeta<Int> = Get("parasitizedTerrorCount", 3);
    public static var REVERSE_SATELLITE_DAMAGE_MULTIPLIER:VanillaDifficultyPropertyMeta<Float> = Get("reverseSatelliteDamageMultiplier", 1.0);
    public static var SKELETON_HORSE_JUMP_TIMES:VanillaDifficultyPropertyMeta<Int> = Get("skeletonHorseJumpTimes", 1);
    public static var WICKED_HERMIT_ZOMBIE_STUN_TIME:VanillaDifficultyPropertyMeta<Int> = Get("wickedHermitZombieStunTime", 150);
    public static var WISP_FLY_DAMAGE_MULTIPLIER:VanillaDifficultyPropertyMeta<Float> = Get("wisp_fly_damage_multiplier", 1.5);
    public static function GetNapstablookParalysisTime(level:LevelEngine):Int return level.GetProperty(NAPSTABLOOK_PARALYSIS_TIME);
    public static function GetGhastDamageMultiplier(level:LevelEngine):Float return level.GetProperty(GHAST_DAMAGE_MULTIPLIER);
    public static function GetMotherTerrorEggCount(level:LevelEngine):Int return level.GetProperty(MOTHER_TERROR_EGG_COUNT);
    public static function GetParasitizedTerrorCount(level:LevelEngine):Int return level.GetProperty(PARASITIZED_TERROR_COUNT);
    public static function GetReverseSatelliteDamageMultiplier(level:LevelEngine):Float return level.GetProperty(REVERSE_SATELLITE_DAMAGE_MULTIPLIER);
    public static function GetSkeletonHorseJumpTimes(level:LevelEngine):Int return level.GetProperty(SKELETON_HORSE_JUMP_TIMES);
    public static function GetWickedHermitZombieStunTime(level:LevelEngine):Int return level.GetProperty(WICKED_HERMIT_ZOMBIE_STUN_TIME);
    public static function GetWispFlyDamageMultiplier(level:LevelEngine):Float return level.GetProperty(WISP_FLY_DAMAGE_MULTIPLIER);

    // Bosses
    public static var FRANKENSTEIN_INSTANT_STEEL:VanillaDifficultyPropertyMeta<Bool> = Get("frankensteinInstantSteel");
    public static var FRANKENSTEIN_NO_STEEL:VanillaDifficultyPropertyMeta<Bool> = Get("frankensteinNoSteel");
    public static var FRANKENSTEIN_SPEED:VanillaDifficultyPropertyMeta<Float> = Get("frankensteinSpeed", 1.0);
    public static var SLENDERMAN_MIND_SWAP_ZOMBIES:VanillaDifficultyPropertyMeta<Bool> = Get("slendermanMindSwapZombies");
    public static var SLENDERMAN_FATE_CHOICE_COUNT:VanillaDifficultyPropertyMeta<Int> = Get("slendermanFateChoiceCount", 3);
    public static var SLENDERMAN_MAX_FATE_TIMES:VanillaDifficultyPropertyMeta<Int> = Get("slendermanMaxFateTimes", 4);
    public static var CRUSHING_WALLS_SPEED:VanillaDifficultyPropertyMeta<Float> = Get("crushingWallsSpeed", 4.0);
    public static var NIGHTMAREAPER_SPIN_DAMAGE:VanillaDifficultyPropertyMeta<Float> = Get("nightmareaperSpinDamage", 15.0);
    public static var NIGHTMAREAPER_TIMEOUT:VanillaDifficultyPropertyMeta<Int> = Get("nightmareaperTimeout", 2700);
    public static var WITHER_REGENERATION:VanillaDifficultyPropertyMeta<Float> = Get("witherRegeneration", 0.5);
    public static var WITHER_SKULL_WITHERS_TARGET:VanillaDifficultyPropertyMeta<Bool> = Get("witherSkullWithersTarget");
    public static var THE_GIANT_IS_MALLEABLE:VanillaDifficultyPropertyMeta<Bool> = Get("theGiantIsMalleable");
    public static var RED_DRAGON_FIRE_EXPLOSION_RADIUS:VanillaDifficultyPropertyMeta<Float> = Get("red_dragon_fire_explosion_radius", 32.0);
    public static var RED_DRAGON_GIANT_FIREBALL_SPEED:VanillaDifficultyPropertyMeta<Float> = Get("red_dragon_giant_fireball_speed", 1.0);
    public static var RED_DRAGON_TORNADO_COUNT:VanillaDifficultyPropertyMeta<Int> = Get("red_dragon_tornado_count", 1);
    public static var LOCKED_CHEST_SPIT_BLUEPRINT_ID:VanillaDifficultyPropertyMeta<NamespaceID> = Get("locked_chest_spit_blueprint_id", LogicBlueprintID.FromEntity(VanillaEnemyID.leatherCappedZombie));
    public static var LOCKED_CHEST_REQUIRED_STARSHARDS:VanillaDifficultyPropertyMeta<Int> = Get("locked_chest_required_starshards", 1);

    public static function FrankensteinNoSteelPhase(level:LevelEngine):Bool return level.GetProperty(FRANKENSTEIN_NO_STEEL);
    public static function FrankensteinInstantSteelPhase(level:LevelEngine):Bool return level.GetProperty(FRANKENSTEIN_INSTANT_STEEL);
    public static function GetFrankensteinSpeed(level:LevelEngine):Float return level.GetProperty(FRANKENSTEIN_SPEED);
    public static function SlendermanMindSwapZombies(level:LevelEngine):Bool return level.GetProperty(SLENDERMAN_MIND_SWAP_ZOMBIES);
    public static function GetSlendermanFateChoiceCount(level:LevelEngine):Int return level.GetProperty(SLENDERMAN_FATE_CHOICE_COUNT);
    public static function GetSlendermanMaxFateTimes(level:LevelEngine):Int return level.GetProperty(SLENDERMAN_MAX_FATE_TIMES);
    public static function GetCrushingWallsSpeed(level:LevelEngine):Float return level.GetProperty(CRUSHING_WALLS_SPEED);
    public static function GetNightmareaperSpinDamage(level:LevelEngine):Float return level.GetProperty(NIGHTMAREAPER_SPIN_DAMAGE);
    public static function GetNightmareaperTimeout(level:LevelEngine):Int return level.GetProperty(NIGHTMAREAPER_TIMEOUT);
    public static function GetWitherRegeneration(level:LevelEngine):Float return level.GetProperty(WITHER_REGENERATION);
    public static function WitherSkullWithersTarget(level:LevelEngine):Bool return level.GetProperty(WITHER_SKULL_WITHERS_TARGET);
    public static function TheGiantIsMalleable(level:LevelEngine):Bool return level.GetProperty(THE_GIANT_IS_MALLEABLE);
    public static function GetRedDragonFireExplosionRadius(level:LevelEngine):Float return level.GetProperty(RED_DRAGON_FIRE_EXPLOSION_RADIUS);
    public static function GetRedDragonGiantFireballSpeed(level:LevelEngine):Float return level.GetProperty(RED_DRAGON_GIANT_FIREBALL_SPEED);
    public static function GetRedDragonTornadoCount(level:LevelEngine):Int return level.GetProperty(RED_DRAGON_TORNADO_COUNT);
    public static function GetLockedChestSpitBlueprintID(level:LevelEngine):Null<NamespaceID> return level.GetProperty(LOCKED_CHEST_SPIT_BLUEPRINT_ID);
    public static function GetLockedChestRequiredStarshards(level:LevelEngine):Int return level.GetProperty(LOCKED_CHEST_REQUIRED_STARSHARDS);

    // Level
    public static var STARSHARD_CARRIER_COUNTER_INCREAMENT:VanillaDifficultyPropertyMeta<Float> = Get("starshardCarrierCounterIncreament", 1.0);
    public static var REDSTONE_CARRIER_COUNTER_INCREAMENT:VanillaDifficultyPropertyMeta<Float> = Get("redstoneCarrierCounterIncreament", 10.0);
    public static var IZ_FURNACE_REDSTONE_COUNT:VanillaDifficultyPropertyMeta<Int> = Get("izFurnaceRedstoneCount", 8);
    public static function GetStarshardCarrierCounterIncreament(level:LevelEngine):Float return level.GetProperty(STARSHARD_CARRIER_COUNTER_INCREAMENT);
    public static function GetRedstoneCarrierCounterIncreament(level:LevelEngine):Float return level.GetProperty(REDSTONE_CARRIER_COUNTER_INCREAMENT);
    public static function GetIZFurnaceRedstoneCount(level:LevelEngine):Int return level.GetProperty(IZ_FURNACE_REDSTONE_COUNT);
}
