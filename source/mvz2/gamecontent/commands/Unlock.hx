// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/Unlock.cs
package mvz2.gamecontent.commands;

import mvz2.vanilla.localization.VanillaStrings;
import mvz2logic.Global;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.localization.LogicStrings;
import pvzengine.NamespaceID;

@:autoCommandDefinition(VanillaCommandNames.unlock)
class Unlock extends CommandDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Invoke(parameters:Array<String>):Void
    {
        var game = Global.Game;
        var saves = Global.Saves;

        if (parameters[0] == "add")
        {
            var id = NamespaceID.Parse(parameters[1], Global.BuiltinNamespace);
            if (!saves.IsUnlocked(id))
            {
                saves.Unlock(id);
                saves.SaveToFile();
                PrintLine(Global.Localization.GetTextParticular(VanillaStrings.COMMAND_UNLOCK_ADD_SUCCESS, LogicStrings.CONTEXT_COMMAND_OUTPUT, [Std.string(id)]));
            }
            else
            {
                PrintLine(Global.Localization.GetTextParticular(VanillaStrings.COMMAND_UNLOCK_ADD_FAILED_ALREADY_UNLOCKED, LogicStrings.CONTEXT_COMMAND_OUTPUT, [Std.string(id)]));
            }
        }
        else if (parameters[0] == "remove")
        {
            var id = NamespaceID.Parse(parameters[1], Global.BuiltinNamespace);
            if (saves.IsUnlocked(id))
            {
                saves.Relock(id);
                saves.SaveToFile();
                PrintLine(Global.Localization.GetTextParticular(VanillaStrings.COMMAND_UNLOCK_REMOVE_SUCCESS, LogicStrings.CONTEXT_COMMAND_OUTPUT, [Std.string(id)]));
            }
            else
            {
                PrintLine(Global.Localization.GetTextParticular(VanillaStrings.COMMAND_UNLOCK_REMOVE_FAILED_NOT_UNLOCKED, LogicStrings.CONTEXT_COMMAND_OUTPUT, [Std.string(id)]));
            }
        }
        else if (parameters[0] == "list")
        {
            var sb = new StringBuf();
            for (id in saves.GetAllUnlocks())
            {
                sb.add(Std.string(id));
                sb.add("\n");
            }
            Print(sb.toString());
        }
        else if (parameters[0] == "listlocked")
        {
            var sb = new StringBuf();
            // PORT-NOTE: C# LINQ Except → 手动过滤。
            var unlocked = saves.GetAllUnlocks();
            for (id in game.GetAllUnlockConditions())
            {
                if (Lambda.has(unlocked, id))
                    continue;
                sb.add(Std.string(id));
                sb.add("\n");
            }
            Print(sb.toString());
        }
        else if (parameters[0] == "all")
        {
            var currentUnlocks = saves.GetAllUnlocks();
            var allUnlocks = game.GetAllUnlockConditions();
            var unlocks = Lambda.array(Lambda.filter(allUnlocks, id -> !Lambda.has(currentUnlocks, id)));
            if (unlocks.length <= 0)
            {
                PrintLine(Global.Localization.GetTextParticular(VanillaStrings.COMMAND_UNLOCK_ALL_FAILED_NOTHING_LOCKED, LogicStrings.CONTEXT_COMMAND_OUTPUT));
            }
            else
            {
                var sb = new StringBuf();
                for (id in unlocks)
                {
                    saves.Unlock(id);
                    sb.add(Std.string(id));
                    sb.add("\n");
                }
                saves.SaveToFile();
                PrintLine(Global.Localization.GetTextParticular(VanillaStrings.COMMAND_UNLOCK_ALL_SUCCESS, LogicStrings.CONTEXT_COMMAND_OUTPUT, [sb.toString()]));
            }
        }
        else if (parameters[0] == "none")
        {
            var unlocks = saves.GetAllUnlocks();
            if (unlocks.length <= 0)
            {
                PrintLine(Global.Localization.GetTextParticular(VanillaStrings.COMMAND_UNLOCK_NONE_FAILED_NOTHING_UNLOCKED, LogicStrings.CONTEXT_COMMAND_OUTPUT));
            }
            else
            {
                var sb = new StringBuf();
                for (id in unlocks)
                {
                    saves.Relock(id);
                    sb.add(Std.string(id));
                    sb.add("\n");
                }
                saves.SaveToFile();
                PrintLine(Global.Localization.GetTextParticular(VanillaStrings.COMMAND_UNLOCK_NONE_SUCCESS, LogicStrings.CONTEXT_COMMAND_OUTPUT, [sb.toString()]));
            }
        }
    }
}
