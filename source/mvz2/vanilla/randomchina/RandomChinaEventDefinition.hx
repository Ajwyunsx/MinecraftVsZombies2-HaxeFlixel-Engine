// Ported from: Assets/Scripts/Vanilla/Frameworks/RandomChinaEvents/RandomChinaEventDefinition.cs
package mvz2.vanilla.randomchina;

import mvz2.vanilla.definitions.VanillaDefinitionTypes;
import pvzengine.base.Definition;
import pvzengine.entities.Entity;
import tools.RandomGenerator;

class RandomChinaEventDefinition extends Definition
{
    public function new(nsp:String, path:String, name:String, description:String, weight:Float = 1)
    {
        super(nsp, path);
        EventName = name;
        EventDescription = description;
        Weight = weight;
    }
    // abstract
    public function Run(contraption:Entity, rng:RandomGenerator):Void throw "abstract";

    public override function GetDefinitionType():String return VanillaDefinitionTypes.RANDOM_CHINA_EVENT;
    public var EventName:String;
    public var EventDescription:String;
    public var Weight:Float;
}
