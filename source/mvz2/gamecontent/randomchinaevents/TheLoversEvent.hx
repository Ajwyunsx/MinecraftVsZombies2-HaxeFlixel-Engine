// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Tarots/TheLoversEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaFactions;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntitySourceReference;
import pvzengine.entities.EntityTypes;
import tools.EnumerableExt;
import tools.RandomGenerator;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.theLovers)
class TheLoversEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        var enemies = level.FindEntities(function(e:Entity) return e.Type == EntityTypes.ENEMY && e.ExistsAndAlive() && !e.IsLoyal() && !e.IsCharmed());
        var contraptions = level.FindEntities(function(e:Entity) return e.Type == EntityTypes.PLANT && e.ExistsAndAlive() && !e.IsLoyal() && !e.IsCharmed() && e != contraption);
        if (enemies.length > 0 && contraptions.length > 0)
        {
            var enemy = EnumerableExt.Random(enemies, rng);
            enemy.CharmPermanent(VanillaFactions.THE_LOVERS, new EntitySourceReference(contraption));
            enemy.Spawn(VanillaEffectID.mindControlLines, enemy.GetCenter());

            var target = EnumerableExt.Random(contraptions, rng);
            target.CharmPermanent(VanillaFactions.THE_LOVERS, new EntitySourceReference(contraption));
            target.Spawn(VanillaEffectID.mindControlLines, target.GetCenter());
            contraption.PlaySound(VanillaSoundID.charmed);
            contraption.PlaySound(VanillaSoundID.floop);
        }
        else
        {
            contraption.PlaySound(VanillaSoundID.buzzer);
        }
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "VI-恋人";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "随机将一对器械和怪物变为中立阵营";
}
