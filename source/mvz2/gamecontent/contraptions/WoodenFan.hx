// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter5/WoodenFan.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.areas.VanillaAreaID;
import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.contraptions.WoodenFanBlowBuff;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import tools.Ticks;
import tools.TimerHelper;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.woodenFan)
class WoodenFan extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);

        SetStateTimer(entity, new FrameTimer(30));
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);

        var state = GetFanState(entity);

        switch (state)
        {
            case FAN_STATE_READY:
                UpdateStateReady(entity);
            case FAN_STATE_BLOW:
                UpdateStateBlow(entity);
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetAnimationInt("FanState", GetFanState(entity));
        entity.SetAnimationFloat("IdleSpeed", GetIdleSpeed(entity));
    }
    function UpdateStateReady(entity:Entity):Void
    {
        var timer = GetStateTimer(entity);
        if (timer.RunToExpiredOrNull())
        {
            if (timer != null)
                timer.ResetSeconds(BLOW_SECONDS);
            SetFanState(entity, FAN_STATE_BLOW);

            var evoked = entity.IsEvoked();

            var buff = entity.GetFirstBuff(VanillaBuffID.Contraption.woodenFanBlow);
            if (buff == null)
            {
                buff = entity.AddBuff(VanillaBuffID.Contraption.woodenFanBlow);
            }
            WoodenFanBlowBuff.SetEvoked(buff, evoked);

            entity.PlaySound(VanillaSoundID.blow);

            var level = entity.Level;
            var speedlineXSize = level.GetMaxColumnCount() * level.GetGridWidth();
            var speedlineYSize = AFFECT_HEIGHT;
            var speedlineZSize = (evoked ? level.GetMaxLaneCount() : 1) * level.GetGridHeight();
            var speedlineSize = new Vector3(speedlineXSize, speedlineYSize, speedlineZSize);
            var spawnParam = entity.GetSpawnParams();
            spawnParam.SetProperty(EngineEntityProps.SIZE, speedlineSize);
            spawnParam.SetProperty(EngineEntityProps.FLIP_X, entity.IsFlipX());

            var x = (level.GetGridLeftX() + level.GetGridRightX()) * 0.5;
            var y = entity.Position.y;
            var z = (evoked ? ((level.GetGridTopZ() + level.GetGridBottomZ()) * 0.5) : entity.Position.z);
            var position = new Vector3(x, y, z);
            // C#: entity.Spawn(...)?.Let(speedline => { ... })
            var speedline = entity.Spawn(VanillaEffectID.windSpeedline, position, spawnParam);
            if (speedline != null)
            {
                speedline.SetParent(entity);
                speedline.Timeout = Ticks.FromSeconds(BLOW_SECONDS);
            }
        }
    }
    function UpdateStateBlow(entity:Entity):Void
    {
        var timer = GetStateTimer(entity);
        if (timer.RunToExpiredOrNull())
        {
            entity.Remove();
        }
    }
    public override function CanTrigger(entity:Entity):Bool
    {
        return super.CanTrigger(entity) && !IsLaunched(entity);
    }
    override function OnTrigger(entity:Entity):Void
    {
        super.OnTrigger(entity);
        Launch(entity);
        entity.TriggerAnimation("Launch");
        entity.RemoveBuffs(VanillaBuffID.Contraption.woodenFanBlow);
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.SetEvoked(true);
        Launch(entity);
        entity.TriggerAnimation("Launch");
        entity.RemoveBuffs(VanillaBuffID.Contraption.woodenFanBlow);
    }
    public static function Launch(entity:Entity):Void
    {
        SetFanState(entity, FAN_STATE_READY);
        var timer = GetStateTimer(entity);
        if (timer == null)
        {
            timer = TimerHelper.NewSecondTimer(READY_TIME_SECONDS);
            SetStateTimer(entity, timer);
        }
        else
        {
            timer.ResetSeconds(READY_TIME_SECONDS);
        }
    }
    public static function IsLaunched(entity:Entity):Bool
    {
        var state = GetFanState(entity);
        return state == FAN_STATE_READY || state == FAN_STATE_BLOW;
    }
    public static function GetIdleSpeed(entity:Entity):Float
    {
        if (entity.Level.AreaID == VanillaAreaID.ship)
        {
            return 1;
        }
        return 0;
    }
    public static function GetFanState(entity:Entity):Int return entity.GetBehaviourField(PROP_FAN_STATE);
    public static function SetFanState(entity:Entity, value:Int):Void entity.SetBehaviourField(PROP_FAN_STATE, value);
    public static function GetStateTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(PROP_STATE_TIMER);
    public static function SetStateTimer(entity:Entity, timer:FrameTimer):Void entity.SetBehaviourField(PROP_STATE_TIMER, timer);
    public static var PROP_FAN_STATE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("fan_state");
    public static var PROP_STATE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("state_timer");
    public static inline var AFFECT_HEIGHT:Float = 400;
    public static inline var FAN_STATE_IDLE:Int = 0;
    public static inline var FAN_STATE_READY:Int = 1;
    public static inline var FAN_STATE_BLOW:Int = 2;
    public static inline var READY_TIME_SECONDS:Float = 0.33333333;
    public static inline var BLOW_SECONDS:Float = 3;
}
