// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter1/TNT.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.contraptions.TNTChargedBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.ElectricArc;
import mvz2.gamecontent.effects.Explosion;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.gamecontent.bosses.Frankenstein;
import mvz2.gamecontent.projectiles.VanillaProjectileID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.contraptions.IExplodeContraptionBehaviour;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.projectiles.VanillaProjectileExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.buffs.BuffExt;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DamageOutput;
import pvzengine.entities.Entity;
import unity.Mathf;
import unity.Quaternion;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileExt;
using mvz2logic.entities.LogicContraptionProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.tnt)
class TNT extends ContraptionBehaviour implements IExplodeContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function PostTakeDamage(result:DamageOutput):Void
    {
        super.PostTakeDamage(result);
        if (result.BodyResult == null)
            return;
        if (result.BodyResult.Effects.HasEffect(VanillaDamageEffects.LIGHTNING))
        {
            Charge(result.Entity);
        }
    }
    public function Explode(entity:Entity, range:Float, damage:Float):Void
    {
        if (IsDumb(entity))
        {
            entity.Remove();
            entity.PlaySound(VanillaSoundID.pop);
        }
        else
        {
            ExplodeStatic(entity, range, damage);
        }
    }
    // PORT-NOTE: C# 中显式接口实现与静态方法同名（Haxe 不允许静态/实例同名字段），静态方法改名为 ExplodeStatic。
    public static function ExplodeStatic(entity:Entity, range:Float, damage:Float):Array<DamageOutput>
    {
        var damageEffects = new DamageEffectList([VanillaDamageEffects.MUTE, VanillaDamageEffects.DAMAGE_BODY_AFTER_ARMOR_BROKEN, VanillaDamageEffects.EXPLOSION]);
        var damageOutputs = entity.Explode(entity.Position, range, entity.GetFaction(), damage, damageEffects);
        for (output in damageOutputs)
        {
            var result = output.BodyResult;
            if (result != null && result.Fatal)
            {
                var target = output.Entity;
                var distance = (target.Position - entity.Position).magnitude;
                var speed = 25 * Mathf.Lerp(1, 0.5, distance / range);
                target.Velocity = target.Velocity + Vector3.up * speed;
            }
        }
        Explosion.Spawn(entity, entity.GetCenter(), range);
        entity.PlaySound(VanillaSoundID.explosion);
        entity.Level.ShakeScreen(10, 0, 15);

        if (entity.IsEvoked())
        {
            EvokedExplode(entity, range, damage);
        }
        if (IsCharged(entity))
        {
            ChargedExplode(entity);
        }
        entity.Level.Triggers.RunCallbackFiltered(VanillaLevelCallbacks.POST_CONTRAPTION_DETONATE, new EntityCallbackParams(entity), entity.GetDefinitionID());

        return damageOutputs;
    }
    static function EvokedExplode(entity:Entity, range:Float, damage:Float):Void
    {
        for (i in 0...4)
        {
            var direction = Quaternion.Euler(0, i * 90, 0) * Vector3.right * 10;
            var velocity = direction;
            velocity.y = 10;
            var shootParams = entity.GetShootParams();
            shootParams.projectileID = VanillaProjectileID.flyingTNT;
            shootParams.velocity = velocity;
            shootParams.pivot = VanillaEntityProps.SHOT_PIVOT_BOTTOM;
            // C#: entity.ShootProjectile(shootParams)?.Let(projectile => { ... })
            var projectile = entity.ShootProjectile(shootParams);
            if (projectile != null)
            {
                projectile.SetDamage(damage);
                projectile.SetRange(range);
                if (IsCharged(entity))
                {
                    Charge(projectile);
                }
            }
        }
    }
    public static function Charge(tnt:Entity):Void
    {
        if (tnt.HasBuff(TNTChargedBuff))
            return;
        tnt.AddBuff(TNTChargedBuff);
    }
    public static function IsCharged(tnt:Entity):Bool
    {
        return tnt.HasBuff(TNTChargedBuff);
    }
    public static function ExplodeArcs(entity:Entity, position:Vector3, arcLength:Float = 1000):Void
    {
        var level = entity.Level;
        for (i in 0...18)
        {
            // C#: level.Spawn(...)?.Let(e => { ... })
            var e = level.Spawn(VanillaEffectID.electricArc, position, entity);
            if (e != null)
            {
                var degree = i * 20;
                var rad = degree * Mathf.Deg2Rad;
                var pos = position + new Vector3(Mathf.Sin(rad), 0, Mathf.Cos(rad)) * arcLength;
                ElectricArc.Connect(e, pos);
                ElectricArc.UpdateArc(e);
            }
        }
    }
    static function ChargedExplode(entity:Entity):Void
    {
        ExplodeArcs(entity, entity.Position);
        var level = entity.Level;
        for (unit in level.FindEntities(e -> entity.IsHostile(e)))
        {
            unit.TakeDamage(entity.GetDamage(), new DamageEffectList([VanillaDamageEffects.LIGHTNING, VanillaDamageEffects.IGNORE_ARMOR]), entity);
            if (unit.IsEntityOf(VanillaBossID.frankenstein))
            {
                Frankenstein.Paralyze(unit, entity);
            }
        }
        entity.PlaySound(VanillaSoundID.thunder);
    }
    public static function IsDumb(entity:Entity):Bool return entity.GetProperty(PROP_DUMB);
    public static function SetDumb(entity:Entity, value:Bool):Void entity.SetProperty(PROP_DUMB, value);
    public static var PROP_DUMB:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("dumb");
}
