// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Projectiles/Chapter2/GhastFireChargeBuff.cs
package mvz2.gamecontent.buffs.projectiles;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;

@:autoBuffDefinition(VanillaBuffNames.Projectile_ghastFireCharge)
class GhastFireChargeBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEntityProps.DAMAGE, NumberOperator.Multiply, PROP_DAMAGE_MULTIPLIER));
        AddModifier(new FloatModifier(VanillaEntityProps.RANGE, NumberOperator.Multiply, PROP_RANGE_MULTIPLIER));
        AddModifier(new Vector3Modifier(EngineEntityProps.SCALE, NumberOperator.Multiply, PROP_SCALE_MULTIPLIER));
        AddModifier(new Vector3Modifier(EngineEntityProps.DISPLAY_SCALE, NumberOperator.Multiply, PROP_SCALE_MULTIPLIER));
    }
    public static function SetDamageMultiplier(buff:Buff, value:Float):Void buff.SetProperty(PROP_DAMAGE_MULTIPLIER, value);
    public static function SetRangeMultiplier(buff:Buff, value:Float):Void buff.SetProperty(PROP_RANGE_MULTIPLIER, value);
    public static function SetScaleMultiplier(buff:Buff, value:Vector3):Void buff.SetProperty(PROP_SCALE_MULTIPLIER, value);
    public static var PROP_DAMAGE_MULTIPLIER:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("damageMultiplier");
    public static var PROP_RANGE_MULTIPLIER:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("rangeMultiplier");
    public static var PROP_SCALE_MULTIPLIER:VanillaBuffPropertyMeta<Vector3> = new VanillaBuffPropertyMeta<Vector3>("scaleMultiplier");
}
