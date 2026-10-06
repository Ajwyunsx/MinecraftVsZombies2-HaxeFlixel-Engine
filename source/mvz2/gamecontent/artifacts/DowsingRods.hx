// Ported from: Assets/Scripts/Vanilla/GameContent/Artifacts/Chapter5/DowsingRods.cs
package mvz2.gamecontent.artifacts;

import mvz2.gamecontent.artifacts.VanillaArtifactID.VanillaArtifactNames;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2logic.artifacts.ArtifactDefinition;
import mvz2logic.blueprints.LogicBlueprintID;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.entities.Entity;
import pvzengine.entities.SpawnParams;
import tools.EnumerableExt;
import tools.RandomGenerator;
using mvz2.vanilla.enemies.VanillaEnemyProps;
using mvz2.vanilla.level.VanillaLevelExt;
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2logic.level.LogicLevelExt;

@:autoArtifactDefinition(VanillaArtifactNames.dowsingRods)
class DowsingRods extends ArtifactDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.ENEMY_DROP_REWARDS, EnemyDropRewardsCallback);
    }
    function EnemyDropRewardsCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        if (entity.HasNoReward())
            return;
        var artifacts = entity.Level.GetArtifacts();
        for (artifact in artifacts)
        {
            if (artifact == null || artifact.Definition != this)
                continue;
            var rng = artifact.RNG;
            // TODO-PORT: Tools.RandomGenerator.NextPercent 由 pvzengine/tools 工作包提供，此处按原 API 直译。
            if (!rng.NextPercent(DROP_CHANCE))
                continue;
            DropRewards(entity, rng);
            artifact.Highlight();
        }
    }
    function DropRewards(entity:Entity, rng:RandomGenerator):Void
    {
        var reward = PickReward(rng);
        switch (reward)
        {
            case REWARD_EMERALD:
                entity.Produce(VanillaPickupID.emerald);
            case REWARD_RUBY:
                entity.Produce(VanillaPickupID.ruby);
            case REWARD_DIAMOND:
                entity.Produce(VanillaPickupID.diamond);
            case REWARD_REDSTONE:
                for (_ in 0...3)
                {
                    entity.Produce(VanillaPickupID.redstone);
                }
            case REWARD_BLUEPRINT:
                var spawnParams = new SpawnParams();
                var contraptionID = entity.Level.GetRandomContraptionFromPool(rng);
                var blueprintID = LogicBlueprintID.FromEntity(contraptionID);
                spawnParams.SetProperty(VanillaPickupProps.CONTENT_ID, blueprintID);
                entity.Produce(VanillaPickupID.blueprintPickup, spawnParams);
            default:
        }
    }
    // PORT-NOTE: C# `rewardPool.WeightedRandom(p => p.Value, rng).Key`（Tools 扩展）在移植层无对应重载，
    // 改为按权重数组调用 tools.EnumerableExt.WeightedRandomTake 取出一个键，权重分布等价。
    function PickReward(rng:RandomGenerator):Int
    {
        var keys:Array<Int> = [for (k in rewardPool.keys()) k];
        var weights:Array<Int> = [for (k in keys) Std.int(rewardPool.get(k))];
        var picked = EnumerableExt.WeightedRandomTake(keys, weights, 1, rng);
        return picked.length > 0 ? picked[0] : REWARD_EMERALD;
    }
    public static inline var DROP_CHANCE:Float = 25;
    public static inline var REWARD_EMERALD:Int = 0;
    public static inline var REWARD_RUBY:Int = 1;
    public static inline var REWARD_DIAMOND:Int = 2;
    public static inline var REWARD_REDSTONE:Int = 3;
    public static inline var REWARD_BLUEPRINT:Int = 4;

    public static var rewardPool:Map<Int, Float> = [
        REWARD_EMERALD => 35,
        REWARD_RUBY => 9,
        REWARD_DIAMOND => 1,
        REWARD_REDSTONE => 30,
        REWARD_BLUEPRINT => 25
    ];
}
