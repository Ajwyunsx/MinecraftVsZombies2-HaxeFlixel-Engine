// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter6/NukeFlash.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.modifiers.ColorModifier;
import unity.Color;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaEffectNames.nukeFlash)
class NukeFlash extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new ColorModifier(EngineEntityProps.COLOR_OFFSET, PROP_COLOR_OFFSET));
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var timeout = entity.Timeout / entity.GetMaxTimeout();
        var colorOffset = new Color(1, 1, 1, timeout);
        entity.SetProperty(PROP_COLOR_OFFSET, colorOffset);
    }
    public static var PROP_COLOR_OFFSET:VanillaEntityPropertyMeta<Color> = new VanillaEntityPropertyMeta<Color>("color_offset", Color.white);
}
