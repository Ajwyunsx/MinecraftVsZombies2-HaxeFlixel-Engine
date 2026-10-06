// Ported from: Assets/Scripts/Vanilla/GameContent/Seeds/EntitySeed.cs
package mvz2.gamecontent.seeds;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.seedpacks.UpgradeEndlessCostBuff;
import mvz2logic.blueprints.LogicSeedProps;
import mvz2logic.blueprints.SeedTypes;
import mvz2logic.entities.LogicContraptionProps;
import mvz2logic.level.LogicStageProps;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.buffs.Buff;
import pvzengine.buffs.IBuffTarget;
import pvzengine.seedpacks.EngineSeedProps;
import pvzengine.seedpacks.SeedDefinition;
import pvzengine.seedpacks.SeedPack;

class EntitySeed extends SeedDefinition
{
    public function new(nsp:String, name:String, info:EntitySeedInfo)
    {
        super(nsp, name);
        SetProperty(LogicSeedProps.SEED_TYPE, SeedTypes.ENTITY);
        SetProperty(LogicSeedProps.SEED_ENTITY_ID, info.entityID);
        SetProperty(EngineSeedProps.COST, info.cost);
        SetProperty(EngineSeedProps.RECHARGE_ID, info.rechargeID);
        SetProperty(LogicSeedProps.TRIGGER_ACTIVE, info.triggerActive);
        SetProperty(LogicSeedProps.CAN_INSTANT_EVOKE, info.canInstantEvoke);
        SetProperty(LogicSeedProps.CAN_INSTANT_TRIGGER, info.canInstantTrigger);
        SetProperty(LogicSeedProps.VARIANT, info.variant);
        SetProperty(LogicSeedProps.ICON, info.icon);
        SetProperty(LogicSeedProps.MOBILE_ICON, info.mobileIcon);
        SetProperty(LogicSeedProps.MODEL_ID, info.model);
        SetProperty(LogicSeedProps.UPGRADE_BLUEPRINT, info.upgrade);
        if (info.upgrade)
        {
            AddAura(new UpgradeEndlessCostAura());
        }
    }
}

// PORT-NOTE: C# 嵌套类 EntitySeed.UpgradeEndlessCostAura → Haxe 模块子类型，访问路径一致。
class UpgradeEndlessCostAura extends AuraEffectDefinition
{
    public function new()
    {
        super(VanillaBuffID.SeedPack.upgradeEndlessCost);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        if (!LogicStageProps.IsEndless(auraEffect.Level))
            return;
        var source = auraEffect.Source;
        if (!Std.isOfType(source, SeedPack))
            return;
        var seedPack:SeedPack = cast source;
        if (!LogicSeedProps.IsUpgradeBlueprintOfPack(seedPack))
            return;
        results.push(seedPack);
    }
    public override function UpdateTargetBuff(effect:AuraEffect, target:IBuffTarget, buff:Buff):Void
    {
        super.UpdateTargetBuff(effect, target, buff);
        if (!Std.isOfType(target, SeedPack))
            return;
        var seed:SeedPack = cast target;
        if (LogicSeedProps.GetSeedTypeOfPack(seed) != SeedTypes.ENTITY)
            return;
        var entityID = LogicSeedProps.GetSeedEntityIDOfPack(seed);
        if (!NamespaceID.IsValid(entityID))
            return;
        buff.SetProperty(UpgradeEndlessCostBuff.PROP_ADDITION, seed.Level.GetEntityCount(entityID) * ADDITION);
    }
    public static inline var ADDITION:Float = 50;
}

// PORT-NOTE: C# struct → Haxe class（PORTING.md §struct）。构造函数接受可选的匿名结构参数，
// 以保留 C# 对象初始化器写法 `new EntitySeedInfo({field: value})`。
class EntitySeedInfo
{
    public var entityID:NamespaceID;
    public var cost:Int;
    public var rechargeID:Null<NamespaceID>;
    public var triggerActive:Bool;
    public var canInstantTrigger:Bool;
    public var upgrade:Bool;
    public var canInstantEvoke:Bool;
    public var variant:Int;
    public var icon:Null<SpriteReference>;
    public var mobileIcon:Null<SpriteReference>;
    public var model:Null<NamespaceID>;

    public function new(?data:{?entityID:NamespaceID, ?cost:Int, ?rechargeID:Null<NamespaceID>, ?triggerActive:Bool,
        ?canInstantTrigger:Bool, ?upgrade:Bool, ?canInstantEvoke:Bool, ?variant:Int, ?icon:Null<SpriteReference>,
        ?mobileIcon:Null<SpriteReference>, ?model:Null<NamespaceID>})
    {
        if (data == null)
            return;
        if (data.entityID != null) entityID = data.entityID;
        if (data.cost != null) cost = data.cost;
        if (data.rechargeID != null) rechargeID = data.rechargeID;
        if (data.triggerActive != null) triggerActive = data.triggerActive;
        if (data.canInstantTrigger != null) canInstantTrigger = data.canInstantTrigger;
        if (data.upgrade != null) upgrade = data.upgrade;
        if (data.canInstantEvoke != null) canInstantEvoke = data.canInstantEvoke;
        if (data.variant != null) variant = data.variant;
        if (data.icon != null) icon = data.icon;
        if (data.mobileIcon != null) mobileIcon = data.mobileIcon;
        if (data.model != null) model = data.model;
    }
}
