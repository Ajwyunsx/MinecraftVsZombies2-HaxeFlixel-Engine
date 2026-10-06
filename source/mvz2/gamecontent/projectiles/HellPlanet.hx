// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter5/HellPlanet.cs
package mvz2.gamecontent.projectiles;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.projectiles.VanillaProjectileProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Quaternion;
import unity.Vector3;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.hellPlanet)
class HellPlanet extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.DISPLAY_SCALE, NumberOperator.Multiply, PROP_SCALE));
        AddModifier(new Vector3Modifier(EngineEntityProps.SCALE, NumberOperator.Multiply, PROP_SCALE));
        AddModifier(new BooleanModifier(VanillaProjectileProps.NO_DESTROY_OUTSIDE_LAWN, PROP_NO_DESTROY_OUTSIDE_LAWN));
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var scaleMultiplier = GetScaleMultiplier(entity);
        scaleMultiplier = scaleMultiplier * 0.9 + Vector3.one * 0.1;
        SetScaleMultiplier(entity, scaleMultiplier);

        var orbitAngle = GetOrbitAngle(entity);
        orbitAngle += GetOrbitSpeed(entity);
        SetOrbitAngle(entity, orbitAngle);


        var parent = entity.Parent;
        if (parent.ExistsAndAlive())
        {
            var orbitDistance = GetOrbitDistance(entity);
            var targetOffset = Quaternion.Euler(0, orbitAngle, 0) * (Vector3.right * orbitDistance);
            var targetPosition = parent.GetCenter() + targetOffset;
            entity.Velocity = (targetPosition - entity.GetCenter());
        }
        SetNoDestroyOutsideLawn(entity, entity.GetChildren().length > 0);
    }

    public static function NoDestroyOutsideLawn(entity:Entity):Bool return entity.GetBehaviourField(PROP_NO_DESTROY_OUTSIDE_LAWN);
    public static function SetNoDestroyOutsideLawn(entity:Entity, value:Bool):Void entity.SetBehaviourField(PROP_NO_DESTROY_OUTSIDE_LAWN, value);
    public static function GetOrbitAngle(entity:Entity):Float return entity.GetBehaviourField(PROP_ORBIT_ANGLE);
    public static function SetOrbitAngle(entity:Entity, value:Float):Void entity.SetBehaviourField(PROP_ORBIT_ANGLE, value);
    public static function GetOrbitSpeed(entity:Entity):Float return entity.GetBehaviourField(PROP_ORBIT_SPEED);
    public static function SetOrbitSpeed(entity:Entity, value:Float):Void entity.SetBehaviourField(PROP_ORBIT_SPEED, value);
    public static function GetOrbitDistance(entity:Entity):Float return entity.GetBehaviourField(PROP_ORBIT_DISTANCE);
    public static function SetOrbitDistance(entity:Entity, value:Float):Void entity.SetBehaviourField(PROP_ORBIT_DISTANCE, value);
    public static function GetScaleMultiplier(entity:Entity):Vector3 return entity.GetBehaviourField(PROP_SCALE);
    public static function SetScaleMultiplier(entity:Entity, value:Vector3):Void entity.SetBehaviourField(PROP_SCALE, value);
    public static var PROP_NO_DESTROY_OUTSIDE_LAWN:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("no_destroy_outside_lawn");
    public static var PROP_ORBIT_ANGLE:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("orbit_angle");
    public static var PROP_ORBIT_SPEED:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("orbit_speed");
    public static var PROP_ORBIT_DISTANCE:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("orbit_distance");
    public static var PROP_SCALE:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("scale");
}
