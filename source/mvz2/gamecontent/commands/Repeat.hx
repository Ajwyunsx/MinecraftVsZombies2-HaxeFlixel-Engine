// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/Repeat.cs
package mvz2.gamecontent.commands;

import mvz2logic.Global;
import mvz2logic.ParseHelper;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.commands.CommandUtility;

@:autoCommandDefinition(VanillaCommandNames.repeat)
class Repeat extends CommandDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Invoke(parameters:Array<String>):Void
    {
        var count = ParseHelper.ParseInt(parameters[0]);
        // PORT-NOTE: C# LINQ FirstOrDefault → Lambda.find。
        var last = Lambda.find(Global.Debugs.GetCommandHistory(), h ->
        {
            var parts = CommandUtility.SplitCommand(h);
            return parts.length >= 1 && Global.Debugs.GetCommandIDByName(parts[0]) != GetID();
        });
        if (last == null || last == "")
            return;
        Global.Debugs.ExecuteCommand(last, count);
    }
}
