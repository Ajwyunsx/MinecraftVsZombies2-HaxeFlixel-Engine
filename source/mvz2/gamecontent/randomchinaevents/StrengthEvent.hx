// Ported from: Assets/Scripts/Vanilla/GameContent/RandomChinaEvents/Tarots/StrengthEvent.cs
package mvz2.gamecontent.randomchinaevents;

import mvz2.gamecontent.buffs.armors.BigTroubleArmorBuff;
import mvz2.gamecontent.buffs.enemies.BigTroubleBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2.vanilla.randomchina.RandomChinaEventDefinition;
import pvzengine.armors.Armor;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import tools.RandomGenerator;
using mvz2logic.entities.LogicEntityExt;

@:randomChinaEventDefinition(VanillaRandomChinaEventNames.strength)
class StrengthEvent extends RandomChinaEventDefinition
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
            if (!enemy.HasBuff(BigTroubleBuff))
            {
                enemy.AddBuff(BigTroubleBuff);
            }
            for (slot in enemy.GetActiveArmorSlots())
            {
                var armor = enemy.GetArmorAtSlot(slot);
                if (!Armor.ExistsArmor(armor))
                    continue;
                if (armor.HasBuff(BigTroubleArmorBuff))
                    continue;
                armor.AddBuff(BigTroubleArmorBuff);
            }
        }
        contraption.PlaySound(VanillaSoundID.growBig);
    }
    @:translateMsg("随机瓷器事件名称", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_NAME)
    public static inline var NAME:String = "VIII-力量";
    @:translateMsg("随机瓷器事件描述", VanillaStrings.CONTEXT_RANDOM_CHINA_EVENT_DESCRIPTION)
    public static inline var DESCRIPTION:String = "所有敌怪变大";
}
