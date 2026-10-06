// Ported from: Assets/Scripts/Logic/HeldItems/HeldHighlight.cs (struct HeldHighlightGrid)
// PORT-NOTE: C# struct 改为普通类（PORTING.md: struct → class）。
package mvz2logic.helditems;

import pvzengine.grids.LawnGrid;

class HeldHighlightGrid
{
	public function new(grid:LawnGrid = null, valid:Bool = false, rangeStart:Float = 0, rangeEnd:Float = 1)
	{
		this.grid = grid;
		this.valid = valid;
		this.rangeStart = rangeStart;
		this.rangeEnd = rangeEnd;
	}
	public static function Green(grid:LawnGrid, start:Float = 0, end:Float = 1):HeldHighlightGrid
	{
		return new HeldHighlightGrid(grid, true, start, end);
	}
	public static function Red(grid:LawnGrid):HeldHighlightGrid
	{
		return new HeldHighlightGrid(grid, false, 0, 1);
	}

	public var grid:LawnGrid;
	public var valid:Bool;
	public var rangeStart:Float;
	public var rangeEnd:Float;
}
