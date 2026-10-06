// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter2/CrushingWalls.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.effects.VanillaEffectStates;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.Global;
import mvz2logic.Shake.ShakeInt;
import mvz2logic.callbacks.LogicCallbacks;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.inputs.PointerPhase;
import mvz2logic.level.GameOverTypes;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.entities.Entity;
import tools.Transitions;
import unity.Mathf;
import unity.Random;
import unity.Vector3;
import mvz2logic.callbacks.LogicCallbacks.PostPointerActionParams;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.crushingWalls)
class CrushingWalls extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LogicCallbacks.POST_POINTER_ACTION, PostPointerActionCallback, PointerPhase.Press);
    }
    // #endregion

    public function PostPointerActionCallback(param:PostPointerActionParams, result:CallbackResult):Void
    {
        var type = param.type;
        var phase = param.phase;
        var screenPosition = param.screenPos;
        var level = Global.Level.GetLevel();
        if (level == null)
            return;
        if (!level.IsGameRunning())
            return;
        for (wall in level.FindEntities(VanillaEffectID.crushingWalls))
        {
            if (wall.State == STATE_IDLE)
            {
                var progress = GetProgress(wall);
                SetProgress(wall, progress - 0.01);
            }
        }
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        UpdateState(entity);
        UpdateShake(entity);
    }
    public static function Shake(wall:Entity, amplitudeStart:Float, amplitudeEnd:Float, time:Int):Void
    {
        SetShake(wall, new ShakeInt(amplitudeStart, amplitudeEnd, time));
    }
    public static function Enrage(wall:Entity):Void
    {
        wall.State = STATE_ENRAGED;
    }
    public static function Close(wall:Entity):Void
    {
        wall.State = STATE_CLOSED;
    }
    private function UpdateState(entity:Entity):Void
    {
        var progress = GetProgress(entity);
        switch (entity.State)
        {
            case STATE_IDLE:
                var speed = VanillaDifficultyLevelProps.GetCrushingWallsSpeed(entity.Level);

                progress += speed * 0.01 / 30;
                progress = Mathf.Clamp01(progress);
                entity.SetModelProperty("Progress", progress);
            case STATE_ENRAGED:
                progress *= 0.8;
                entity.SetModelProperty("Progress", progress);
            case STATE_CLOSED:
                progress += 1 / 15;
                var realProgress = Transitions.EaseIn(progress);
                if (progress >= 1)
                {
                    entity.Level.ShakeScreen(10, 0, 15);
                    entity.PlaySound(VanillaSoundID.smash);
                }
                entity.SetModelProperty("Progress", realProgress);
            case STATE_STOPPED:
                progress *= 0.6;
                if (progress <= 0.02)
                {
                    entity.Remove();
                }
                entity.SetModelProperty("Progress", progress);
        }
        SetProgress(entity, progress);


        if (progress >= 1)
        {
            if (LogicLevelProps.IsGodMode(entity.Level))
            {
                SetProgress(entity, 0.0);
            }
            else
            {
                entity.Level.GameOver(GameOverTypes.NO_ENEMY, entity, VanillaStrings.DEATH_MESSAGE_CRUSHING_WALLS);
            }
        }
    }
    private function UpdateShake(entity:Entity):Void
    {
        var shake = GetShake(entity);
        var shakeValue = Vector3.zero;
        if (shake != null)
        {
            shakeValue = shake.GetShake3D();
            shake.Run();
            if (shake.Expired)
            {
                SetShake(entity, null);
            }
        }
        switch (entity.State)
        {
            case STATE_IDLE:
                shakeValue += new Vector3(Random.Range(3, 3), Random.Range(3, 3), 0);
        }
        entity.SetModelProperty("Shake", shakeValue);
    }
    public static function GetProgress(entity:Entity):Float
    {
        return entity.GetBehaviourFieldNS(ID, PROP_PROGRESS);
    }
    public static function SetProgress(entity:Entity, value:Float):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_PROGRESS, value);
    }
    public static function GetShake(entity:Entity):Null<ShakeInt>
    {
        return entity.GetBehaviourFieldNS(ID, PROP_SHAKE);
    }
    public static function SetShake(entity:Entity, value:Null<ShakeInt>):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_SHAKE, value);
    }
    public static inline var STATE_IDLE:Int = VanillaEffectStates.IDLE;
    public static inline var STATE_CLOSED:Int = VanillaEffectStates.CRUSHING_WALLS_CLOSED;
    public static inline var STATE_STOPPED:Int = VanillaEffectStates.CRUSHING_WALLS_STOPPED;
    public static inline var STATE_ENRAGED:Int = VanillaEffectStates.CRUSHING_WALLS_ENRAGED;
    public static var PROP_PROGRESS:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("Progress");
    public static var PROP_SHAKE:VanillaEntityPropertyMeta<ShakeInt> = new VanillaEntityPropertyMeta<ShakeInt>("Shake");
    public static var ID:NamespaceID = VanillaEffectID.crushingWalls;
}
