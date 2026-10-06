// Ported from: Assets/Scripts/Vanilla/Frameworks/Definitions/DefinitionAttributes.cs
package mvz2.vanilla.definitions;

import pvzengine.DefinitionAttribute;

class RandomChinaEventDefinitionAttribute extends DefinitionAttribute
{
    public function new(name:String)
    {
        super(name, VanillaDefinitionTypes.RANDOM_CHINA_EVENT);
    }
}
