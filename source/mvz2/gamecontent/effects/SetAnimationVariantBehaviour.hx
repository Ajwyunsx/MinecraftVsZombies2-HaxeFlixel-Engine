// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Common/SetAnimationVariantBehaviour.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2logic.entities.LogicEntityProps;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.setAnimationVariant)
class SetAnimationVariantBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.SetAnimationInt("Variant", entity.GetVariant());
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.SetAnimationInt("Variant", entity.GetVariant());
    }
}
