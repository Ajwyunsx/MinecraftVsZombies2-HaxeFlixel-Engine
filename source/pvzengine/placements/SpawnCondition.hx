// Ported from: Assets/Scripts/Engine/Level/Placements/SpawnCondition.cs
package pvzengine.placements;

import pvzengine.NamespaceID;
import pvzengine.entities.EntityDefinition;
import pvzengine.grids.LawnGrid;

// PORT-NOTE: C# 为 `abstract class SpawnCondition`，按 PORTING.md「抽象类仍写 class」改为普通 class，
//   抽象方法以 throw "abstract" 占位。
class SpawnCondition
{
	// C#: public abstract NamespaceID? GetSpawnError(PlacementDefinition placement, LawnGrid grid, EntityDefinition entity);
	public function GetSpawnError(placement:PlacementDefinition, grid:LawnGrid, entity:EntityDefinition):Null<NamespaceID>
	{
		throw "abstract";
	}
}
