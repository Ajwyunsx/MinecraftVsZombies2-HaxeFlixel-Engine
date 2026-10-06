// Ported from: Assets/Scripts/Vanilla/GameContent/Entities/Behaviours/TimeoutRemoveBehaviour.cs
package mvz2.gamecontent.entities;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.timeoutRemove)
class TimeoutRemoveBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.Timeout = VanillaEntityProps.GetMaxTimeout(entity);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (entity.Timeout >= 0)
        {
            entity.Timeout--;
            if (entity.Timeout <= 0)
            {
                entity.Remove();
            }
        }
    }
}
