// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter4/DevourerInvincibleBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.NamespaceIDArrayModifier;
import pvzengine.modifiers.SetOperator;

@:autoBuffDefinition(VanillaBuffNames.Contraption_devourerInvincible)
class DevourerInvincibleBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
        AddModifier(new NamespaceIDArrayModifier(LogicEntityProps.GRID_LAYERS, SetOperator.Set, []));
    }
}
