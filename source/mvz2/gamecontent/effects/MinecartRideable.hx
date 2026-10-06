// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter6/MinecartRideable.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.Global;
import mvz2logic.callbacks.LogicLevelCallbacks;
import mvz2logic.level.LogicLevelExt;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.LevelCallbackParams;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Mathf;
import tools.Ref;
import unity.Vector2;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.minecartRideable)
class MinecartRideable extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LogicLevelCallbacks.POST_PAUSE, PostPauseCallback);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetTargetPosition(entity, entity.Position);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        // PORT-NOTE: C# 的 out 参数在 Haxe 中按 IGlobalInput 的声明改为 tools.Ref<Vector2> 容器。
        var screenPosition = new Ref<Vector2>(new Vector2(0, 0));
        if (Global.Input.TryGetPointerScreenPosition(screenPosition) && entity.Level.IsGameRunning())
        {
            var targetPosition = entity.Level.ScreenToLawnPositionByRelativeY(screenPosition.value, 0);
            SetTargetPosition(entity, targetPosition);
        }

        var parent = entity.Parent;
        if (parent.ExistsAndAlive())
        {
            FollowPointer(entity, parent, GetTargetPosition(entity));
        }
    }
    private function FollowPointer(entity:Entity, parent:Entity, targetPosition:Vector3):Void
    {
        var parentBounds = parent.GetBounds();
        var entityBounds = entity.GetBounds();
        var minX = parentBounds.min.x + entityBounds.extents.x;
        var maxX = parentBounds.max.x - entityBounds.extents.x;
        var minZ = parentBounds.min.z + entityBounds.extents.z;
        var maxZ = parentBounds.max.z - entityBounds.extents.z;
        targetPosition.x = minX < maxX ? Mathf.Clamp(targetPosition.x, minX, maxX) : parent.Position.x;
        targetPosition.z = minZ < maxZ ? Mathf.Clamp(targetPosition.z, minZ, maxZ) : parent.Position.z;
        var distance = targetPosition - entity.Position;
        var magnitude = Mathf.Max(0, distance.magnitude - 24);
        distance = magnitude * distance.normalized;
        var targetVelocity = distance * VELOCITY_DAMP;
        entity.Velocity = targetVelocity;
    }
    private function PostPauseCallback(param:LevelCallbackParams, result:CallbackResult):Void
    {
        var level = param.level;
        for (cart in level.FindEntities(function(e) return e.HasBehaviour(this)))
        {
            cart.Velocity = Vector3.zero;
            SetTargetPosition(cart, cart.Position);
        }
    }
    public static function GetTargetPosition(entity:Entity):Vector3 return entity.GetBehaviourField(PROP_TARGET_POSITION);
    public static function SetTargetPosition(entity:Entity, value:Vector3):Void entity.SetBehaviourField(PROP_TARGET_POSITION, value);
    public static inline var VELOCITY_DAMP:Float = 0.1;
    public static var PROP_TARGET_POSITION:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("target_position");
}
