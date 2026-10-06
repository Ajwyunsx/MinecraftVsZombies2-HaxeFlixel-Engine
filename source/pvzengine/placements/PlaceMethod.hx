// Ported from: Assets/Scripts/Engine/Level/Placements/PlaceMethod.cs
// PORT-NOTE: C# 的 PlaceMethod.cs 同时定义了 abstract class PlaceMethod 与 class PlaceOutput。
//   Haxe 只按「模块路径 == 主类型名」解析 import，而既有上层代码分别以
//   `import pvzengine.placements.PlaceOutput;`（7 处）与 `import pvzengine.placements.PlaceMethod;`（6 处）
//   引用二者，故 PlaceOutput 拆到独立模块 PlaceOutput.hx（与 pvzengine/PropertyKey.hx 的拆分方式一致）。
package pvzengine.placements;

import pvzengine.NamespaceID;
import pvzengine.entities.EntityDefinition;
import pvzengine.grids.LawnGrid;

// PORT-NOTE: C# 为 `abstract class PlaceMethod`，按 PORTING.md「抽象类仍写 class」改为普通 class，
//   抽象方法以 throw "abstract" 占位。
class PlaceMethod
{
	// C#: public abstract NamespaceID? GetPlaceError(PlacementDefinition placement, LawnGrid grid, EntityDefinition entityDef);
	public function GetPlaceError(placement:PlacementDefinition, grid:LawnGrid, entityDef:EntityDefinition):Null<NamespaceID>
	{
		throw "abstract";
	}
	// C#: public abstract PlaceOutput PlaceEntity(PlacementDefinition placement, LawnGrid grid, EntityDefinition entityDef, PlaceParams param);
	public function PlaceEntity(placement:PlacementDefinition, grid:LawnGrid, entityDef:EntityDefinition, param:PlaceParams):PlaceOutput
	{
		throw "abstract";
	}
}
