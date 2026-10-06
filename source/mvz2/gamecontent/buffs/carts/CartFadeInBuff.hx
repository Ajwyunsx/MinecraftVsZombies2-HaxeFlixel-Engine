// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Carts/Prologue/CartFadeInBuff.cs
package mvz2.gamecontent.buffs.carts;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.level.LevelPositions;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.ColorModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import unity.Color;
import unity.Mathf;

@:autoBuffDefinition(VanillaBuffNames.Cart_cartFadeIn)
class CartFadeInBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(EngineEntityProps.TINT, PROP_COLOR_MULTIPLIER));
        AddModifier(ColorModifier.Multiply(LogicEntityProps.LIGHT_COLOR, PROP_COLOR_MULTIPLIER));
        AddModifier(new FloatModifier(LogicEntityProps.SHADOW_ALPHA, NumberOperator.Multiply, PROP_ALPHA_MULTIPLIER));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        UpdateColor(buff);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        UpdateColor(buff);
    }
    function UpdateColor(buff:Buff):Void
    {
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        var alpha = Mathf.Lerp(0, 1, (entity.Position.x - LevelPositions.CART_START_X) / (LevelPositions.CART_TARGET_X - LevelPositions.CART_START_X));
        buff.SetProperty(PROP_COLOR_MULTIPLIER, new Color(1, 1, 1, alpha));
        buff.SetProperty(PROP_ALPHA_MULTIPLIER, alpha);
    }
    public static var PROP_COLOR_MULTIPLIER:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("ColorMultiplier");
    public static var PROP_ALPHA_MULTIPLIER:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("AlphaMultiplier");
}
