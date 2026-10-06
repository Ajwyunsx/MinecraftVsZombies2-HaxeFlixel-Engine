// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Chapter4/DivineShieldCooldownBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import tools.FrameTimer;
import tools.TimerHelper;

@:autoBuffDefinition(VanillaBuffNames.Entity_divineShieldCooldown)
class DivineShieldCooldownBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMER, TimerHelper.NewSecondTimer(COOLDOWN_SECONDS));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timer = buff.GetProperty(PROP_TIMER);
        if (timer.RunToExpiredOrNull())
        {
            buff.Remove();
        }
    }
    public static inline var COOLDOWN_SECONDS:Float = 5;
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
}
