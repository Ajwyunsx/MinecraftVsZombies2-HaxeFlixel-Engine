// Ported from: Assets/Scripts/MVZ2/Saves/MVZ2SaveExt.cs
package mvz2.saves;

import mvz2logic.conditions.ICondition;
import mvz2logic.conditions.IConditionList;
import mvz2logic.games.IGlobalSaveData;

// PORT-NOTE: C# 的扩展方法改为静态方法（PORTING.md §扩展方法），
// 调用处可 `using mvz2.saves.MVZ2SaveExt;` 保持原写法。
class MVZ2SaveExt {
    public static function IsNullOrMeetsConditions(conditions:IConditionList, save:IGlobalSaveData):Bool {
        return conditions == null || conditions.MeetsConditions(save);
    }
    public static function MeetsXMLConditions(save:IGlobalSaveData, conditions:IConditionList):Bool {
        if (conditions == null)
            return false;
        return conditions.MeetsConditions(save);
    }
    public static function MeetsXMLCondition(save:IGlobalSaveData, condition:ICondition):Bool {
        if (condition == null)
            return false;
        return condition.MeetsCondition(save);
    }
}
