// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Tarots/TheStarEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.buffs.level.BeaconMeteorBuff;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
using mvz2.vanilla.entities.VanillaEntityProps;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.theStar)
class TheStarEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        var buff = level.NewBuff(BeaconMeteorBuff);
        BeaconMeteorBuff.SetFaction(buff, contraption.GetFaction());
        BeaconMeteorBuff.SetDamage(buff, contraption.GetDamage() * 9);
        BeaconMeteorBuff.SetCount(buff, 10);
        BeaconMeteorBuff.SetRNG(buff, new RandomGenerator(rng.Next()));
        // C#: BeaconMeteorBuff.GetTimer(buff)?.Let(timer => timer.ResetTime(1));
        var timer = BeaconMeteorBuff.GetTimer(buff);
        if (timer != null)
        {
            timer.ResetTime(1);
        }
        level.AddBuff(buff);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "XVII-星星";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "召唤10枚陨石";
}
