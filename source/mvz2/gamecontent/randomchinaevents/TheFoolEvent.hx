// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Tarots/TheFoolEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import tools.RandomGenerator;
using mvz2logic.entities.LogicEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.theFool)
class TheFoolEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        for (enemy in level.FindEntities(function(e) return e.Type == EntityTypes.ENEMY && contraption.IsHostile(e) && e.ExistsAndAlive()))
        {
            var pos = enemy.Position;
            pos.x = level.GetEnemySpawnX();
            enemy.Position = pos;
        }
        contraption.PlaySound(VanillaSoundID.timeWarp);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "0-愚者";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "所有敌怪回到起始点";
}
