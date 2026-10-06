// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter2/NocturnalBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2logic.models.LogicModelHelper;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Contraption_nocturnal)
class NocturnalBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, VanillaModelKeys.nocturnal, VanillaModelID.nocturnal);
        AddModifier(new BooleanModifier(VanillaEntityProps.AI_FROZEN, true));
        AddModifier(new BooleanModifier(VanillaEntityProps.NO_EXPLOSION, true));
    }
}
