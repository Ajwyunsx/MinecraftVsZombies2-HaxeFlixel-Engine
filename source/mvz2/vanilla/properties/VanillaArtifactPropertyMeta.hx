// Ported from: Assets/Scripts/Vanilla/Frameworks/Properties/VanillaArtifactPropertyMeta.cs
package mvz2.vanilla.properties;

import pvzengine.PropertyMeta;

class VanillaArtifactPropertyMeta<T> extends PropertyMeta<T>
{
    public function new(name:String, ?defaultValue:T, ?obsoleteNames:Array<String>)
    {
        super(name, defaultValue, obsoleteNames);
    }
}
