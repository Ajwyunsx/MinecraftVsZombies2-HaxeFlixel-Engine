// Ported from: Assets/Scripts/Engine/Level/Modifiers/BlendModifiers/BlendOperator.cs
package pvzengine.modifiers;

enum abstract BlendOperator(Int)
{
	var One = 0;
	var Zero = 1;
	var SrcAlpha = 2;
	var DstAlpha = 3;
	var OneMinusSrcAlpha = 4;
	var OneMinusDstAlpha = 5;
	var SrcColor = 6;
	var DstColor = 7;
	var OneMinusSrcColor = 8;
	var OneMinusDstColor = 9;
}
