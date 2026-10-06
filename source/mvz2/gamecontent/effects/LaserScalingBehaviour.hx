// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter6/LaserScalingBehaviour.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.detections.CollisionDetector;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.EngineEntityProps;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.effectLaserScaling)
class LaserScalingBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.DISPLAY_SCALE, NumberOperator.Multiply, PROP_SCALE_MULTIPLIER));
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var multi = new Vector3(1, entity.Timeout / entity.GetMaxTimeout(), 1);
        entity.SetProperty(PROP_SCALE_MULTIPLIER, multi);
    }
    public static inline var GLOWING_DURATION_SECONDS:Float = 30;
    public static var laserDetector:Detector = new CollisionDetector(true);
    public var detectBuffer:Array<Entity> = [];
    public static var PROP_SCALE_MULTIPLIER:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("scale_multiplier", Vector3.zero);
}
