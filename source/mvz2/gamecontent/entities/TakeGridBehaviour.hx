// Ported from: Assets/Scripts/Vanilla/GameContent/Entities/Behaviours/TakeGridBehaviour.cs
package mvz2.gamecontent.entities;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.takeGrid)
class TakeGridBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        VanillaEntityExt.UpdateTakenGrids(entity);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        VanillaEntityExt.UpdateTakenGrids(entity);
    }
    public override function PostRemove(entity:Entity):Void
    {
        super.PostRemove(entity);
        entity.ClearTakenGrids();
    }
}
