// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/Help.cs
package mvz2.gamecontent.commands;

import mvz2.vanilla.localization.VanillaStrings;
import mvz2logic.Global;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.localization.LogicStrings;
using mvz2logic.games.LogicGameDefinitionsExt;
using mvz2logic.commands.LogicCommandProps;

@:autoCommandDefinition(VanillaCommandNames.help)
class Help extends CommandDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Invoke(parameters:Array<String>):Void
    {
        var game = Global.Game;
        var localization = Global.Localization;
        var debugs = Global.Debugs;

        if (parameters.length <= 0)
        {
            // PORT-NOTE: C# LINQ OrderBy → Array.sort。
            var commands = Lambda.array(debugs.GetAllCommandsID());
            commands.sort((a, b) -> Reflect.compare(debugs.GetCommandNameByID(a), debugs.GetCommandNameByID(b)));
            for (id in commands)
            {
                var name = debugs.GetCommandNameByID(id);
                var def = game.GetCommandDefinition(id);
                if (def == null)
                    continue;
                var desc = def.GetDescription();
                var description = (desc == null || desc == "") ? "" : localization.GetTextParticular(desc, LogicStrings.CONTEXT_COMMAND_DESCRIPTION);
                // PORT-NOTE: C# 签名是 GetTextParticular(key, context, params object[] args)，可变参数在 Haxe 侧
                // 收成单个 Array<Dynamic>，故把 name/description 合并进一个数组。
                var output = localization.GetTextParticular(VanillaStrings.COMMAND_HELP_COMMAND_LIST_TEMPLATE, LogicStrings.CONTEXT_COMMAND_OUTPUT, [name, description]);
                PrintLine(output);
            }
            PrintLine("");
            var details = localization.GetTextParticular(VanillaStrings.COMMAND_HELP_DETAILS, LogicStrings.CONTEXT_COMMAND_OUTPUT);
            PrintLine(details);
        }
        else
        {
            var commandName = parameters[0];
            var id = debugs.GetCommandIDByName(commandName);
            var def = game.GetCommandDefinition(id);
            if (def == null)
                return;

            PrintLine(commandName);
            var variants = def.GetVariants();
            if (variants != null)
            {
                for (variant in variants)
                {
                    PrintLine("");
                    PrintLine(variant.GetGrammarText(commandName));
                    PrintLine(localization.GetTextParticular(variant.Description, LogicStrings.CONTEXT_COMMAND_VARIANT_DESCRIPTION));
                    PrintLine("");
                    for (param in variant.Parameters)
                    {
                        var paramName = param.Name;
                        var desc = localization.GetTextParticular(param.Description, LogicStrings.CONTEXT_COMMAND_PARAMETER_DESCRIPTION);
                        var type = localization.GetTextParticular(param.GetTypeName(), LogicStrings.CONTEXT_COMMAND_PARAMETER_TYPE);
                        // PORT-NOTE: 同上，C# 的 params object[] args 在 Haxe 侧是一个数组：{0}=paramName, {1}=type, {2}=desc。
                        var msg = localization.GetTextParticular(VanillaStrings.COMMAND_HELP_PARAMETER_TEMPLATE, LogicStrings.CONTEXT_COMMAND_OUTPUT, [paramName, type, desc]);
                        PrintLine(msg);
                    }
                }
            }
        }
    }
}
