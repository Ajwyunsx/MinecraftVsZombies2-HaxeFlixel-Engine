// Ported from: Assets/Scripts/Vanilla/Frameworks/Callbacks/VanillaLevelCallbacks.cs
package mvz2.vanilla.callbacks;

import mvz2.vanilla.projectiles.ProjectileHitInput;
import mvz2.vanilla.projectiles.ProjectileHitOutput;
import pvzengine.armors.Armor;
import pvzengine.armors.ArmorDamageResult;
import pvzengine.buffs.Buff;
import pvzengine.buffs.BuffDefinition;
import pvzengine.callbacks.CallbackType;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.damages.BodyDamageResult;
import pvzengine.damages.DamageInput;
import pvzengine.damages.DamageOutput;
import pvzengine.damages.HealInput;
import pvzengine.damages.HealOutput;
import pvzengine.entities.Entity;
import pvzengine.level.ILevelSourceReference;

class VanillaLevelCallbacks
{
    public static var PRE_ENTITY_TAKE_DAMAGE:CallbackType<PreTakeDamageParams> = new CallbackType();
    public static var POST_ENTITY_TAKE_DAMAGE:CallbackType<PostTakeDamageParams> = new CallbackType();
    public static var PRE_BODY_TAKE_DAMAGE:CallbackType<PreBodyTakeDamageParams> = new CallbackType();
    public static var POST_BODY_TAKE_DAMAGE:CallbackType<PostBodyTakeDamageParams> = new CallbackType();
    public static var PRE_ARMOR_TAKE_DAMAGE:CallbackType<PreArmorTakeDamageParams> = new CallbackType();
    public static var POST_ARMOR_TAKE_DAMAGE:CallbackType<PostArmorTakeDamageParams> = new CallbackType();
    public static var APPLY_DAMAGE_SPECIAL_EFFECTS:CallbackType<PostTakeDamageParams> = new CallbackType();
    public static var PRE_ENTITY_HEAL:CallbackType<PreHealParams> = new CallbackType();
    public static var POST_ENTITY_HEAL:CallbackType<PostHealParams> = new CallbackType();

    public static var PRE_APPLY_STATUS_EFFECT:CallbackType<PreApplyStatusEffectParams> = new CallbackType();
    public static var POST_APPLY_STATUS_EFFECT:CallbackType<PostApplyStatusEffectParams> = new CallbackType();
    public static var PRE_REMOVE_STATUS_EFFECT:CallbackType<PreRemoveStatusEffectParams> = new CallbackType();
    public static var POST_REMOVE_STATUS_EFFECT:CallbackType<PostRemoveStatusEffectParams> = new CallbackType();

    public static var POST_CONTRAPTION_TRIGGER:CallbackType<EntityCallbackParams> = new CallbackType();
    public static var POST_CONTRAPTION_EMPTY_HAND_CLICK:CallbackType<EntityCallbackParams> = new CallbackType();
    public static var POST_CONTRAPTION_EVOKE:CallbackType<EntityCallbackParams> = new CallbackType();
    public static var POST_CONTRAPTION_DESTROY:CallbackType<EntityCallbackParams> = new CallbackType();
    public static var POST_CONTRAPTION_DETONATE:CallbackType<EntityCallbackParams> = new CallbackType();
    public static var CAN_CONTRAPTION_SACRIFICE:CallbackType<ContraptionSacrificeValueParams> = new CallbackType();
    public static var GET_CONTRAPTION_SACRIFICE_FUEL:CallbackType<ContraptionSacrificeValueParams> = new CallbackType();
    public static var PRE_CONTRAPTION_SACRIFICE:CallbackType<ContraptionSacrificeParams> = new CallbackType();
    public static var POST_CONTRAPTION_SACRIFICE:CallbackType<ContraptionSacrificeParams> = new CallbackType();

    public static var POST_WATER_INTERACTION:CallbackType<WaterInteractionParams> = new CallbackType();
    public static var POST_AIR_INTERACTION:CallbackType<WaterInteractionParams> = new CallbackType();

    public static var ENEMY_DROP_REWARDS:CallbackType<EntityCallbackParams> = new CallbackType();
    public static var PRE_ENEMY_NEUTRALIZE:CallbackType<EntityCallbackParams> = new CallbackType();
    public static var POST_ENEMY_NEUTRALIZE:CallbackType<EntityCallbackParams> = new CallbackType();
    public static var PRE_ENEMY_FAINT:CallbackType<EntityCallbackParams> = new CallbackType();
    public static var POST_ENEMY_FAINT:CallbackType<EntityCallbackParams> = new CallbackType();
    public static var POST_OBSIDIAN_FIRST_AID:CallbackType<EntityCallbackParams> = new CallbackType();
    public static var POST_ENEMY_MELEE_ATTACK:CallbackType<EnemyMeleeAttackParams> = new CallbackType();

    public static var CAN_PICKUP_COLLECT:CallbackType<EntityCallbackParams> = new CallbackType();
    public static var POST_PICKUP_COLLECT:CallbackType<EntityCallbackParams> = new CallbackType();

    public static var POST_PROJECTILE_SHOT:CallbackType<EntityCallbackParams> = new CallbackType();
    public static var PRE_PROJECTILE_HIT:CallbackType<PreProjectileHitParams> = new CallbackType();
    public static var POST_PROJECTILE_HIT:CallbackType<PostProjectileHitParams> = new CallbackType();

    public static var POST_USE_STARSHARD:CallbackType<EntityCallbackParams> = new CallbackType();
}

// C#: public struct PreTakeDamageParams
class PreTakeDamageParams
{
    public var input:DamageInput;
    public var output:DamageOutput;

    public function new(input:DamageInput, output:DamageOutput)
    {
        this.input = input;
        this.output = output;
    }
}

// C#: public struct PostTakeDamageParams
class PostTakeDamageParams
{
    public var output:DamageOutput;

    public function new(output:DamageOutput)
    {
        this.output = output;
    }
}

// C#: public struct PreArmorTakeDamageParams
class PreArmorTakeDamageParams
{
    public var input:DamageInput;
    public var armor:Armor;
    public var result:ArmorDamageResult;

    public function new(input:DamageInput, armor:Armor, result:ArmorDamageResult)
    {
        this.input = input;
        this.armor = armor;
        this.result = result;
    }
}

// C#: public struct PostArmorTakeDamageParams
class PostArmorTakeDamageParams
{
    public var result:ArmorDamageResult;

    public function new(result:ArmorDamageResult)
    {
        this.result = result;
    }
}

// C#: public struct PreBodyTakeDamageParams
class PreBodyTakeDamageParams
{
    public var input:DamageInput;
    public var output:BodyDamageResult;

    public function new(input:DamageInput, output:BodyDamageResult)
    {
        this.input = input;
        this.output = output;
    }
}

// C#: public struct PostBodyTakeDamageParams
class PostBodyTakeDamageParams
{
    public var output:BodyDamageResult;

    public function new(output:BodyDamageResult)
    {
        this.output = output;
    }
}

// C#: public struct PreHealParams
class PreHealParams
{
    public var input:HealInput;

    public function new(?input:HealInput)
    {
        this.input = input;
    }
}

// C#: public struct PostHealParams
class PostHealParams
{
    public var output:HealOutput;

    public function new(?output:HealOutput)
    {
        this.output = output;
    }
}

// C#: public struct PreApplyStatusEffectParams
class PreApplyStatusEffectParams
{
    public var entity:Entity;
    public var buffDefinition:BuffDefinition;
    public var source:Null<ILevelSourceReference>;

    public function new(entity:Entity, definition:BuffDefinition, source:Null<ILevelSourceReference>)
    {
        this.entity = entity;
        this.buffDefinition = definition;
        this.source = source;
    }
}

// C#: public struct PostApplyStatusEffectParams
class PostApplyStatusEffectParams
{
    public var entity:Entity;
    public var buff:Buff;
    public var source:Null<ILevelSourceReference>;

    public function new(entity:Entity, buff:Buff, source:Null<ILevelSourceReference>)
    {
        this.entity = entity;
        this.buff = buff;
        this.source = source;
    }
}

// C#: public struct PreRemoveStatusEffectParams
class PreRemoveStatusEffectParams
{
    public var entity:Entity;
    public var buffDefinition:BuffDefinition;
    public var source:Null<ILevelSourceReference>;

    public function new(entity:Entity, definition:BuffDefinition, source:Null<ILevelSourceReference>)
    {
        this.entity = entity;
        this.buffDefinition = definition;
        this.source = source;
    }
}

// C#: public struct PostRemoveStatusEffectParams
class PostRemoveStatusEffectParams
{
    public var entity:Entity;
    public var buffDefinition:BuffDefinition;
    public var source:Null<ILevelSourceReference>;

    public function new(entity:Entity, definition:BuffDefinition, source:Null<ILevelSourceReference>)
    {
        this.entity = entity;
        this.buffDefinition = definition;
        this.source = source;
    }
}

// C#: public struct ContraptionSacrificeValueParams
class ContraptionSacrificeValueParams
{
    public var entity:Entity;
    public var soulFurnace:Entity;

    public function new(entity:Entity, soulFurnace:Entity)
    {
        this.entity = entity;
        this.soulFurnace = soulFurnace;
    }
}

// C#: public struct ContraptionSacrificeParams
class ContraptionSacrificeParams
{
    public var entity:Entity;
    public var soulFurnace:Entity;
    public var fuel:Int;

    public function new(entity:Entity, soulFurnace:Entity, fuel:Int)
    {
        this.entity = entity;
        this.soulFurnace = soulFurnace;
        this.fuel = fuel;
    }
}

// C#: public struct WaterInteractionParams
class WaterInteractionParams
{
    public var entity:Entity;
    public var action:Int;

    // PORT-NOTE: C# struct 有隐式无参构造函数，Haxe class 必须显式声明，调用处才能 `new WaterInteractionParams()`。
    public function new() {}
}

// C#: public struct EnemyMeleeAttackParams
class EnemyMeleeAttackParams
{
    public var enemy:Entity;
    public var target:Entity;
    public var amount:Float;

    public function new(enemy:Entity, target:Entity, amount:Float)
    {
        this.enemy = enemy;
        this.target = target;
        this.amount = amount;
    }
}

// C#: public struct PreProjectileHitParams
class PreProjectileHitParams
{
    public var hit:ProjectileHitInput;
    public var damage:DamageInput;

    // PORT-NOTE: C# struct 有隐式无参构造函数，Haxe class 必须显式声明，调用处才能 `new PreProjectileHitParams()`。
    public function new() {}
}

// C#: public struct PostProjectileHitParams
class PostProjectileHitParams
{
    public var hit:ProjectileHitOutput;
    public var damage:Null<DamageOutput>;

    // PORT-NOTE: C# struct 有隐式无参构造函数，Haxe class 必须显式声明，调用处才能 `new PostProjectileHitParams()`。
    public function new() {}
}
