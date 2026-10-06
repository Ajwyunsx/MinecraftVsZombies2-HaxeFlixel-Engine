// Ported from: Assets/Scripts/Logic/HeldItems/HeldHighlight.cs (enum HeldHighlightMode)
// PORT-NOTE: 原文件包含多个顶层类型，按 Haxe 模块规则拆分为独立模块，便于以 `import mvz2logic.helditems.X;` 引用。
package mvz2logic.helditems;

enum abstract HeldHighlightMode(Int)
{
	var None = 0;
	var Entity = 1;
	var Grid = 2;
}
