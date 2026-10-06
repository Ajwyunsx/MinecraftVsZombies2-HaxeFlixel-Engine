// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter6/ZombieCat_ModelBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.zombieCat_Model)
class ZombieCat_ModelBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.SetModelProperty("ReviveTimes", EnemySelfRevivalBehaviour.GetReviveTimes(entity));
    }
}
