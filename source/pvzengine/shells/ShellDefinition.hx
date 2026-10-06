// Ported from: Assets/Scripts/Engine/Level/Shells/ShellDefinition.cs
package pvzengine.shells;

import pvzengine.base.Definition;
import pvzengine.damages.DamageInput;
import pvzengine.definitions.EngineDefinitionTypes;

// C# 为 abstract class
class ShellDefinition extends Definition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    // C#: public virtual void EvaluateDamage(DamageInput damageInfo)
    public function EvaluateDamage(damageInfo:DamageInput):Void
    {
    }
    // C#: public sealed override string GetDefinitionType()
    public override function GetDefinitionType():String return EngineDefinitionTypes.SHELL;
}
