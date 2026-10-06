// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter3/DullahanHead.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.enemies.FlyBuff;
import mvz2.gamecontent.buffs.entities.CharmBuff;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.EntityID;
import pvzengine.buffs.BuffExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.dullahanHead)
class DullahanHead extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(VanillaLevelCallbacks.POST_APPLY_STATUS_EFFECT, PostEntityCharmCallback, VanillaBuffID.Entity.charm);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var buff = entity.AddBuff(FlyBuff);
        buff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, 20);
    }
    function PostEntityCharmCallback(param:PostApplyStatusEffectParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        var buff = param.buff;
        if (!entity.IsEntityOf(VanillaEnemyID.dullahanHead))
            return;
        var body = GetBody(entity);
        if (!body.ExistsAndAlive())
            return;
        CharmBuff.CloneCharm(buff, body);
    }
    public static function GetBody(entity:Entity):Null<Entity>
    {
        var entityID = entity.GetBehaviourField(FIELD_BODY);
        return entityID != null ? entityID.GetEntity(entity.Level) : null;
    }
    public static function SetBody(entity:Entity, value:Entity):Void
    {
        entity.SetBehaviourField(FIELD_BODY, new EntityID(value));
    }
    public static var FIELD_BODY:VanillaEntityPropertyMeta<EntityID> = new VanillaEntityPropertyMeta<EntityID>("Body");
}
