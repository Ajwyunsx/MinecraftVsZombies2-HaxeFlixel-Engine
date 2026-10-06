// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Boss/BossRevengeBuff.cs
package mvz2.gamecontent.buffs.bosses;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.MaxHealthModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.Boss_bossRevenge)
class BossRevengeBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new MaxHealthModifier(NumberOperator.Multiply, PROP_HEALTH_MULTIPLIER));
    }
    public static var PROP_HEALTH_MULTIPLIER:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("health_multiplier", 1.5);
}
