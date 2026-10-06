// Ported from: Assets/Scripts/View/Widgets/Tooltip/ITooltipAnchor.cs
package mvz2.ui;

import unity.Vector2;
import unity.Vector3;

interface ITooltipAnchor
{
	var Position(get, never):Vector3;
	var IsDisabled(get, never):Bool;
	var Pivot(get, never):Vector2;
}
