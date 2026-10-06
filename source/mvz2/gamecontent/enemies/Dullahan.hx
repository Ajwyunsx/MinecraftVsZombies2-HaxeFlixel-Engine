// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter3/Dullahan.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.entities.CharmBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2.vanilla.unlocks.VanillaUnlockID;
import mvz2logic.Global;
import mvz2logic.entities.IDeathEffectsBehaviour;
import mvz2logic.entities.LogicEnemyProps;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.EntityID;
import pvzengine.NamespaceID;
import pvzengine.callbacks.CallbackResult;
import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;
import pvzengine.grids.GridSourceReference;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.contents.enemies.LogicEnemyExt;
using mvz2logic.entities.LogicEnemyProps;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.dullahan)
class Dullahan extends AIEntityBehaviour implements IDeathEffectsBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_APPLY_STATUS_EFFECT, PostEntityCharmCallback, VanillaBuffID.Entity.charm);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.ChangeModel(VanillaModelID.dullahanMain);
        var param = entity.GetSpawnParams();
        if (entity.IsPreviewEnemy())
        {
            param.SetProperty(LogicEnemyProps.PREVIEW_ENEMY, true);
        }
        // C#: entity.Spawn(...)?.Let(e => { entity.RideOn(e); })
        var e = entity.Spawn(VanillaEnemyID.skeletonHorse, entity.Position, param);
        if (e != null)
        {
            entity.RideOn(e);
        }
        entity.SetAnimationBool("HoldingHead", !IsHeadDropped(entity));
    }
    function PostEntityCharmCallback(param:PostApplyStatusEffectParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var buff = param.buff;
        if (!entity.IsEntityOf(VanillaEnemyID.dullahan))
            return;
        var head = GetHead(entity);
        if (!head.ExistsAndAlive())
            return;
        CharmBuff.CloneCharm(buff, head);
    }
    override function UpdateAI(enemy:Entity):Void
    {
        super.UpdateAI(enemy);
        var horse = enemy.GetRidingEntity();
        if (horse == null)
        {
            DropHead(enemy);
        }
        else if (horse.IsEntityOf(VanillaEnemyID.skeletonHorse))
        {
            if (horse.State == SkeletonHorse.STATE_JUMP)
            {
                DropHead(enemy);
            }
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);

        entity.SetAnimationBool("HoldingHead", !IsHeadDropped(entity));
    }
    public function DeathEffects(entity:Entity, info:DeathInfo):Void
    {
        DropHead(entity);
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        if (Std.isOfType(info.Source, GridSourceReference) && !info.HasEffect(VanillaDamageEffects.FALL_DAMAGE))
        {
            Global.Saves.Unlock(VanillaUnlockID.midasTouchdown);
        }
    }
    public static function DropHead(entity:Entity):Null<Entity>
    {
        if (IsHeadDropped(entity))
            return null;
        // C#: entity.SpawnWithParams(...)?.Let(e => { ... })
        var head = entity.SpawnWithParams(VanillaEnemyID.dullahanHead, entity.GetCenter());
        if (head != null)
        {
            SetHead(entity, head);
            DullahanHead.SetBody(head, entity);
        }
        SetHeadDropped(entity, true);
        return head;
    }

    public static function IsHeadDropped(entity:Entity):Bool return entity.GetBehaviourFieldNS(ID, FIELD_HEAD_DROPPED);
    public static function SetHeadDropped(entity:Entity, value:Bool):Void entity.SetBehaviourFieldNS(ID, FIELD_HEAD_DROPPED, value);
    public static function GetHead(entity:Entity):Null<Entity>
    {
        var entityID = entity.GetBehaviourFieldNS(ID, FIELD_HEAD);
        return entityID != null ? entityID.GetEntity(entity.Level) : null;
    }
    public static function SetHead(entity:Entity, value:Entity):Void
    {
        entity.SetBehaviourFieldNS(ID, FIELD_HEAD, new EntityID(value));
    }

    public static var FIELD_HEAD:VanillaEntityPropertyMeta<EntityID> = new VanillaEntityPropertyMeta<EntityID>("Head");
    public static var FIELD_HEAD_DROPPED:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("HeadDropped");
    static var ID:NamespaceID = VanillaEnemyID.dullahan;
}
