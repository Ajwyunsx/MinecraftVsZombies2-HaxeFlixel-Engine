// Ported from: Assets/Scripts/MVZ2/Metas/Almanac/Variable/AlmanacVariableFunctions.cs
package mvz2.metas;

import pvzengine.NamespaceID;
import pvzengine.PropertyMapper;
import pvzengine.base.Definition;
using mvz2logic.helditems.LogicHeldItemExt;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class AlmanacVariableFunctions {
    private function new() {}

    public static function EvaluateFunctions(context:AlmanacVariableContext, name:String, args:Array<Dynamic>):Dynamic {
        switch (name) {
            case "global":
                return global(context, args);
            case "local":
                return local(context, args);
            case "property":
                return property(context, args);
            default:
        }
        return null;
    }
    public static function global(context:AlmanacVariableContext, args:Array<Dynamic>):Dynamic {
        if (context == null)
            throw "No AlmanacVariableContext provided.";
        if (args.length == 1 && Std.isOfType(args[0], String)) {
            var idStr:String = cast args[0];
            var id = NamespaceID.Parse(idStr, context.main.BuiltinNamespace);
            var variable = context.main.ResourceManager.GetAlmanacGlobalVariable(id);
            if (variable == null)
                throw 'Cannot find global almanac variable ${idStr}';

            // PORT-NOTE: C# `HashSet<T>.Add` 返回是否新增 → Haxe Map.exists + set。
            if (context.globalCallStack.exists(id))
                throw 'Cyclic dependency detected: ${idStr}';
            context.globalCallStack.set(id, true);
            // PORT-NOTE: C# 的 try/finally 在 Haxe 中不支持，改为 try/catch + 显式清理。
            try {
                var result = variable.GetVariableValue(context);
                context.globalCallStack.remove(id);
                return result;
            } catch (e:Dynamic) {
                context.globalCallStack.remove(id);
                throw e;
            }
        }
        throw "Invalid global() usage";
    }
    public static function local(context:AlmanacVariableContext, args:Array<Dynamic>):Dynamic {
        if (context == null)
            throw "No AlmanacVariableContext provided.";
        if (args.length == 1 && Std.isOfType(args[0], String)) {
            var idStr:String = cast args[0];
            var variable = context.currentAlmanacEntry.GetLocalVariable(idStr);
            if (variable == null)
                throw 'Cannot find local almanac variable ${idStr} in entry ${context.currentAlmanacEntry.name}';

            // PORT-NOTE: C# `HashSet<T>.Add` 返回是否新增 → Haxe Map.exists + set。
            if (context.localCallStack.exists(idStr))
                throw 'Cyclic dependency detected: ${idStr}';
            context.localCallStack.set(idStr, true);
            // PORT-NOTE: C# 的 try/finally 在 Haxe 中不支持，改为 try/catch + 显式清理。
            try {
                var result = variable.GetVariableValue(context);
                context.localCallStack.remove(idStr);
                return result;
            } catch (e:Dynamic) {
                context.localCallStack.remove(idStr);
                throw e;
            }
        }
        throw "Invalid local() usage";
    }
    public static function property(context:AlmanacVariableContext, args:Array<Dynamic>):Dynamic {
        if (context == null)
            throw "No AlmanacVariableContext provided.";
        var arg0 = args[0];
        var key:String = null;
        if (arg0 != null) {
            key = Std.string(arg0);
            var propertyKey = PropertyMapper.ConvertFromName(key);
            // TODO-PORT: pvzengine.PropertyMapper / IPropertyKey 的 shim 尚未编写，
            // 此处按 C# 原样调用 IsValid()，待 shim 落地后确认签名。
            if (propertyKey.IsValid()) {

                var definitionId = context.currentDefinitionID;
                var definitionType = context.currentDefinitionType;

                if (args.length >= 2) {
                    var arg1 = args[1];
                    // PORT-NOTE: C# 为 `arg1 is NamespaceID nid` / `NamespaceID.Parse(arg1.ToString(), nsp)` 两分支；
                    // NamespaceID 在 Haxe 中是 abstract(String)，运行期即 "nsp:path" 字符串，无法判定类型，
                    // 两条分支走 Parse 的结果一致（字符串形式可被 Parse 直接还原），故合并。
                    if (arg1 != null)
                        definitionId = NamespaceID.Parse(Std.string(arg1), context.main.BuiltinNamespace);
                    else
                        definitionId = null;
                }
                if (args.length >= 3) {
                    var arg2 = args[2];
                    if (arg2 != null)
                        definitionType = Std.string(arg2);
                    else
                        definitionType = "";
                }
                // PORT-NOTE: C# 泛型调用 GetDefinition<Definition>(type, id) 在 Haxe 中改为首参数传 Class<T>。
                var definition:Definition = context.main.Game.GetDefinition(Definition, definitionType, definitionId);
                if (definition == null)
                    throw 'Cannot find definition ${definitionId} of type ${definitionType} in variable of almanac entry ${context.currentAlmanacEntry.name}.';

                return definition.GetPropertyObject(propertyKey);
            }
        }
        throw 'Cannot find property of key ${key} in variable of almanac entry ${context.currentAlmanacEntry.name}.';
    }
}
