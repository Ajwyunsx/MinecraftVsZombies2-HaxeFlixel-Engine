// Ported from: Assets/Scripts/Logic/Game/IGlobalGame.cs
package mvz2logic.games;

import pvzengine.IGameContent;
import pvzengine.IGameTriggerSystem;
import pvzengine.NamespaceID;
import unity.Coroutine;

interface IGlobalGame extends IGameContent extends IGameTriggerSystem
{
	function IsMobile():Bool;
	function UseMobileLayout():Bool;
	// PORT-NOTE: C# 为 StartCoroutine(IEnumerator coroutine)，协程在移植中统一用 unity.Coroutine 表示。
	function StartCoroutine(coroutine:Coroutine):Coroutine;
	function GetAllUnlockConditions():Array<NamespaceID>;
	var DefaultNamespace(get, never):String;
}
