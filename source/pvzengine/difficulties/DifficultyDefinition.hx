// Ported from: Assets/Scripts/Engine/Level/Difficulties/DifficultyDefinition.cs
package pvzengine.difficulties;

import pvzengine.base.Definition;
import pvzengine.definitions.EngineDefinitionTypes;

class DifficultyDefinition extends Definition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    // C#: public sealed override string GetDefinitionType()
    public override function GetDefinitionType():String return EngineDefinitionTypes.DIFFICULTY;
}
