// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Prologue/Obsidian.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.ObsidianArmorBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.obsidian)
class Obsidian extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    override function UpdateLogic(contraption:Entity):Void
    {
        super.UpdateLogic(contraption);
        var maxHP = contraption.GetMaxHealth();
        var netherite = contraption.HasBuff(ObsidianArmorBuff);
        if (netherite)
        {
            if (contraption.Health <= maxHP * 0.4)
            {
                var hp = contraption.Health;
                contraption.RemoveBuffs(ObsidianArmorBuff);
                netherite = false;
                contraption.Health = hp;
            }
        }

        if (netherite)
        {
            var percent = GetArmoredDamagePercent(contraption, maxHP);
            contraption.SetModelDamagePercentValue(percent);
        }
        else
        {
            contraption.SetModelDamagePercent();
        }
        contraption.SetModelProperty("Netherite", netherite);
    }

    public override function CanEvoke(entity:Entity):Bool
    {
        if (entity.HasBuff(ObsidianArmorBuff))
            return false;
        return super.CanEvoke(entity);
    }

    override function OnEvoke(contraption:Entity):Void
    {
        super.OnEvoke(contraption);
        contraption.AddBuff(ObsidianArmorBuff);
        contraption.Health = contraption.GetMaxHealth();
        contraption.Level.PlaySound(VanillaSoundID.armorUp);
    }
    function GetArmoredDamagePercent(contraption:Entity, maxHP:Float):Float
    {
        var percent = contraption.Health / maxHP;
        var armorPercent = (percent - 0.4) / 0.6;
        return 1 - armorPercent;
    }
}
