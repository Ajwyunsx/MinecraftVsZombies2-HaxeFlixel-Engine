// Ported from: Assets/Scripts/MVZ2/Managers/CursorManager.cs
package mvz2.cursors;

import mvz2.managers.MainManager;
import mvz2logic.cursor.CursorSource;
import mvz2logic.cursor.CursorType;
import mvz2logic.games.IGlobalCursors;
import unity.*;
import unity.Debug;

class CursorManager extends MonoBehaviour implements IGlobalCursors
{
	public function AddCursorSource(source:CursorSource):Void
	{
		cursorSources.push(source);
		// PORT-NOTE: C# 依赖 CursorSource : IComparable 的 List.Sort()；Haxe 侧显式给出比较器。
		cursorSources.sort((a, b) -> a.CompareTo(b));
		// PORT-NOTE: C# 的 event Action<bool> 在 Haxe 侧用 Array<Bool->Void> 表达，订阅即 push。
		source.OnEnableChanged.push(OnSourceEnableChangedCallback);
		UpdateCursor();
	}
	public function RemoveCursorSource(source:CursorSource):Bool
	{
		if (cursorSources.remove(source))
		{
			source.OnEnableChanged.remove(OnSourceEnableChangedCallback);
			UpdateCursor();
			return true;
		}
		return false;
	}
	private function OnEnable():Void
	{
		UpdateCursor();
	}
	private function Update():Void
	{
		var mousePosition = Input.mousePosition;
		var outScreen = mousePosition.x <= 0 || mousePosition.y <= 0 || mousePosition.x >= Screen.width || mousePosition.y >= Screen.height;
		var invalidSources = RemoveInvalidCursorSources();
		if (invalidSources > 0 || outScreen != outOfScreen)
		{
			outOfScreen = outScreen;
			UpdateCursor();
		}
	}
	private function OnSourceEnableChangedCallback(value:Bool):Void
	{
		UpdateCursor();
	}
	private function RemoveInvalidCursorSources():Int
	{
		var removed = 0;
		var i = cursorSources.length - 1;
		while (i >= 0)
		{
			var source = cursorSources[i];
			if (!source.IsValid())
			{
				cursorSources.splice(i, 1);
				source.OnEnableChanged.remove(OnSourceEnableChangedCallback);
				removed++;
			}
			i--;
		}
		return removed;
	}
	private function UpdateCursor():Void
	{
		var main = MainManager.Instance;
		// 移动端不要调用Cursor相关内容，可能会崩溃
		if (main == null || main.IsMobile())
			return;

		var cursorType = CursorType.Arrow;
		var enabledSources = cursorSources.filter(s -> s.Enabled);
		if (enabledSources.length > 0)
		{
			cursorType = enabledSources[enabledSources.length - 1].CursorType;
		}

		if (targetCursorType == cursorType)
			return;
		targetCursorType = cursorType;

		if (targetCursorType == CursorType.Empty)
		{
			Cursor.visible = outOfScreen;
		}
		else
		{
			Cursor.visible = true;
			var cursorData = Lambda.find(cursorDatas, d -> d.type == targetCursorType);
			if (cursorData != null)
				// TODO-PORT: C# 传 3 个参数（含 CursorMode.Auto），unity shim 的 Cursor.SetCursor 只保留
				// (cursor, hotspot)，CursorMode 参数缺失；如需恢复请补齐 shim。
				Cursor.SetCursor(cursorData.texture, cursorData.hotspot);
		}
	}
	private var outOfScreen:Bool;
	private var cursorSources:Array<CursorSource> = [];
	@:serializeField
	private var targetCursorType:CursorType = CursorType.Arrow;
	@:serializeField
	private var cursorDatas:Array<CursorData> = [];
}

class CursorData
{
	public var type:CursorType;
	public var texture:Texture2D;
	public var hotspot:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public function new() {}
}
