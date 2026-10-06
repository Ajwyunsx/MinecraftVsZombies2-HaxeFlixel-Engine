// Ported from: Assets/Scripts/Logic/Conditions/ICondition.cs
// PORT-NOTE: 同文件的 IConditionList 已拆为独立模块 mvz2logic/conditions/IConditionList.hx。
package mvz2logic.conditions;

import mvz2logic.games.IGlobalSaveData;

interface ICondition
{
	function MeetsCondition(save:IGlobalSaveData):Bool;
}
