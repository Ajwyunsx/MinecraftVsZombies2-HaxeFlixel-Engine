// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter4/BottledBlackholeBuff.cs
// PORT-NOTE: 原 C# 文件名为 BottledBlackholeBuff.cs，顶层类名为 BottledBlackholeDamageBuff；
// 便于 Haxe 按类名 import，此 .hx 以类名命名。
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.Contraption_bottledBlackholeDamage)
class BottledBlackholeDamageBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEntityProps.DAMAGE, NumberOperator.AddMultiple, PROP_DAMAGE_MULTIPLIER));
    }
    public static function SetDamageMultiplier(buff:Buff, value:Float):Void
    {
        buff.SetProperty(PROP_DAMAGE_MULTIPLIER, value);
    }
    public static var PROP_DAMAGE_MULTIPLIER:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("damageMultiplier");
}
