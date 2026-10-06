// Ported from: Assets/Scripts/View/Widgets/Tooltip/ITooltipTarget.cs
package mvz2.ui;

import flixel.addons.ui.Anchor;
interface ITooltipTarget
{
	var Anchor(get, never):Null<ITooltipAnchor>;
}
