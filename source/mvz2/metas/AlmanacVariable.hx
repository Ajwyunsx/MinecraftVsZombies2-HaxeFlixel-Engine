// Ported from: Assets/Scripts/MVZ2/Metas/Almanac/Variable/AlmanacVariable.cs
package mvz2.metas;

import expressionevaluator.CompiledExpression;
import system.globalization.CultureInfo;  // UNKNOWNIMPORT
import expressionevaluator.ExpressionEngine;
import mvz2.io.XMLHelper;
import pvzengine.Log;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class AlmanacVariable {
    public var name:String;
    public var decimalPrecision:Int = 2;
    public var expression:CompiledExpression;

    public function new(name:String) {
        this.name = name;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):AlmanacVariable {
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null || name.length == 0) {
            Log.LogError('The name of an AlmanacVariable is invalid.');
            return null;
        }
        var decimalPrecisionAttr = XMLHelper.GetAttributeInt(node, "decimalPrecision");
        var decimalPrecision = decimalPrecisionAttr != null ? decimalPrecisionAttr : 2;
        var expression = ExpressionEngine.Compile(node.InnerText);
        var variable = new AlmanacVariable(name);
        variable.expression = expression;
        variable.decimalPrecision = decimalPrecision;
        return variable;
    }

    public function GetVariableValue(context:AlmanacVariableContext):Dynamic {
        if (expression == null)
            return null;
        try {
            return expression.Evaluate(context);
        } catch (e:Dynamic) {
            throw 'Failed to execute almanac variable expression ${expression.ExpressionString}: ${Std.string(e)}';
        }
    }
    public function GetValueString(context:AlmanacVariableContext):String {
        // 从数据提供者获取属性值
        var value:Dynamic = null;
        try {
            value = GetVariableValue(context);
        } catch (ex:Dynamic) {
            // 错误处理：可记录日志，返回错误占位符
            return '[ERR: ${Std.string(ex)}]';
        }

        var numericValue:Float;
        try {
            // 转换为数值并应用乘数
            // PORT-NOTE: C# `Convert.ToDouble(object)` 在 Haxe 中无直接对应，按运行时类型转换，转换失败抛错。
            numericValue = ConvertToDouble(value);
            // 根据数值类型格式化（去除不必要的小数尾随零）
            return FormatNumber(numericValue, decimalPrecision);
        } catch (e:Dynamic) {
            // 非数值属性：直接返回字符串形式
            return value != null ? Std.string(value) : "";
        }
    }
    // PORT-NOTE: C# `Convert.ToDouble(object)` 的等价实现：整数/浮点/布尔/可解析字符串可转换，其余抛出。
    // TODO-PORT: C# Convert.ToDouble 还支持 DateTime/IConvertible 等类型并受 CultureInfo 影响，
    // Haxe 侧只覆盖数值与字符串，非数值对象会走 catch 分支返回原字符串。
    private static function ConvertToDouble(value:Dynamic):Float {
        switch (Type.typeof(value)) {
            case TInt:
                return cast(value, Int) * 1.0;
            case TFloat:
                return cast value;
            case TBool:
                return (cast(value, Bool)) ? 1.0 : 0.0;
            case TClass(c) if (c == String):
                var parsed = Std.parseFloat(cast value);
                if (Math.isNaN(parsed))
                    throw 'Cannot convert "${Std.string(value)}" to a number.';
                return parsed;
            default:
                throw 'Cannot convert value to a number.';
        }
    }
    // PORT-NOTE: C# `numericValue.ToString($"0.{new string('#', decimalPrecision)}")`（即 "0.##"）
    // 在 Haxe 无自定义数字格式字符串，改为四舍五入到指定小数位后输出，结果一致。
    // TODO-PORT: 四舍五入 + Std.string 与 .NET "0.##" 在极值/科学计数法（如 1e21）下输出可能不同，
    // 若后续发现显示差异，需在此实现完整的自定义数字格式化。
    private static function FormatNumber(value:Float, decimalPrecision:Int):String {
        var factor = Math.pow(10, decimalPrecision);
        var rounded = Math.round(value * factor) / factor;
        return Std.string(rounded);
    }
    public function toString():String {
        return name;
    }
}
