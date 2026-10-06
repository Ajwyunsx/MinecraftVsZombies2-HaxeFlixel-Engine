// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/SeedPacks/Difficulty/EasyBlueprintBuff.cs
package mvz2.gamecontent.buffs.seedpacks;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import pvzengine.definitions.BuffDefinition;
import pvzengine.level.EngineSeedProps;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.SeedPack_easyBlueprint)
class EasyBlueprintBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(EngineSeedProps.RECHARGE_SPEED, NumberOperator.Multiply, 1.25));
    }
}
