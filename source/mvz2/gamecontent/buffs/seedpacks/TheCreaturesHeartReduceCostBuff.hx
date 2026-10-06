// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/SeedPacks/Chapter1/TheCreaturesHeartReduceCostBuff.cs
package mvz2.gamecontent.buffs.seedpacks;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.definitions.BuffDefinition;
import pvzengine.level.EngineSeedProps;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.SeedPack_theCreaturesHeartReduceCost)
class TheCreaturesHeartReduceCostBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(EngineSeedProps.COST, NumberOperator.Add, PROP_ADDITION));
    }
    public static var PROP_ADDITION:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("Reduction");
}
