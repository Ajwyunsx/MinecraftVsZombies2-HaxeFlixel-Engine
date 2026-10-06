// Ported from: Assets/Scripts/Vanilla/GameContent/Areas/Palace.cs
package mvz2.gamecontent.areas;

import mvz2.gamecontent.areas.VanillaAreaID.VanillaAreaNames;
import mvz2.gamecontent.buffs.seedpacks.BlueprintLockBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import pvzengine.definitions.AreaDefinition;
import pvzengine.level.LevelEngine;
import pvzengine.seedpacks.SeedPack;
import tools.RandomGenerator;
using tools.EnumerableExt;

@:autoAreaDefinition(VanillaAreaNames.palace)
class Palace extends AreaDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostHugeWaveEvent(level:LevelEngine):Void
    {
        super.PostHugeWaveEvent(level);


        var seedPacks = GetBlueprintsToLock(level);
        var count = Std.int(Lambda.count(seedPacks) / LOCK_DIVISION);
        if (count <= 0)
            return;
        var rng = GetRNG(level);
        if (rng == null)
        {
            rng = level.CreateRNG();
            SetRNG(level, rng);
        }
        LockRandomBlueprints(level, seedPacks, count, rng);
        LogicLevelExt.PlaySound(level, VanillaSoundID.locked);
    }
    public static function GetBlueprintsToLock(level:LevelEngine):Iterable<SeedPack>
    {
        if (LogicLevelExt.IsConveyorMode(level))
        {
            return level.GetAllConveyorSeedPacks();
        }
        else
        {
            return Lambda.filter(level.GetAllSeedPacks(), e -> Std.isOfType(e, SeedPack));
        }
    }
    public static function LockRandomBlueprints(level:LevelEngine, seedPacks:Iterable<SeedPack>, count:Int, rng:RandomGenerator):Void
    {
        if (count <= 0)
            return;
        var validSeedPacks = Lambda.filter(seedPacks, e -> !e.HasBuff(BlueprintLockBuff));
        if (Lambda.count(validSeedPacks) <= 0)
            return;
        // TODO-PORT: Tools 扩展方法 RandomTake(this IEnumerable<T>, int, RandomGenerator)（Engine 子模块源码缺失，需由 pvzengine 工作包提供）。
        var seeds = validSeedPacks.RandomTake(count, rng);
        for (seed in seeds)
        {
            seed.AddBuff(BlueprintLockBuff);
        }
    }
    public static function GetRNG(level:LevelEngine):Null<RandomGenerator> return level.GetProperty(PROP_RNG);
    public static function SetRNG(level:LevelEngine, rng:Null<RandomGenerator>):Void level.SetProperty(PROP_RNG, rng);
    public static inline var LOCK_DIVISION:Int = 3;
    public static var PROP_RNG:VanillaLevelPropertyMeta<RandomGenerator> = new VanillaLevelPropertyMeta<RandomGenerator>("rng");
}
