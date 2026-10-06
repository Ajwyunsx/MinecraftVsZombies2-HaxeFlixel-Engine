// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Tarots/TheHierophantEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.enemies.VanillaEnemyID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.theHierophant)
class TheHierophantEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        var spawnParams = contraption.GetSpawnParams();
        for (lane in 0...level.GetMaxLaneCount())
        {
            var position = level.GetEntityGridPosition(0, lane);
            contraption.Spawn(VanillaEnemyID.mesmerizer, position, spawnParams);
        }
        contraption.PlaySound(VanillaSoundID.mindControl);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "V-教皇";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "每行召唤一个友方的催眠者";
}
