// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/StopParticlesWithoutParentBehaviour.cs
package mvz2.gamecontent.entities;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.stopParticlesWithoutParent)
class StopParticlesWithoutParentBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.SetModelProperty("ParticleStopped", !entity.Parent.ExistsAndAlive());
    }
}
