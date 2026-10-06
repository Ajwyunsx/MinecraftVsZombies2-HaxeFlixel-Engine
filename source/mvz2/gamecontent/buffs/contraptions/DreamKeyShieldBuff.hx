// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter1/DreamKeyShieldBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2logic.models.LogicModelHelper;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;

@:autoBuffDefinition(VanillaBuffNames.Contraption_dreamKeyShield)
class DreamKeyShieldBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, VanillaModelKeys.dreamKeyShield, VanillaModelID.dreamKeyShield);
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
    }
}
