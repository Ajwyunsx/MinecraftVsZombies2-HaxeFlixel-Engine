// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Stages/RandomEnemySpeedBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;

@:autoBuffDefinition(VanillaBuffNames.Enemy_randomEnemySpeed)
class RandomEnemySpeedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEnemyProps.SPEED, NumberOperator.Multiply, PROP_SPEED));
    }
    public static function SetSpeed(buff:Buff, value:Float):Void
    {
        buff.SetProperty(PROP_SPEED, value);
    }
    public static var PROP_SPEED:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("Speed");
}
