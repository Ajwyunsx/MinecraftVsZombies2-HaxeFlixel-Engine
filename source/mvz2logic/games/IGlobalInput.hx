// Ported from: Assets/Scripts/Logic/Game/IGlobalInput.cs
package mvz2logic.games;

import tools.Ref;
import unity.Vector2;

interface IGlobalInput
{
	function GetPointerScreenPosition():Vector2;
	// TODO-PORT: C# 重载 GetPointerScreenPosition(int type, int button)，Haxe 不支持重载，重命名为 GetPointerScreenPositionByType
	function GetPointerScreenPositionByType(type:Int, button:Int):Vector2;
	function TryGetPointerScreenPosition(screenPosition:Ref<Vector2>):Bool;
	// TODO-PORT: C# 重载 TryGetPointerScreenPosition(int type, int button, out Vector2)，Haxe 不支持重载，重命名为 TryGetPointerScreenPositionByType
	function TryGetPointerScreenPositionByType(type:Int, button:Int, screenPosition:Ref<Vector2>):Bool;
	function IsPointerDown(type:Int, button:Int):Bool;
	function IsPointerHolding(type:Int, button:Int):Bool;
	function IsPointerUp(type:Int, button:Int):Bool;
	function GetActivePointerType():Int;
}
