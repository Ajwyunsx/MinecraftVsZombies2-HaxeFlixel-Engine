// Ported from: Assets/Scripts/Logic/Game/IGlobalScene.cs
package mvz2logic.games;

import pvzengine.NamespaceID;
import unity.Color;
import unity.Coroutine;

interface IGlobalScene
{
	function GotoMapOrMainmenu():Void;
	function GotoMainmenu():Void;
	function GotoMap(mapID:NamespaceID):Void;
	function GotoStore(backAction:Void->Void, showTalks:Bool):Void;
	function GotoLevelCoroutine():Coroutine;
	function GotoChapterTransitionCoroutine(chapterID:NamespaceID, end:Bool):Coroutine;
	function HideChapterTransition():Void;
	function HidePages():Void;
	function OpenCreditsPanel():Void;
	function OpenKeybindingPanel():Void;

	function FadeScreenCoverColor(target:Color, duration:Float):Void;
	function SetScreenCoverColor(value:Color):Void;
}
