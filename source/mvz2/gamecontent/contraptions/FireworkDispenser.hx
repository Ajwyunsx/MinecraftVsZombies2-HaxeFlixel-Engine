// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter5/FireworkDispenser.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffID;
import pvzengine.buffs.BuffExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.fireworkDispenser)
class FireworkDispenser extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.SetModelProperty("Evoked", entity.HasBuff(VanillaBuffID.Contraption.fireworkDispenserEvoked));
    }
}
