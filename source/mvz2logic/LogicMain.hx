// Ported from: Assets/Scripts/Logic/LogicMain.cs
package mvz2logic;

import unity.Mathf;

class LogicMain {
    public static function GetFloatPercentageText(value:Float):String {
        return Global.Localization.GetText(VALUE_PERCENT, [Mathf.RoundToInt(value * 100)]);
    }

    // [TranslateMsg("将数值{0}显示为百分比")]
    public static inline var VALUE_PERCENT:String = "{0}%";
}
