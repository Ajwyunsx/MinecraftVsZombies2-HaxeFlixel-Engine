// Ported from: Assets/Scripts/Vanilla/GameContent/Entities/Behaviours/AIEntityBehaviour.cs
package mvz2.gamecontent.entities;

import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

// PORT-NOTE: C# abstract class → Haxe class（PORTING.md §abstract）。
class AIEntityBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (!VanillaEntityProps.IsAIFrozen(entity))
        {
            UpdateAI(entity);
        }
        UpdateLogic(entity);
    }
    function UpdateLogic(entity:Entity):Void
    {
    }
    function UpdateAI(entity:Entity):Void
    {
    }
}
