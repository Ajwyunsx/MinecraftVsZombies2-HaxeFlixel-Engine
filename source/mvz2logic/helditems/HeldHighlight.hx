// Ported from: Assets/Scripts/Logic/HeldItems/HeldHighlight.cs
package mvz2logic.helditems;

import pvzengine.entities.Entity;
import pvzengine.grids.LawnGrid;

// PORT-NOTE: C# struct 改为普通类（PORTING.md: struct → class）。
class HeldHighlight
{
	public function new(mode:HeldHighlightMode = HeldHighlightMode.None, ?entity:Entity, ?grids:Array<HeldHighlightGrid>)
	{
		this.mode = mode;
		this.entity = entity;
		this.grids = grids;
	}

	public static var None:HeldHighlight = new HeldHighlight(HeldHighlightMode.None);

	public static function Entity(entity:Entity):HeldHighlight // TODO-PORT: 与 HeldHighlightMode.Entity 同名的静态工厂方法，保留原名
	{
		return new HeldHighlight(HeldHighlightMode.Entity, entity);
	}
	public static function Green(grid:LawnGrid, start:Float = 0, end:Float = 1):HeldHighlight
	{
		return new HeldHighlight(HeldHighlightMode.Grid, null, [HeldHighlightGrid.Green(grid, start, end)]);
	}
	public static function Red(grid:LawnGrid):HeldHighlight
	{
		return new HeldHighlight(HeldHighlightMode.Grid, null, [HeldHighlightGrid.Red(grid)]);
	}
	// TODO-PORT: C# 重载 Green(IEnumerable<LawnGrid> grids, float start, float end)，Haxe 不支持重载，重命名为 GreenMultiple
	public static function GreenMultiple(grids:Iterable<LawnGrid>, start:Float = 0, end:Float = 1):HeldHighlight
	{
		return new HeldHighlight(HeldHighlightMode.Grid, null, [for (g in grids) HeldHighlightGrid.Green(g, start, end)]);
	}
	// TODO-PORT: C# 重载 Red(IEnumerable<LawnGrid> grids)，Haxe 不支持重载，重命名为 RedMultiple
	public static function RedMultiple(grids:Iterable<LawnGrid>):HeldHighlight
	{
		return new HeldHighlight(HeldHighlightMode.Grid, null, [for (g in grids) HeldHighlightGrid.Red(g)]);
	}

	public var mode:HeldHighlightMode;
	public var entity:Entity;
	public var grids:Array<HeldHighlightGrid>;
}
