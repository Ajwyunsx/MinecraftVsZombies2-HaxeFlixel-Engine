// Ported from: Assets/Scripts/View/Level/ILevelRaycastReceiver.cs
package mvz2.ui.level;

import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.HeldItemDefinition;
import pvzengine.level.LevelEngine;
import unity.eventsystems.PointerEventData;

interface ILevelRaycastReceiver
{
	function IsValidReceiver(level:LevelEngine, definition:HeldItemDefinition, data:IHeldItemData, eventData:PointerEventData):Bool;
	function GetSortingLayer():Int;
	function GetSortingOrder():Int;
}
