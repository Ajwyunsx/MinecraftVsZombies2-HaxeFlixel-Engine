// Ported from: Assets/Scripts/Logic/Conditions/ICondition.cs
package mvz2logic.conditions;

import mvz2logic.games.IGlobalSaveData;

interface IConditionList
{
	function MeetsConditions(save:IGlobalSaveData):Bool;
}
