// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/SuperRechargeEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.buffs.level.SuperRechargeBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
using mvz2logic.entities.LogicEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.superRecharge)
class SuperRechargeEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        level.AddBuff(SuperRechargeBuff);
        contraption.PlaySound(VanillaSoundID.growBig);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "超级充能";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "30秒内蓝图充能速度翻倍";
}
