// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/HellMetalEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.armors.VanillaArmorID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import tools.RandomGenerator;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.hellMetal)
class HellMetalEvent extends RandomChinaEventDefinition
{
    public function new(nsp:String, path:String)
    {
        super(nsp, path, NAME, DESCRIPTION);
    }
    public override function Run(contraption:Entity, rng:RandomGenerator):Void
    {
        var level = contraption.Level;
        contraption.PlaySound(VanillaSoundID.armorUp);
        for (enemy in level.FindEntities(function(e) return e.Type == EntityTypes.ENEMY && e.ExistsAndAlive()))
        {
            enemy.EquipMainArmor(VanillaArmorID.ironHelmet);
        }
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "地狱金属";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "所有怪物装备铁盔";
}
