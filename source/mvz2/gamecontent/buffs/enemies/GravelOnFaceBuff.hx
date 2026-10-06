// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter6/GravelOnFaceBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.models.LogicModelHelper;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;
import tools.FrameTimer;
import tools.TimerHelper;

@:autoBuffDefinition(VanillaBuffNames.Enemy_gravelOnFace)
class GravelOnFaceBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModelInsertion(LogicModelHelper.ANCHOR_HEAD, VanillaModelKeys.gravelOnFace, VanillaModelID.gravelOnFace);
        AddModifier(new BooleanModifier(VanillaEntityProps.AI_FROZEN, true));
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
        var entity = buff.GetEntity();
        if (entity != null && entity.IsDead)
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
    public static inline var DEFAULT_SECONDS:Float = 5;
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
}
