// Ported from: Assets/Scripts/Vanilla/GameContent/Stages/Definitions/LittleZombieStage.cs
package mvz2.gamecontent.stages;

import mvz2.gamecontent.buffs.enemies.BigTroubleBuff;
import mvz2.gamecontent.buffs.enemies.LittleZombieBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.properties.VanillaLevelPropertyMeta;
import pvzengine.entities.EntityTypes;
import mvz2logic.level.LogicLevelExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.definitions.StageDefinition;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;

@:autoStageDefinition(VanillaStageNames.bigTroubleAndLittleZombie)
class LittleZombieStage extends StageDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddBehaviour(new WaveStageBehaviour(this));
        AddBehaviour(new FinalWaveClearBehaviour(this));
        AddBehaviour(new GemStageBehaviour(this));
        AddBehaviour(new StarshardStageBehaviour(this));
        AddBehaviour(new ConveyorStageBehaviour(this));

        AddTrigger(LevelCallbacks.POST_ENTITY_INIT, PostEnemyInitCallback, EntityTypes.ENEMY);
    }
    override public function OnPostWave(level:LevelEngine, wave:Int):Void
    {
        super.OnPostWave(level, wave);
        if (wave == 11)
        {
            level.PlaySound(VanillaSoundID.growBig);
        }
    }
    public function PostEnemyInitCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var level = entity.Level;
        if (level.StageDefinition != this)
            return;
        var big = false;
        if (level.CurrentWave > 10)
        {
            var bigCounter = GetBigCounter(level);
            if (bigCounter > MAX_BIG_COUNTER)
            {
                bigCounter -= MAX_BIG_COUNTER;
                big = true;
            }
            else
            {
                bigCounter++;
            }
            SetBigCounter(level, bigCounter);
        }
        if (big)
        {
            entity.AddBuff(BigTroubleBuff);
        }
        else
        {
            entity.AddBuff(LittleZombieBuff);
        }
    }
    public static function GetBigCounter(level:LevelEngine):Int
    {
        return level.GetProperty(FIELD_BIG_COUNTER);
    }
    public static function SetBigCounter(level:LevelEngine, value:Int):Void
    {
        level.SetProperty(FIELD_BIG_COUNTER, value);
    }

    public static inline var REGION_NAME:String = "little_zombie_stage";
    @:levelPropertyRegistry(REGION_NAME)
    public static var FIELD_BIG_COUNTER:VanillaLevelPropertyMeta<Int> = new VanillaLevelPropertyMeta<Int>("BigCounter");
    public static inline var MAX_BIG_COUNTER:Int = 6;
}
