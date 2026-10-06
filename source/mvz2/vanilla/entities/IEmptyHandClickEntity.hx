// Ported from: Assets/Scripts/Vanilla/Frameworks/Contraptions/IEmptyHandClickEntity.cs
package mvz2.vanilla.entities;

import mvz2logic.inputs.PointerInteractionData;
import pvzengine.entities.Entity;

interface IEmptyHandClickEntity
{
    function IsValidPointerInteraction(entity:Entity, interaction:PointerInteractionData):Bool;
    function CanEmptyHandClick(entity:Entity):Bool;
    function EmptyHandClick(entity:Entity):Void;
}
