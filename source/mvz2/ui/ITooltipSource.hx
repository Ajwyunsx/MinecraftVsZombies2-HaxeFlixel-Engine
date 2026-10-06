// Ported from: Assets/Scripts/View/Widgets/Tooltip/ITooltipSource.cs
package mvz2.ui;

import unity.Camera;
import mvz2.ui.Tooltip;
import mvz2.ui.Tooltip.TooltipContent;

interface ITooltipSource
{
	function GetCamera():Camera;
	function GetTarget():ITooltipTarget;
	function GetContent():TooltipContent;
}
