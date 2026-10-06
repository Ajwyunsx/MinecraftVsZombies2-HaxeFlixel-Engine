// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter6/ControlRodUnstableBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.enemies.Berserker;
import mvz2logic.callbacks.LogicLevelCallbacks;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EntityTypes;
import pvzengine.callbacks.LevelCallbacks.EntityDeathParams;

@:autoBuffDefinition(VanillaBuffNames.Enemy_controlRodUnstable)
class ControlRodUnstableBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LogicLevelCallbacks.ENTITY_DEATH_EFFECTS, DeathEffectsCallback, 0, EntityTypes.ENEMY);
    }
    private function DeathEffectsCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var buffCount = entity.GetBuffCount(ControlRodUnstableBuff);
        if (buffCount <= 0)
            return;
        var effects = new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.MUTE]);
        Berserker.ExplodeFull(entity, DAMAGE_PER_BUFF * buffCount, RADIUS, effects, entity.GetFaction());
    }
    public static inline var DAMAGE_PER_BUFF:Float = 300;
    public static inline var RADIUS:Float = 120;
}
