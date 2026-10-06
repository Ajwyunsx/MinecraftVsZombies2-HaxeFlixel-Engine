// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/WorldwideCelebrationEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.buffs.entities.WorldwideCelebrationBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
using mvz2logic.entities.LogicEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.worldwideCelebration)
class WorldwideCelebrationEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        for (e in level.FindEntities(function(ent) return ent.IsVulnerableEntity()))
        {
            e.AddBuff(WorldwideCelebrationBuff);
        }

        contraption.PlaySound(VanillaSoundID.fastForward);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "普天同庆";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "30秒内所有单位的移速、攻击速度和生产速度翻倍";
}
