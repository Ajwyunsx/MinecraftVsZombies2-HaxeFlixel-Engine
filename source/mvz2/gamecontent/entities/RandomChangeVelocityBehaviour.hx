// Ported from: Assets/Scripts/Vanilla/GameContent/Entities/Behaviours/RandomChangeVelocityBehaviour.cs
package mvz2.gamecontent.entities;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import unity.Vector3;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.randomChangeVelocity)
class RandomChangeVelocityBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var accelerationMax = entity.GetProperty(PROP_ACCELERATION_MAX);
        var accelerationMin = entity.GetProperty(PROP_ACCELERATION_MIN);
        var rng = entity.RNG;
        var x = rng.NextFloat() * (accelerationMax.x - accelerationMin.x) + accelerationMin.x;
        var y = rng.NextFloat() * (accelerationMax.y - accelerationMin.y) + accelerationMin.y;
        var z = rng.NextFloat() * (accelerationMax.z - accelerationMin.z) + accelerationMin.z;
        var acceleration = entity.GetProperty(PROP_ACCELERATION);
        acceleration += new Vector3(x, y, z);
        entity.SetProperty(PROP_ACCELERATION, acceleration);

        entity.Velocity += acceleration;
    }
    public static var PROP_ACCELERATION:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("acceleration");
    public static var PROP_ACCELERATION_MAX:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("acceleration_max", Vector3.one * 0.01);
    public static var PROP_ACCELERATION_MIN:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("acceleration_min", Vector3.one * -0.01);
}
