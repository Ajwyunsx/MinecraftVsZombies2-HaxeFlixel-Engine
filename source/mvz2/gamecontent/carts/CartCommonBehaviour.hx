// Ported from: Assets/Scripts/Vanilla/GameContent/Carts/CartCommonBehaviour.cs
package mvz2.gamecontent.carts;

import mvz2.gamecontent.buffs.carts.CartFadeInBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.GemEffect;
import mvz2.vanilla.VanillaMod;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.carts.ICartBehaviour;
import mvz2.vanilla.carts.VanillaCartExt;
import mvz2.vanilla.carts.VanillaCartProps;
import mvz2.vanilla.carts.VanillaCartStates;
import mvz2.vanilla.effects.FragmentExt;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.difficulties.LogicDifficultyProps;
import mvz2logic.entities.LogicEnemyProps;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LevelPositions;
import mvz2logic.level.LogicLevelExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.cartCommon)
class CartCommonBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        LogicEntityProps.SetCanUpdateBeforeGameStart(entity, true);
        entity.AddBuff(CartFadeInBuff);
    }

    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        StateUpdate(entity);
        TriggerChargeUpdate(entity);
        TurnToMoneyUpdate(entity);
    }
    function StateUpdate(entity:Entity):Void
    {
        var velocity = entity.Velocity;
        switch (entity.State)
        {
            case STATE_TRIGGERED:
                velocity.x = 10;
                // 获取所有接触到的僵尸。
                for (ent in entity.Level.FindEntities(e -> VanillaCartExt.CanCartCrush(entity, e)))
                {
                    // 碰到小车的僵尸受到伤害。
                    var effects = new DamageEffectList(VanillaDamageEffects.DAMAGE_BOTH_ARMOR_AND_BODY, VanillaDamageEffects.MUTE, VanillaDamageEffects.INSTA_KILL, VanillaDamageEffects.NO_REVIVAL);
                    VanillaEntityExt.TakeDamage(ent, VanillaMod.INSTA_DAMAGE_AMOUNT, effects, entity);
                    for (behaviour in entity.Definition.GetBehaviours())
                    {
                        var cartBehaviour:ICartBehaviour = Std.isOfType(behaviour, ICartBehaviour) ? (cast behaviour : ICartBehaviour) : null;
                        if (cartBehaviour != null)
                            cartBehaviour.PostCrush(entity, ent);
                    }
                }
                // 如果超出屏幕，消失。
                if (entity.GetBounds().min.x >= LevelPositions.GetBorderX(true))
                {
                    entity.Remove();
                }
            default:
                if (entity.Position.x < LevelPositions.CART_TARGET_X)
                {
                    velocity.x = 10;
                }
                else
                {
                    var pos = entity.Position;
                    pos.x = LevelPositions.CART_TARGET_X;
                    entity.Position = pos;
                    velocity.x = 0;
                }

                // PORT-NOTE: EntityExists(filter:Dynamic) 的形参是 Dynamic，Haxe 无法从谓词体反推参数类型，
                // 需显式标注为 Entity（否则 e 会被推断成匿名结构类型，与 Entity 的 Position 访问权限冲突）。
                if (entity.Level.EntityExists((e:Entity) -> e.Position.x <= entity.Position.x + TRIGGER_DISTANCE && e.Type == EntityTypes.ENEMY && e.GetLane() == entity.GetLane() && !e.IsDead && !LogicEnemyProps.IsHarmless(e) && entity.IsHostile(e)))
                {
                    VanillaCartExt.TriggerCart(entity);
                }
        }
        entity.Velocity = velocity;
    }
    function TriggerChargeUpdate(entity:Entity):Void
    {
        if (!IsCartTriggerCharging(entity))
        {
            SetCartTriggerCharge(entity, 0);
        }
        SetCartTriggerCharging(entity, false);
        entity.SetModelProperty("Charge", GetCartTriggerCharge(entity) / MAX_TRIGGER_CHARGE);
    }
    function TurnToMoneyUpdate(entity:Entity):Void
    {
        var timer = VanillaCartProps.GetTurnToMoneyTimer(entity);
        if (timer == null)
            return;
        timer.Run();
        if (timer.Expired)
        {
            var level = entity.Level;
            var difficultyMeta = level.Content.GetDifficultyDefinition(level.Difficulty);
            var money = 50;
            if (difficultyMeta != null)
            {
                money = LogicDifficultyProps.GetCartConvertMoney(difficultyMeta);
            }
            var gemEffects = GemEffect.SpawnGemEffects(level, money, entity.Position, entity, true, 0);
            for (effect in gemEffects)
            {
                LogicEntityExt.PlaySound(effect, VanillaSoundID.points, 1 + (level.GetMaxLaneCount() - entity.GetLane() - 1) * 0.1);
            }
            LogicLevelExt.ShowMoney(level);
            entity.Remove();
        }
    }
    public static function ChargeUpTrigger(entity:Entity):Void
    {
        SetCartTriggerCharging(entity, true);
        var charge = GetCartTriggerCharge(entity);
        charge++;
        if (charge >= MAX_TRIGGER_CHARGE)
        {
            charge = 0;
            VanillaCartExt.TriggerCart(entity);
        }
        SetCartTriggerCharge(entity, charge);
    }
    public override function PostDeath(entity:Entity, deathInfo:DeathInfo):Void
    {
        super.PostDeath(entity, deathInfo);
        if (!VanillaEntityExt.WillRemoveOnDeath(entity, deathInfo))
        {
            FragmentExt.CreateFragmentAndPlay(entity, null, 500);
        }
        entity.Remove();
    }
    public static function SetCartTriggerCharge(entity:Entity, value:Int):Void entity.SetBehaviourField(FIELD_TRIGGER_CHARGE, value);
    public static function GetCartTriggerCharge(entity:Entity):Int return entity.GetBehaviourField(FIELD_TRIGGER_CHARGE);
    public static function SetCartTriggerCharging(entity:Entity, value:Bool):Void entity.SetBehaviourField(FIELD_TRIGGER_CHARGING, value);
    public static function IsCartTriggerCharging(entity:Entity):Bool return entity.GetBehaviourField(FIELD_TRIGGER_CHARGING);

    public static var FIELD_TRIGGER_CHARGE:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("TriggerCharge");
    public static var FIELD_TRIGGER_CHARGING:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("TriggerCharging");
    public static inline var TRIGGER_DISTANCE:Float = 28;
    public static inline var STATE_TRIGGERED:Int = VanillaCartStates.TRIGGERED;
    public static inline var MAX_TRIGGER_CHARGE:Int = 30;
}
