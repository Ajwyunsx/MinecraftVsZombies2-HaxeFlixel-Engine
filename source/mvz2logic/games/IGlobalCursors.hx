// Ported from: Assets/Scripts/Logic/Game/IGlobalCursors.cs
package mvz2logic.games;

import mvz2logic.cursor.CursorSource;

interface IGlobalCursors
{
	function AddCursorSource(source:CursorSource):Void;
	function RemoveCursorSource(source:CursorSource):Bool;
}
