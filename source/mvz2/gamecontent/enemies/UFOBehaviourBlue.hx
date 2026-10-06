// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter5/UndeadFlyingObjectBlue.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.UFOBlueAbsorbBuff;
import mvz2.gamecontent.pickups.VanillaPickupID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.NamespaceID;
import pvzengine.PropertyRegions;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;

// PORT-NOTE: C# 扩展方法（Entity 的 AddBuff/HasBuff/RemoveBuffs、IsHostileEntity、IsSecondsInterval、
// Produce、GetBehaviourField）在 Haxe 侧以静态方法 + `using` 提供（PORTING.md §扩展方法）。
using mvz2logic.entities.LogicEntityExt;
using mvz2.vanilla.pickups.VanillaPickupExt;
using pvzengine.TimerHelper;
using pvzengine.buffs.BuffTargetExt;
using pvzengine.entities.EngineEntityExt;

class UFOBehaviourBlue extends UFOBehaviour
{
    public function new()
    {
        super(UndeadFlyingObject.VARIANT_BLUE);
    }
    public override function CanSpawn(level:LevelEngine, faction:Int):Bool
    {
        return true;
    }
    public override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        var isHostile = entity.IsHostileEntity();
        var isFriendly = entity.IsFriendlyEntity();
        var shouldAbsorb = entity.State == UFOBehaviour.STATE_ACT && isHostile;
        var shouldProduce = entity.State == UFOBehaviour.STATE_ACT && isFriendly;
        if (shouldAbsorb)
        {
            if (!entity.HasBuff(UFOBlueAbsorbBuff))
            {
                entity.AddBuff(UFOBlueAbsorbBuff);
            }
        }
        else
        {
            if (entity.HasBuff(UFOBlueAbsorbBuff))
            {
                entity.RemoveBuffs(UFOBlueAbsorbBuff);
            }
        }

        if (isFriendly)
        {
            DropAllAbsorbedEntities(entity);
        }
        if (shouldProduce)
        {
            if (entity.IsSecondsInterval(FRIENDLY_PRODUCE_INTERVAL_SECONDS))
            {
                entity.Produce(VanillaPickupID.redstone);
            }
        }
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        DropAllAbsorbedEntities(entity);
    }
    public override function UpdateActionState(entity:Entity, state:Int):Void
    {
        super.UpdateActionState(entity, state);
        // PORT-NOTE: Haxe 不继承静态成员，C# 中直接引用的基类静态成员需以 UFOBehaviour. 限定。
        switch (state)
        {
            case UFOBehaviour.STATE_STAY:
                UpdateStateStay(entity);
            case UFOBehaviour.STATE_ACT:
                UpdateStateAct(entity);
            case UFOBehaviour.STATE_LEAVE:
                UpdateStateLeave(entity);
        }
    }
    function UpdateStateStay(enemy:Entity):Void
    {
        EnterUpdate(enemy);

        var timer = UFOBehaviour.GetOrInitStateTimer(enemy, STAY_TIME);
        if (timer.RunToExpiredAndNotNull())
        {
            UFOBehaviour.SetUFOState(enemy, UFOBehaviour.STATE_ACT);
            timer.ResetTime(ACT_TIME);
        }
    }
    function UpdateStateAct(enemy:Entity):Void
    {
        EnterUpdate(enemy);

        var timer = UFOBehaviour.GetOrInitStateTimer(enemy, ACT_TIME);
        if (timer.RunToExpiredAndNotNull())
        {
            UFOBehaviour.SetUFOState(enemy, UFOBehaviour.STATE_LEAVE);
        }
    }
    function UpdateStateLeave(entity:Entity):Void
    {
        LeaveUpdate(entity);
    }
    public static function DropAllAbsorbedEntities(entity:Entity):Void
    {
        var absorbedEntities = GetAbsorbedEntityID(entity);
        if (absorbedEntities != null)
        {
            for (stolen in absorbedEntities)
            {
                if (NamespaceID.IsValid(stolen))
                {
                    entity.Spawn(stolen, entity.GetCenter());
                }
            }
            absorbedEntities = [];
        }
    }
    public static function GetAbsorbedEntityID(entity:Entity):Null<Array<NamespaceID>> return entity.GetBehaviourField(PROP_ABSORBED_ENTITY_ID);
    public static function SetAbsorbedEntityID(entity:Entity, value:Array<NamespaceID>):Void entity.SetBehaviourField(PROP_ABSORBED_ENTITY_ID, value);
    public static function AddAbsorbedEntityID(entity:Entity, value:NamespaceID):Void
    {
        var list = GetAbsorbedEntityID(entity);
        if (list == null)
        {
            list = [];
            SetAbsorbedEntityID(entity, list);
        }
        list.push(value);
    }
    public static function RemoveAbsorbedEntityID(entity:Entity, value:NamespaceID):Bool
    {
        var list = GetAbsorbedEntityID(entity);
        if (list == null)
        {
            return false;
        }
        return list.remove(value);
    }

    public static inline var STAY_TIME:Int = 30;
    public static inline var ACT_TIME:Int = 300;
    public static inline var FRIENDLY_PRODUCE_INTERVAL_SECONDS:Float = 1;
    public static inline var PROP_REGION:String = VanillaEnemyNames.ufo;
    @:propertyRegistry(PROP_REGION)
    public static var PROP_ABSORBED_ENTITY_ID:VanillaEntityPropertyMeta<Array<NamespaceID>> = new VanillaEntityPropertyMeta<Array<NamespaceID>>("absorbed_entity_id");
}
