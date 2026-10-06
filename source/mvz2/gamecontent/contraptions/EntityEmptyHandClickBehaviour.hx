// Ported from: Assets/Scripts/Vanilla/GameContent/Entities/EntityEmptyHandClickBehaviour.cs
package mvz2.gamecontent.contraptions;

import mvz2.vanilla.entities.IEmptyHandClickEntity;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.inputs.PointerHelper;
import mvz2logic.inputs.PointerInteractionData;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;

// PORT-NOTE: C# abstract class → Haxe class；abstract 方法 EmptyHandClick → throw "abstract"（PORTING.md §abstract）。
class EntityEmptyHandClickBehaviour extends EntityBehaviourDefinition implements IEmptyHandClickEntity
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public function IsValidPointerInteraction(entity:Entity, interaction:PointerInteractionData):Bool
    {
        return !PointerHelper.IsInvalidReleaseAction(interaction);
    }
    public function CanEmptyHandClick(entity:Entity):Bool
    {
        return !VanillaEntityProps.IsAIFrozen(entity) && LogicEntityExt.IsFriendlyEntity(entity);
    }

    public function EmptyHandClick(entity:Entity):Void throw "abstract";
}
