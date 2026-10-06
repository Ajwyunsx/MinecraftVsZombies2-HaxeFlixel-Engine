// Ported from: Assets/Scripts/Logic/Game/IGlobalLocalization.cs
package mvz2logic.games;

import haxe.Int64;

interface IGlobalLocalization
{
	function GetAllLanguageCodes():Array<String>;
	function GetCurrentLanguage():String;
	function GetLanguageName(code:String):String;
	// PORT-NOTE: C# 的 `params object[] args` 在 Haxe 中用可选数组参数表示（调用处需写成 [a, b]）。
	function GetText(textKey:String, ?args:Array<Dynamic>):String;
	function GetTextParticular(textKey:String, context:String, ?args:Array<Dynamic>):String;
	function GetTextPlural(textKey:String, textPlural:String, n:Int64, ?args:Array<Dynamic>):String;
	function GetTextPluralParticular(textKey:String, textPlural:String, n:Int64, context:String, ?args:Array<Dynamic>):String;
}
