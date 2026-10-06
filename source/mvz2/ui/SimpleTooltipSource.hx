// Ported from: Assets/Scripts/View/Widgets/Tooltip/SimpleTooltipSource.cs
package mvz2.ui;

import unity.Camera;
import mvz2.ui.Tooltip;
import mvz2.ui.Tooltip.TooltipContent;

class SimpleTooltipSource implements ITooltipSource
{
	public function new(camera:Camera, target:ITooltipTarget, viewData:TooltipContent)
	{
		this.camera = camera;
		this.target = target;
		this.viewData = viewData;
	}
	public function GetCamera():Camera return camera;
	public function GetTarget():ITooltipTarget return target;
	public function GetContent():TooltipContent return viewData;
	private var camera:Camera;
	private var target:ITooltipTarget;
	private var viewData:TooltipContent;
}
