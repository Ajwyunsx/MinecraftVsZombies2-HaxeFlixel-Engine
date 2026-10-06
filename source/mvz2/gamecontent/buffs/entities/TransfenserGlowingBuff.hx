// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Chapter6/TransfenserGlowingBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.callbacks.VanillaCallbackPriorities;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.models.LogicModelHelper;
import pvzengine.buffs.Buff;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.ColorModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import tools.FrameTimer;
import tools.TimerHelper;
import unity.Color;
import unity.Vector3;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PreTakeDamageParams;

@:autoBuffDefinition(VanillaBuffNames.Entity_transfenserGlowing)
class TransfenserGlowingBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, VanillaModelKeys.glowingParticles, VanillaModelID.glowingParticles);
        AddModifier(new BooleanModifier(LogicEntityProps.IS_LIGHT_SOURCE, true));
        AddModifier(ColorModifier.Override(LogicEntityProps.LIGHT_COLOR, Color.yellow));
        AddModifier(new Vector3Modifier(LogicEntityProps.LIGHT_RANGE, NumberOperator.Set, Vector3.one * 256));
        var colorModifier = new ColorModifier(EngineEntityProps.COLOR_OFFSET, new Color(1, 1, 0, 0.2));
        colorModifier.NoStack = true;
        AddModifier(colorModifier);
        AddTrigger(VanillaLevelCallbacks.PRE_ENTITY_TAKE_DAMAGE, PreEntityTakeDamageCallback, VanillaCallbackPriorities.MULTIPLY);
    }
    public override function OnCreate(buff:Buff):Void
    {
        super.OnCreate(buff);
        SetTimer(buff, TimerHelper.NewSecondTimer(DEFAULT_SECONDS));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timer = GetTimer(buff);
        if (timer.RunToExpiredOrNull())
        {
            buff.Remove();
        }
    }
    public static function GetTimer(buff:Buff):Null<FrameTimer>
    {
        return buff.GetProperty(PROP_TIMER);
    }
    public static function SetTimer(buff:Buff, value:Null<FrameTimer>):Void
    {
        buff.SetProperty(PROP_TIMER, value);
    }
    public static function ResetTime(buff:Buff, frames:Int):Void
    {
        var timer = GetTimer(buff);
        if (timer == null)
            return;
        timer.ResetTime(frames);
    }
    public static function MaxTime(buff:Buff, frames:Int):Void
    {
        var timer = GetTimer(buff);
        if (timer == null || timer.Frame >= frames)
            return;
        timer.ResetTime(frames);
    }
    private function PreEntityTakeDamageCallback(param:PreTakeDamageParams, result:CallbackResult):Void
    {
        var input = param.input;
        var entity = input.Entity;
        if (entity.HasBuff(TransfenserGlowingBuff))
        {
            input.Multiply(DAMAGE_MULTIPLIER);
        }
    }
    public static inline var DEFAULT_SECONDS:Float = 0;
    public static inline var DAMAGE_MULTIPLIER:Float = 1.5;
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
}
