// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Chapter2/ParabotBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.detections.ParabotDetector;
import mvz2.gamecontent.effects.Explosion;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2.vanilla.projectiles.ShootParams;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.models.LogicModelHelper;
import pvzengine.buffs.Buff;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.Entity;
import unity.Mathf;
import unity.Vector3;
import pvzengine.callbacks.LevelCallbacks.EntityDeathParams;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoBuffDefinition(VanillaBuffNames.Entity_parabot)
class ParabotBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = new ParabotDetector(RANGE);
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, VanillaModelKeys.parabotInsected, VanillaModelID.parabotInsected);
        AddTrigger(LevelCallbacks.POST_ENTITY_DEATH, PostEntityDeathCallback);
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_COOLDOWN, MAX_COOLDOWN);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        UpdateCooldown(buff);
        UpdateExplosion(buff);
        UpdateTimeout(buff);
    }
    private function UpdateCooldown(buff:Buff):Void
    {
        var cooldown = buff.GetProperty(PROP_COOLDOWN);
        cooldown--;
        if (cooldown <= 0)
        {
            ShootTick(buff);
            cooldown = MAX_COOLDOWN;
        }
        buff.SetProperty(PROP_COOLDOWN, cooldown);
    }
    private function ShootTick(buff:Buff):Void
    {
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        var level = buff.Level;
        var centerPos = entity.GetCenter();

        // PORT-NOTE: C# 的隐式转换 operator DetectionParams(Entity) 在 Haxe 中用工厂方法 fromEntity 显式表达
        //   （类上的 @:from 不生效，只有 abstract 支持 @:from 隐式转换）。
        var param = DetectionParams.fromEntity(entity);
        param.faction = GetFaction(buff);
        var target = detector.DetectEntityWithTheLeast(param, function(e) return GetTargetPriority(centerPos, e));
        if (target != null)
        {
            var otherCenter = target.GetCenter();
            var shootParams = new ShootParams();
            shootParams.damage = 20;
            shootParams.faction = GetFaction(buff);
            shootParams.position = centerPos;
            shootParams.projectileID = VanillaProjectileID.parabot;
            shootParams.soundID = VanillaSoundID.bow;
            shootParams.velocity = (otherCenter - centerPos).normalized * 10;
            shootParams.spawnParam = entity.GetSpawnParams();
            var projectile = VanillaProjectileExt.ShootProjectile(entity, shootParams);
            if (projectile != null)
            {
                projectile.Timeout = Mathf.CeilToInt(RANGE / projectile.Velocity.magnitude);
            }
        }
    }
    private function UpdateExplosion(buff:Buff):Void
    {
        var explodeTime = GetExplodeTime(buff);
        if (explodeTime <= 0)
            return;
        explodeTime--;
        buff.SetProperty(PROP_EXPLODE_TIME, explodeTime);

        var model = buff.GetInsertedModel(VanillaModelKeys.parabotInsected);
        if (model != null)
        {
            model.SetAnimationBool("Exploding", true);
        }
        if (explodeTime <= 0)
        {
            ParabotExplode(buff);
            buff.Remove();
        }
    }
    private function ParabotExplode(buff:Buff):Void
    {
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        var level = entity.Level;
        var range = 50;
        var centerPos = entity.GetCenter();
        entity.Explode(centerPos, range, GetFaction(buff), 500, new DamageEffectList([VanillaDamageEffects.EXPLOSION, VanillaDamageEffects.DAMAGE_BOTH_ARMOR_AND_BODY, VanillaDamageEffects.MUTE]));

        Explosion.Spawn(entity, centerPos, range);
        LogicEntityExt.PlaySound(entity, VanillaSoundID.explosion);
        level.ShakeScreen(10, 0, 15);
    }
    private function UpdateTimeout(buff:Buff):Void
    {
        if (GetExplodeTime(buff) > 0)
            return;
        var timeout = buff.GetProperty(PROP_TIMEOUT);
        timeout--;
        buff.SetProperty(PROP_TIMEOUT, timeout);
        if (timeout <= 0)
        {
            buff.Remove();
            return;
        }
    }
    private function GetFaction(buff:Buff):Int
    {
        return buff.GetProperty(PROP_FACTION);
    }
    private function GetExplodeTime(buff:Buff):Int
    {
        return buff.GetProperty(PROP_EXPLODE_TIME);
    }
    private function PostEntityDeathCallback(param:EntityDeathParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var info = param.deathInfo;
        var buffs = entity.GetBuffs(ParabotBuff);
        for (buff in buffs)
        {
            if (GetExplodeTime(buff) > 0)
            {
                ParabotExplode(buff);
            }
        }
        // PORT-NOTE: C# Entity.RemoveBuffs(IEnumerable<Buff>) 在 Haxe 侧以“按定义类移除”代替。
        entity.RemoveBuffs(ParabotBuff);
    }
    private function GetTargetPriority(sourcePos:Vector3, target:Entity):Float
    {
        var priority = (sourcePos - target.GetCenter()).magnitude;
        if (target.HasBuff(ParabotBuff))
            priority += 100000000;
        return priority;
    }
    public static var PROP_TIMEOUT:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Timeout");
    public static var PROP_COOLDOWN:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Cooldown");
    public static var PROP_FACTION:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("Faction");
    public static var PROP_EXPLODE_TIME:VanillaBuffPropertyMeta<Int> = new VanillaBuffPropertyMeta<Int>("ExplodeTime");
    public static inline var MAX_COOLDOWN:Int = 45;
    public static inline var MAX_EXPLODE_TIME:Int = 24;
    public static inline var RANGE:Float = 280;
    private var detector:ParabotDetector;
}
