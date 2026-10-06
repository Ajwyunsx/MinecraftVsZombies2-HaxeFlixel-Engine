// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter4/IZombieAttackBoosterBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.enemies.EnemyMeleeBehaviour;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EntityTypes;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import unity.Mathf;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostTakeDamageParams;

@:autoBuffDefinition(VanillaBuffNames.Enemy_iZombieAttackBooster)
class IZombieAttackBoosterBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEntityProps.ATTACK_SPEED, NumberOperator.Multiply, PROP_ATTACK_SPEED_MULTIPLIER));
        AddTrigger(VanillaLevelCallbacks.POST_ENTITY_TAKE_DAMAGE, PostEnemyTakeDamageCallback, 0, EntityTypes.ENEMY);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var attackTime = GetAttackTime(buff);
        var entity = buff.GetEntity();
        if (entity != null && EnemyMeleeBehaviour.IsMeleeAttacking(entity))
        {
            attackTime++;
        }
        else
        {
            attackTime = 0;
        }
        SetAttackTime(buff, attackTime);
        var speedMultiplier:Float = 1;
        if (attackTime > ATTACK_UP_TIME_START)
        {
            var t = (attackTime - ATTACK_UP_TIME_START) / (ATTACK_UP_TIME_END - ATTACK_UP_TIME_START);
            speedMultiplier = Mathf.Lerp(ATTACK_UP_MULTIPLIER_START, ATTACK_UP_MULTIPLIER_END, t);
        }
        SetAttackSpeedMultiplier(buff, speedMultiplier);
    }
    private function PostEnemyTakeDamageCallback(param:PostTakeDamageParams, result:CallbackResult):Void
    {
        var output = param.output;
        if (output == null)
            return;
        var entity = output.Entity;
        if (entity == null)
            return;
        var buffs = entity.GetBuffs(IZombieAttackBoosterBuff);
        for (buff in buffs)
        {
            SetAttackTime(buff, 0);
        }
    }
    public static function GetAttackTime(buff:Buff):Int return buff.GetProperty(PROP_ATTACK_TIME);
    public static function SetAttackTime(buff:Buff, value:Int):Void buff.SetProperty(PROP_ATTACK_TIME, value);
    public static function GetAttackSpeedMultiplier(buff:Buff):Float return buff.GetProperty(PROP_ATTACK_SPEED_MULTIPLIER);
    public static function SetAttackSpeedMultiplier(buff:Buff, value:Float):Void buff.SetProperty(PROP_ATTACK_SPEED_MULTIPLIER, value);
    public static inline var ATTACK_UP_TIME_START:Int = 150;
    public static inline var ATTACK_UP_TIME_END:Int = 300;
    public static inline var ATTACK_UP_MULTIPLIER_START:Float = 1;
    public static inline var ATTACK_UP_MULTIPLIER_END:Float = 5;
    public static var PROP_ATTACK_TIME:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("attackTime");
    public static var PROP_ATTACK_SPEED_MULTIPLIER:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("attackSpeedMultiplier");
}
