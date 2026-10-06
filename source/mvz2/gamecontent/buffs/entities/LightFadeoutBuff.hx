// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Chapter1/LightFadeoutBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.ColorModifier;
import unity.Color;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoBuffDefinition(VanillaBuffNames.Entity_lightFadeout)
class LightFadeoutBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(ColorModifier.Multiply(LogicEntityProps.LIGHT_COLOR, PROP_COLOR_MULTIPLIER));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        UpdateMultiplier(buff);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        UpdateMultiplier(buff);
    }
    private function UpdateMultiplier(buff:Buff):Void
    {
        var entity = buff.GetEntity();
        if (entity == null)
            return;
        var speedMultiplier = buff.GetProperty(PROP_SPEED_MULTIPLIER);
        var remainPercentage = entity.Timeout / entity.GetMaxTimeout();
        var alpha = Mathf.Clamp01(1 - (1 - remainPercentage) * speedMultiplier);
        var color = new Color(1, 1, 1, alpha);
        buff.SetProperty(PROP_COLOR_MULTIPLIER, color);
    }
    public static var PROP_COLOR_MULTIPLIER:VanillaBuffPropertyMeta<Color> = new VanillaBuffPropertyMeta<Color>("ColorMultiplier");
    public static var PROP_SPEED_MULTIPLIER:VanillaBuffPropertyMeta<Float> = new VanillaBuffPropertyMeta<Float>("speed_multiplier", 1);
}
