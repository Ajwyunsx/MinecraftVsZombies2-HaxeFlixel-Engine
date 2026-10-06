// Ported from: Assets/Scripts/Logic/Game/IGlobalMusic.cs
package mvz2logic.games;

interface IGlobalMusic
{
	function StartFade(target:Float, duration:Float):Void;
	function SetVolume(volume:Float):Void;
	function Stop():Void;
}
