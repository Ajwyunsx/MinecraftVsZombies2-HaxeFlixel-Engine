// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Behaviours/StarshardStageBehaviour.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.buffs.enemies.StarshardCarrierBuff;
import mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import mvz2logic.Global;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.saves.LogicSaveExt;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;
import pvzengine.level.StageBehaviour;
import pvzengine.level.StageDefinition;

class StarshardStageBehaviour extends StageBehaviour
{
    public function new(stageDef:StageDefinition)
    {
        super(stageDef);
    }
    override public function PostWave(level:LevelEngine, wave:Int):Void
    {
        super.PostWave(level, wave);
        var increament = VanillaDifficultyLevelProps.GetStarshardCarrierCounterIncreament(level);
        var counter = GetStarshardCounter(level);
        counter += increament;
        SetStarshardCounter(level, counter);
    }
    override public function PostEnemySpawned(entity:Entity):Void
    {
        super.PostEnemySpawned(entity);
        if (!LogicSaveExt.IsStarshardUnlocked(Global.Saves))
            return;
        if (VanillaEnemyProps.HasNoReward(entity))
            return;
        var level = entity.Level;
        var counter = GetStarshardCounter(level);
        if (counter >= COUNTER_PER_STARSHARD - 1)
        {
            entity.AddBuff(StarshardCarrierBuff);
            counter -= COUNTER_PER_STARSHARD;
            SetStarshardCounter(level, counter);
        }
    }
    public static function GetStarshardCounter(level:LevelEngine):Float
    {
        return level.GetProperty(PROP_STARSHARD_COUNTER);
    }
    public static function SetStarshardCounter(level:LevelEngine, value:Float):Void
    {
        level.SetProperty(PROP_STARSHARD_COUNTER, value);
    }
    public static function AddStarshardCounter(level:LevelEngine, value:Float):Void
    {
        SetStarshardCounter(level, GetStarshardCounter(level) + value);
    }

    private static inline var PROP_REGION:String = "starshard_drop_stage";
    @:levelPropertyRegistry(PROP_REGION)
    public static var PROP_STARSHARD_COUNTER:VanillaLevelPropertyMeta<Float> = new VanillaLevelPropertyMeta<Float>("starshard_counter", DEFAULT_STARSHARD_COUNTER);
    public static inline var COUNTER_PER_STARSHARD:Int = 6;
    public static inline var DEFAULT_STARSHARD_COUNTER:Int = 3;
}
