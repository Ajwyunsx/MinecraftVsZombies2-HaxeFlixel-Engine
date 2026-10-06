// Ported from: Assets/Scripts/Vanilla/GameContent/Obstacles/ObstacleDestroyContraptionBehaviour.cs
package mvz2.gamecontent.obstacles;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.obstacleDestroyContraption)
class ObstacleDestroyContraptionBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        VanillaEntityExt.DestroyConflictGridEntities(entity);
    }
}
