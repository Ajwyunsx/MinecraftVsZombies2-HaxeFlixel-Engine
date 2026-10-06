// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter3/ReverseSatellite.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.FlyBuff;
import mvz2.gamecontent.buffs.level.ReverseSatelliteBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.Explosion;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.level.VanillaLevelExt;
import mvz2.vanilla.level.VanillaLevelStates;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEnemyStates;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LevelPositions;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import unity.Vector3;
using mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.reverseSatellite)
class ReverseSatellite extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var buff = entity.AddBuff(FlyBuff);
        buff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, 80);

        entity.Level.AddLoopSoundEntity(VanillaSoundID.morseCodeReverse, entity.ID);

        SetLeaveTimer(entity, new FrameTimer(LEAVE_TIME));

        entity.Velocity = new Vector3(entity.RNG.Next(-1, 1), 0, entity.RNG.Next(-1, 1));
    }
    override function UpdateAI(enemy:Entity):Void
    {
        super.UpdateAI(enemy);
        if (!enemy.Level.HasBuff(ReverseSatelliteBuff))
        {
            enemy.Level.AddBuff(ReverseSatelliteBuff);
        }
        if (!IsLeft(enemy))
        {
            var leavingTimer = GetLeaveTimer(enemy);
            if (leavingTimer.RunToExpiredOrNull() || enemy.Level.WaveState == VanillaLevelStates.STATE_AFTER_FINAL_WAVE || enemy.Level.IsAllEnemiesCleared())
            {
                SetLeft(enemy, true);
            }
        }

        switch (enemy.State)
        {
            case STATE_STAY:
                UpdateStateWalk(enemy);
            case STATE_LEAVE:
                UpdateStateLeaving(enemy);
        }
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        entity.RemoveBuffs(FlyBuff);
    }
    public override function PostContactGround(entity:Entity, velocity:Vector3):Void
    {
        super.PostContactGround(entity, velocity);
        if ((entity.IsDead || entity.IsAIFrozen()) && entity.IsAboveLand())
        {
            var damageMutliplier = entity.Level.GetReverseSatelliteDamageMultiplier();
            var radius = entity.GetRange();
            var damage = entity.GetDamage() * damageMutliplier;
            if (damage >= 0)
            {
                entity.Explode(entity.GetCenter(), radius, entity.GetFaction(), damage, new DamageEffectList([VanillaDamageEffects.EXPLOSION]));
            }
            // PORT-NOTE: C# 重载 Spawn(Entity, Vector3 position, Vector3 size) 在 Haxe 中改名为 SpawnWithSize。
            Explosion.SpawnWithSize(entity, entity.GetCenter(), entity.GetScaledSize());
            entity.PlaySound(VanillaSoundID.explosion);

            entity.Remove();
        }
    }
    function UpdateStateWalk(enemy:Entity):Void
    {
        var pos = enemy.Position;
        var velocity = enemy.Velocity;
        var centerX = LevelPositions.LAWN_CENTER_X;
        var centerZ = enemy.Level.GetLawnCenterZ();
        var backDistanceX = 200;
        var backDistanceZ = 80;
        if (pos.x > centerX + backDistanceX)
        {
            if (velocity.x > -3)
            {
                velocity.x -= 0.1;
            }
        }
        else if (pos.x < centerX - backDistanceX)
        {
            if (velocity.x < 3)
            {
                velocity.x += 0.1;
            }
        }
        if (pos.z > centerZ + backDistanceZ)
        {
            if (velocity.z > -3)
            {
                velocity.z -= 0.1;
            }
        }
        else if (pos.z < centerZ - backDistanceZ)
        {
            if (velocity.z < 3)
            {
                velocity.z += 0.1;
            }
        }
        var magnitude = velocity.magnitude;
        magnitude += 0.05;
        enemy.Velocity = velocity.normalized * magnitude;
    }
    function UpdateStateLeaving(enemy:Entity):Void
    {
        var velocity = enemy.Velocity;
        if (velocity.x < 6)
        {
            velocity.x += 0.1;
        }
        enemy.Velocity = velocity;

        var pos = enemy.Position;
        if (pos.x > LevelPositions.RIGHT_BORDER || pos.y > 640 || pos.z < -40)
        {
            enemy.Remove();
        }
    }
    public static function GetLeaveTimer(entity:Entity):Null<FrameTimer> return entity.GetBehaviourField(FIELD_LEAVE_TIMER);
    public static function SetLeaveTimer(entity:Entity, value:FrameTimer):Void entity.SetBehaviourField(FIELD_LEAVE_TIMER, value);
    public static function IsLeft(entity:Entity):Bool return entity.GetBehaviourField(FIELD_LEFT);
    public static function SetLeft(entity:Entity, value:Bool):Void entity.SetBehaviourField(FIELD_LEFT, value);
    public static inline var STATE_STAY:Int = LogicEnemyStates.WALK;
    public static inline var STATE_LEAVE:Int = LogicEnemyStates.LEAVE;
    public static inline var LEAVE_TIME:Int = 900;
    public static var FIELD_LEFT:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("is_left");
    public static var FIELD_LEAVE_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("LeaveTimer");
}
