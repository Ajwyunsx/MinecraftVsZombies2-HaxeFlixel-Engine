// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Upgrade/HFPDUpgradedBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Contraption_hfpdUpgraded)
class HFPDUpgradedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicEntityProps.IS_LIGHT_SOURCE, true));
        AddModifier(new Vector3Modifier(LogicEntityProps.LIGHT_RANGE, NumberOperator.Add, LIGHT_RANGE_ADDITION));
    }
    public static var LIGHT_RANGE_ADDITION:Vector3 = new Vector3(80, 80, 80);
}
