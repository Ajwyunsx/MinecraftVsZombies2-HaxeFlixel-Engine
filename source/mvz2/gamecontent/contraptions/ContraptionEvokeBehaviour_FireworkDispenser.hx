// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter5/FireworkDispenser/ContraptionEvokeBehaviour_FireworkDispenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.effects.FireworkBlast;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
using mvz2logic.entities.LogicEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.contraptionEvokeFireworkDispenser)
class ContraptionEvokeBehaviour_FireworkDispenser extends ContraptionEvokeBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function CanEvoke(entity:Entity):Bool
    {
        if (entity.HasBuff(VanillaBuffID.Contraption.fireworkDispenserEvoked))
            return false;
        return super.CanEvoke(entity);
    }
    public override function Evoke(entity:Entity):Void
    {
        super.Evoke(entity);
        entity.AddBuff(VanillaBuffID.Contraption.fireworkDispenserEvoked);
        FireworkBlast.SpawnFireworkBlast(entity, entity.GetCenter(), entity.GetRange(), entity.RNG);
        entity.PlaySound(VanillaSoundID.fireworkLargeBlast);
        entity.PlaySound(VanillaSoundID.fireworkTwinkle);
        entity.PlaySound(VanillaSoundID.fireworkLaunch);
    }
}
