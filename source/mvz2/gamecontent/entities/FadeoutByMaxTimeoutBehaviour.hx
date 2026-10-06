// Ported from: Assets/Scripts/Vanilla/GameContent/Entities/Behaviours/FadeoutByMaxTimeoutBehaviour.cs
package mvz2.gamecontent.entities;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.ColorModifier;
import unity.Color;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.fadeoutByMaxTimeout)
class FadeoutByMaxTimeoutBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(EngineEntityProps.TINT, PROP_TINT_MULTIPLIER));
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var alpha:Float;
        var alphaMax = entity.GetProperty(PROP_ALPHA_MAX);
        if (entity.Timeout < 0)
        {
            alpha = alphaMax;
        }
        else
        {
            var alphaMin = entity.GetProperty(PROP_ALPHA_MIN);
            var t = entity.Timeout / entity.GetMaxTimeout();
            t = t * (alphaMax - alphaMin) + alphaMin;
            alpha = Mathf.Clamp01(t);
        }
        entity.SetProperty(PROP_TINT_MULTIPLIER, new Color(1, 1, 1, alpha));
    }
    public static var PROP_TINT_MULTIPLIER:VanillaEntityPropertyMeta<Color> = new VanillaEntityPropertyMeta<Color>("tint_multiplier", Color.white);
    public static var PROP_ALPHA_MAX:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("alpha_max", 1);
    public static var PROP_ALPHA_MIN:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("alpha_min", 0);
}
