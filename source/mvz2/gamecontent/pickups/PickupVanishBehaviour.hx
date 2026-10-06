// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/Behaviours/PickupVanishBehaviour.cs
package mvz2.gamecontent.pickups;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.pickups.VanillaPickupExt;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.ColorModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import unity.Color;
import unity.Vector3;
using mvz2.vanilla.pickups.VanillaPickupExt;
using mvz2.vanilla.pickups.VanillaPickupProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.pickupVanish)
class PickupVanishBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(EngineEntityProps.TINT, PROP_TINT_MULT));
        AddModifier(new FloatModifier(LogicEntityProps.SHADOW_ALPHA, NumberOperator.Multiply, PROP_SHADOW_ALPHA));
    }
    public override function Update(pickup:Entity):Void
    {
        super.Update(pickup);
        var level = pickup.Level;
        var alpha:Float = 1;
        var shadowAlpha:Float = 1;
        if (!pickup.IsCollected() && !pickup.IsImportantPickup() && pickup.Timeout < 15 && pickup.Timeout >= 0)
        {
            pickup.Velocity = Vector3.zero;
            alpha = pickup.Timeout / 15;
            shadowAlpha = alpha;
        }
        var color = GetTintMultiplier(pickup);
        color.a = alpha;
        SetTintMultiplier(pickup, color);
        SetShadowAlpha(pickup, shadowAlpha);
    }
    public static function GetTintMultiplier(entity:Entity):Color return entity.GetBehaviourField(PROP_TINT_MULT);
    public static function SetTintMultiplier(entity:Entity, value:Color):Void entity.SetBehaviourField(PROP_TINT_MULT, value);
    public static function GetShadowAlpha(entity:Entity):Float return entity.GetBehaviourField(PROP_SHADOW_ALPHA);
    public static function SetShadowAlpha(entity:Entity, value:Float):Void entity.SetBehaviourField(PROP_SHADOW_ALPHA, value);
    private static var PROP_TINT_MULT:VanillaEntityPropertyMeta<Color> = new VanillaEntityPropertyMeta<Color>("tint_mult", Color.white);
    private static var PROP_SHADOW_ALPHA:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("shadow_alpha", 1);
}
