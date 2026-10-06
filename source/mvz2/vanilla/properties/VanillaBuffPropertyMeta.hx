// Ported from: Assets/Scripts/Vanilla/Frameworks/Properties/VanillaBuffPropertyMeta.cs
package mvz2.vanilla.properties;

import pvzengine.PropertyMeta;

class VanillaBuffPropertyMeta<T> extends PropertyMeta<T>
{
    public function new(name:String, ?defaultValue:T, ?obsoleteNames:Array<String>)
    {
        super(name, defaultValue, obsoleteNames);
    }
}
