// Ported from: Assets/Scripts/Vanilla/Frameworks/Properties/VanillaEntityPropertyMeta.cs
package mvz2.vanilla.properties;

import pvzengine.PropertyMeta;

class VanillaEntityPropertyMeta<T> extends PropertyMeta<T>
{
    public function new(name:String, ?defaultValue:T, ?obsoleteNames:Array<String>)
    {
        super(name, defaultValue, obsoleteNames);
    }
}
