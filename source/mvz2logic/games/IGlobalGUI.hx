// Ported from: Assets/Scripts/Logic/Game/IGlobalGUI.cs
package mvz2logic.games;

interface IGlobalGUI
{
	function ShowDialog(title:String, desc:String, options:Array<String>, ?onSelect:Int->Void):Void;
}
