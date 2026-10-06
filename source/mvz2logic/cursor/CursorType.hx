// Ported from: Assets/Scripts/Logic/Cursor/CursorSource.cs
// PORT-NOTE: CursorType 与 CursorSource 同文件；旧式引用 `mvz2logic.cursor.CursorSource.CursorType` 与
// `mvz2logic.cursor.CursorType` 在 Haxe 中无法同时满足（子类型会占用包级名称且与独立模块冲突），
// 这里采用独立模块，同包引用时用 `import mvz2logic.cursor.CursorType;`。
package mvz2logic.cursor;

enum abstract CursorType(Int)
{
	var Arrow = 0;
	var Point = 1;
	var Drag = 2;
	var Move = 3;
	var Empty = 4;
}
