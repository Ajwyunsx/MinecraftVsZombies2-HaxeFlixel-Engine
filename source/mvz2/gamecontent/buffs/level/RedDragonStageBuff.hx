// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter5/RedDragonStageBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import tools.FrameTimer;

@:autoBuffDefinition(VanillaBuffNames.Level_redDragonStage)
class RedDragonStageBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function OnCreate(buff:Buff):Void
    {
        super.OnCreate(buff);
        buff.SetProperty(PROP_THUNDER_TIMER, new FrameTimer(MAX_THUNDER_TIMEOUT));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timer = buff.GetProperty(PROP_THUNDER_TIMER);
        if (timer.RunToExpiredAndNotNull())
        {
            timer.Reset();
            VanillaLevelExt.Thunder(buff.Level);
        }
    }
    public static var PROP_THUNDER_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("thunder_timer");
    public static inline var MAX_THUNDER_TIMEOUT:Int = 300;
}
