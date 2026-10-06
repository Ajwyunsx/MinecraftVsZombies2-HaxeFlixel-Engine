// Ported from: Assets/Scripts/Logic/HeldItems/IHeldTwinkleEntityBehaviour.cs
package mvz2logic.helditems;

import pvzengine.entities.Entity;

interface IHeldTwinkleEntityBehaviour
{
	function ShouldMakeEntityTwinkle(entity:Entity, data:IHeldItemData):Bool;
}
