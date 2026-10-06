// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Tarots/TheEmperorEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.buffs.entities.DivineShieldBuff;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import tools.RandomGenerator;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.theEmperor)
class TheEmperorEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        for (contrap in level.FindEntities(function(e) return e.Type == EntityTypes.PLANT && contraption.IsFriendly(e) && e.ExistsAndAlive()))
        {
            if (!contrap.HasBuff(DivineShieldBuff))
            {
                contrap.AddBuff(DivineShieldBuff);
            }
        }
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "IV-皇帝";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "所有器械获得圣盾";
}
