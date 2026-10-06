// Ported from: Assets/Scripts/Logic/Placements/IEntityTwinklePlaceMethod.cs
// PORT-NOTE: 原文 namespace 为 MVZ2Logic.HeldItems（虽然文件位于 Placements 目录），因此目标包为 mvz2logic.helditems。
package mvz2logic.helditems;

import pvzengine.entities.Entity;
import pvzengine.entities.EntityDefinition;
import pvzengine.placements.PlacementDefinition;

interface IEntityTwinklePlaceMethod
{
	function ShouldMakeEntityTwinkle(placement:PlacementDefinition, entity:Entity, toPlace:EntityDefinition):Bool;
}
