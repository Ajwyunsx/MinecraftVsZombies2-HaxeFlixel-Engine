// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/WaterStain.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.effects.WaterStainFrozenBuff;
import mvz2.vanilla.enemies.VanillaMass;
import mvz2.vanilla.entities.VanillaColliderExt;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.Global;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.grids.LogicGridExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.auras.IBuffTarget;
import pvzengine.buffs.Buff;
import pvzengine.buffs.BuffExt;
import pvzengine.collisions.IEntityCollider;
import pvzengine.collisions.level.OverlapParams;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.EntityTypes;
import pvzengine.level.LevelEngine;
import pvzengine.modifiers.ColorModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import tools.Ticks;
import unity.Bounds;
import unity.Color;
import unity.Mathf;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaEffectNames.waterStain)
class WaterStain extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new WaterStainSlideAura());
        AddAura(new WaterStainWetGridAura());
        AddModifier(new Vector3Modifier(EngineEntityProps.DISPLAY_SCALE, NumberOperator.Multiply, PROP_DISPLAY_SCALE_MULTIPLIER));
        AddModifier(ColorModifier.Multiply(EngineEntityProps.TINT, PROP_TINT_MULTIPLIER));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var collisionMask = EntityCollisionHelper.MASK_ALL;
        entity.CollisionMaskFriendly = collisionMask;
        entity.CollisionMaskHostile = collisionMask;
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (!entity.IsAboveLand())
        {
            entity.Remove();
            return;
        }
        var t = Mathf.Clamp01(entity.Timeout / Ticks.FromSeconds(MAX_FADE_SECONDS));
        var colorMulti = new Color(1, 1, 1, t);
        var scaleMulti = Vector3.one * t;
        entity.SetProperty(PROP_TINT_MULTIPLIER, colorMulti);
        entity.SetProperty(PROP_DISPLAY_SCALE_MULTIPLIER, scaleMulti);
        entity.SetModelProperty("Frozen", IsStainFrozen(entity));
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        if (state == EntityCollisionHelper.STATE_EXIT)
            return;
        if (collision.Other.IsFrost())
        {
            var stain = collision.Entity;
            FreezeStain(stain);
        }
        else if (collision.Other.IsFire())
        {
            var stain = collision.Entity;
            MeltStain(stain);
            Disappear(stain);
        }
    }
    public static function FreezeStain(stain:Entity):Void
    {
        var buffID = VanillaBuffID.Effect.waterStainFrozen;
        // TODO-PORT: C# 重载 GetFirstBuff(NamespaceID) 与 GetFirstBuff(BuffDefinition 子类)，Haxe 无重载，最终方法名由 BuffExt 的移植方决定。
        var buff = stain.GetFirstBuff(buffID);
        if (buff == null)
        {
            buff = stain.AddBuff(buffID);
        }
        WaterStainFrozenBuff.ResetTimeout(buff);
    }
    public static function MeltStain(stain:Entity):Void
    {
        var buffID = VanillaBuffID.Effect.waterStainFrozen;
        stain.RemoveBuffs(buffID);
    }
    public static function IsStainFrozen(stain:Entity):Bool
    {
        return stain.HasBuff(VanillaBuffID.Effect.waterStainFrozen);
    }
    public static function UpdateStain(level:LevelEngine, position:Vector3, spawner:Entity):Null<Entity>
    {
        var foundStain = FindStainAtPosition(level, position);
        if (foundStain != null && foundStain.ExistsAndAlive())
        {
            foundStain.Timeout = foundStain.GetMaxTimeout();
            return foundStain;
        }
        else
        {
            return level.Spawn(VanillaEffectID.waterStain, position, spawner);
        }
    }
    public static function FindStainAtPosition(level:LevelEngine, position:Vector3):Null<Entity>
    {
        var bounds = GetDetectionBounds(position);

        var mask = EntityCollisionHelper.MASK_EFFECT;
        resultsBuffer.resize(0);
        var overlapParam = OverlapParams.AnyFaction(mask);
        level.OverlapBoxNonAlloc(bounds.center, bounds.size, overlapParam, resultsBuffer);
        // PORT-NOTE: C# LINQ `resultsBuffer.FirstOrDefault(c => ...)?.Entity` → Lambda.find + 显式判空。
        var found = Lambda.find(resultsBuffer, function(c) return c.Entity.IsEntityOf(VanillaEffectID.waterStain) && !IsDisappearing(c.Entity));
        return found != null ? found.Entity : null;
    }
    public static function Disappear(stain:Entity):Void
    {
        stain.Timeout = Mathf.MinInt(Ticks.FromSeconds(MAX_FADE_SECONDS), stain.Timeout);
    }
    public static function IsDisappearing(stain:Entity):Bool
    {
        return stain.Timeout <= Ticks.FromSeconds(MAX_FADE_SECONDS);
    }
    private static function GetDetectionBounds(position:Vector3):Bounds
    {
        var center = position;
        var def = Global.Game.GetEntityDefinition(VanillaEffectID.waterStain);
        var size = def != null ? def.GetSize() : new Vector3(32, 16, 32);
        size *= 0.5;
        size.y = 800;
        return new Bounds(center, size);
    }
    public static inline var MAX_FADE_SECONDS:Float = 0.5;
    private static var resultsBuffer:Array<IEntityCollider> = [];
    public static var PROP_DISPLAY_SCALE_MULTIPLIER:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("scale_multiplier");
    public static var PROP_TINT_MULTIPLIER:VanillaEntityPropertyMeta<Color> = new VanillaEntityPropertyMeta<Color>("tint_multiplier");
}

// PORT-NOTE: C# 的嵌套类 WaterStain.SlideAura 提升为模块级类（Haxe 不支持嵌套类）。
class WaterStainSlideAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Enemy.waterStainSlide, 4);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var source = auraEffect != null && auraEffect.Source != null ? auraEffect.Source.GetEntity() : null;
        if (source == null)
            return;
        if (WaterStain.IsDisappearing(source))
            return;
        collisions.resize(0);
        source.GetCurrentCollisions(collisions);
        for (collision in collisions)
        {
            if (!collision.OtherCollider.IsForMain())
                continue;
            var other = collision.Other;
            if (other.Type != EntityTypes.ENEMY)
                continue;
            if (other.GetGravity() <= 0 || !other.IsOnGround)
                continue;
            if (other.GetMass() >= VanillaMass.VERY_HEAVY) // 不影响极重敌人。
                continue;
            results.push(other);
        }
    }
    private var collisions:Array<EntityCollision> = [];
}

// PORT-NOTE: C# 的嵌套类 WaterStain.WetGridAura 提升为模块级类（Haxe 不支持嵌套类）。
class WaterStainWetGridAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.Grid.waterStainWet, 7);
    }

    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var source = auraEffect != null && auraEffect.Source != null ? auraEffect.Source.GetEntity() : null;
        if (source == null)
            return;
        if (WaterStain.IsStainFrozen(source))
            return;
        var grid = source.GetGrid();
        if (grid == null)
            return;
        results.push(grid);
    }
}
