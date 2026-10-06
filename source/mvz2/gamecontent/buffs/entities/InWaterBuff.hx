// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Chapter2/InWaterBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.entities.WaterInteraction;
import mvz2.vanilla.modifiers.VanillaModifierPriorities;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import pvzengine.buffs.Buff;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoBuffDefinition(VanillaBuffNames.Entity_inWater)
class InWaterBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.AddMultiple, PROP_GRAVITY_ADDITION, VanillaModifierPriorities.WATER_GRAVITY));
        AddModifier(new FloatModifier(EngineEntityProps.FRICTION, NumberOperator.Add, 0.15));
        AddModifier(new FloatModifier(EngineEntityProps.GROUND_LIMIT_OFFSET, NumberOperator.Add, -100.0));
        AddModifier(new FloatModifier(VanillaEntityProps.BLOW_MASS_OFFSET, NumberOperator.Add, 1));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        var groundY = entity.GetGroundY();
        var gravityAddition:Float = 0;
        if (entity.Position.y < groundY)
        {
            var willSink = entity.IsDead || entity.GetWaterInteraction() == WaterInteraction.DROWN;

            var height = entity.GetScaledSize().y;
            var thresold = 0.33333;
            var thresoldHeight = thresold * height;
            var sinkPercentage = (groundY - entity.Position.y) / height;

            if (!willSink)
            {
                gravityAddition = Mathf.LerpUnclamped(0, -1, sinkPercentage / thresold);
            }
            else
            {
                if (entity.Position.y <= -thresoldHeight && !entity.IsDead)
                {
                    entity.Die(new DamageEffectList([VanillaDamageEffects.DROWN, VanillaDamageEffects.NO_DEATH_EFFECTS, VanillaDamageEffects.NO_REVIVAL]), entity);
                }
            }
            var verticalFriction = Mathf.Lerp(1, 0.5, sinkPercentage / thresold);

            var velocity = entity.Velocity;
            velocity.y *= verticalFriction;
            entity.Velocity = velocity;
        }
        buff.SetProperty(PROP_GRAVITY_ADDITION, gravityAddition);
    }
    public static var PROP_GRAVITY_ADDITION:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("GravityAddition");
}
