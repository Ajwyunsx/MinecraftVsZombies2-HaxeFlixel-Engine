// Ported from: Assets/Scripts/Vanilla/GameContent/Entities/Behaviours/RemoveWithoutParentBehaviour.cs
package mvz2.gamecontent.entities;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.removeWithoutParent)
class RemoveWithoutParentBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (!entity.Parent.ExistsAndAlive())
        {
            entity.Remove();
        }
    }
}
