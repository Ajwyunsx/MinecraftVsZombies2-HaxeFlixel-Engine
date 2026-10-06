// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/ZombieCloudRaindrop.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EngineEntityProps;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Mathf;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.zombieCloudRaindrop)
class ZombieCloudRaindrop extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.DISPLAY_SCALE, NumberOperator.Multiply, PROP_DISPLAY_SCALE_MULTIPLIER));
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var t = Mathf.Abs(entity.Velocity.y) / MAX_STRETCH_VELOCITY;
        var scaleMulti = new Vector3(1, Mathf.Lerp(0, 1, t), 1);
        entity.SetProperty(PROP_DISPLAY_SCALE_MULTIPLIER, scaleMulti);
    }
    public override function PostContactGround(entity:Entity, velocity:Vector3):Void
    {
        super.PostContactGround(entity, velocity);
        var position = entity.Position;
        position.y = entity.Level.GetGroundY(position.x, position.y);
        if (!entity.Level.IsAirAt(position.x, position.z) && !entity.Level.IsWaterAt(position.x, position.z))
        {
            WaterStain.UpdateStain(entity.Level, position, entity);
        }
        entity.Remove();
    }
    public static inline var MAX_STRETCH_VELOCITY:Float = 10;
    public static var PROP_DISPLAY_SCALE_MULTIPLIER:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("scale_multiplier");
}
