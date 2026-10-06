// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/DragonFireBreath.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.contraptions.GridFire;
import mvz2.vanilla.entities.IBeBlownBehaviour;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.modifiers.VanillaModifierPriorities;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.modifiers.ColorModifier;
import unity.Color;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityProps;

@:autoEntityBehaviourDefinition(VanillaEffectNames.dragonFireBreath)
class DragonFireBreath extends EntityBehaviourDefinition implements IBeBlownBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Override(LogicEntityProps.LIGHT_COLOR, PROP_LIGHT_COLOR, VanillaModifierPriorities.EARLY));
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        UpdateVariant(entity);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        UpdateVariant(entity);
        UpdateGridFire(entity);
    }
    public static function GetLightColorByVariant(variant:Int):Color
    {
        switch (variant)
        {
            case VARIANT_RED:
                return Color.red;
            case VARIANT_CYAN:
                return Color.cyan;
            default:
        }
        return defaultLightColor;
    }
    public static function UpdateVariant(entity:Entity):Void
    {
        var variant = entity.GetVariant();
        var lightColor = GetLightColorByVariant(variant);
        entity.SetProperty(PROP_LIGHT_COLOR, lightColor);
    }
    private function UpdateGridFire(entity:Entity):Void
    {
        if (entity.GetRelativeY() > 20) // 距离地面过高
            return;
        var grid = entity.GetGrid();
        if (grid == null)
            return;
        var param = entity.GetSpawnParams();
        param.SetProperty(VanillaEntityProps.DAMAGE, entity.GetDamage());
        GridFire.Spawn(grid, entity, param);
    }
    public function BeBlown(entity:Entity, source:Entity):Void
    {
        var newVelocity = source.GetFacingDirection();
        newVelocity *= entity.Velocity.magnitude;
        entity.Velocity = newVelocity;
    }
    private static var PROP_LIGHT_COLOR:VanillaEntityPropertyMeta<Color> = new VanillaEntityPropertyMeta<Color>("light_color", defaultLightColor);
    public static inline var VARIANT_ORANGE:Int = 0;
    public static inline var VARIANT_RED:Int = 1;
    public static inline var VARIANT_CYAN:Int = 2;
    public static var defaultLightColor:Color = new Color(1, 0.5, 0);
}
