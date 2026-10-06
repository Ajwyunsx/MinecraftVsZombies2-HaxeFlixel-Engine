// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter6/ShadowCell.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.FlyBuff;
import mvz2.gamecontent.buffs.enemies.SmallShadowCellBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2logic.entities.IDeathEffectsBehaviour;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import tools.Ticks;
import unity.Color;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.Ticks;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.shadowCell)
class ShadowCell extends AIEntityBehaviour implements IDeathEffectsBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var buff = entity.AddBuff(FlyBuff);
        buff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, 20);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        if (entity.IsOnGround && entity.IsAboveLand())
        {
            var effects = new DamageEffectList([VanillaDamageEffects.MUTE, VanillaDamageEffects.SELF_DAMAGE, VanillaDamageEffects.IGNORE_ARMOR]);
            var damage = Ticks.FromPerSecond(GROUND_DAMAGE_PER_SECOND);
            entity.TakeDamage(damage, effects, entity);
        }
        entity.SetAnimationFloat("AnimationSpeed", entity.IsAIFrozen() ? 0 : 1);
    }

    public function DeathEffects(entity:Entity, info:DeathInfo):Void
    {
        if (entity.HasBuff(SmallShadowCellBuff))
            return;
        var lane = entity.GetLane();
        var spawnParam = entity.GetSpawnParams();
        for (i in 0...2)
        {
            var laneOffset = i * 2 - 1;
            // PORT-NOTE: C# Mathf.Clamp(int,int,int) 重载在 Haxe 中改名为 Mathf.ClampInt（lane 为 Int，StartChangingLane 需要 Int）。
            var l = Mathf.ClampInt(lane + laneOffset, 0, entity.Level.GetMaxLaneCount() - 1);
            // C#: entity.Spawn(...)?.Let(e => { ... })
            var e = entity.Spawn(VanillaEnemyID.shadowCell, entity.Position, spawnParam);
            if (e != null)
            {
                // PORT-NOTE: C# 的 StartChangingLane(target, speed) 重载在 Haxe 中改名为 StartChangingLaneWithSpeed。
                e.StartChangingLaneWithSpeed(l, CHANGE_LANE_SPEED);
                e.AddBuff(SmallShadowCellBuff);
            }
        }
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        if (!entity.WillRemoveOnDeath(info))
        {
            var param = entity.GetSpawnParams();
            param.SetProperty(EngineEntityProps.TINT, Color.black);
            entity.Spawn(VanillaEffectID.bloodParticles, entity.GetCenter(), param);
            entity.Remove();
        }
    }
    public static inline var GROUND_DAMAGE_PER_SECOND:Float = 100;
    public static inline var CHANGE_LANE_SPEED:Float = 10;
}
