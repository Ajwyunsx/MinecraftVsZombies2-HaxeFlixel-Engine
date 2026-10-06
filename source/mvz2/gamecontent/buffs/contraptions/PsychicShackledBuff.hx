// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter6/PsychicShackledBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2logic.models.LogicModelHelper;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Contraption_psychicShackled)
class PsychicShackledBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(VanillaEntityProps.AI_FROZEN, true));
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, VanillaModelKeys.psychicShackled, VanillaModelID.shackled);
    }
}
