// Ported from: Assets/Scripts/View/Widgets/Faders/ColorFader.cs
package mvz2.ui;

import unity.Color;

class ColorFader extends Fader<Color>
{
	override function LerpValue(start:Color, end:Color, t:Float):Color
	{
		return Color.Lerp(start, end, t);
	}
}
