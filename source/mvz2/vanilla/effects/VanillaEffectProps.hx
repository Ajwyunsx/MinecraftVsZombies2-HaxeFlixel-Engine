// Ported from: Assets/Scripts/Vanilla/Frameworks/Effects/VanillaEffectProps.cs
package mvz2.vanilla.effects;

import pvzengine.PropertyMeta;
import pvzengine.PropertyRegions;

@:propertyRegistryRegion(PropertyRegions.entity)
class VanillaEffectProps
{
    public static var DECORATIVE:PropertyMeta<Bool> = new PropertyMeta<Bool>("decorative");
}
