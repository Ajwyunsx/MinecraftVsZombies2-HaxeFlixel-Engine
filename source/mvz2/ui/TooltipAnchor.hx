// Ported from: Assets/Scripts/View/Widgets/Tooltip/TooltipAnchor.cs
package mvz2.ui;

import unity.Vector2;
import unity.Vector3;
import unity.MonoBehaviour;
import unity.UnityObject;

class TooltipAnchor extends unity.MonoBehaviour implements ITooltipAnchor
{
	public var IsDisabled(get, never):Bool;
	function get_IsDisabled():Bool return !unity.UnityObject.exists(this) || disabled || !enabled;
	public var Pivot(get, never):Vector2;
	function get_Pivot():Vector2 return pivot;
	public var Position(get, never):Vector3;
	function get_Position():Vector3 return transform.position;
	@:serializeField
	private var disabled:Bool = false;
	@:serializeField
	private var pivot:Vector2 = new Vector2(0.5, 0.5);
}
