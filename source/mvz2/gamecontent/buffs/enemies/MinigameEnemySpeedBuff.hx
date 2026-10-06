// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Stages/MinigameEnemySpeedBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.enemies.VanillaEnemyProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.Entity;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import unity.Mathf;

@:autoBuffDefinition(VanillaBuffNames.Enemy_minigameEnemySpeed)
class MinigameEnemySpeedBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEnemyProps.SPEED, NumberOperator.Multiply, PROP_SPEED_MULTIPLIER));
    }
    public static function AddSpeedBuff(entity:Entity, min:Float, max:Float):Buff
    {
        var buff = entity.AddBuff(MinigameEnemySpeedBuff);
        buff.SetProperty(MinigameEnemySpeedBuff.PROP_SPEED_MULTIPLIER, Mathf.Lerp(min, max, entity.Level.CurrentWave / entity.Level.GetTotalWaveCount()));
        return buff;
    }
    public static var PROP_SPEED_MULTIPLIER:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("SpeedMultiplier");
}
