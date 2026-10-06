// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/Save.cs
package mvz2.gamecontent.commands;

import mvz2.vanilla.localization.VanillaStrings;
import mvz2logic.Global;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.localization.LogicStrings;
import mvz2logic.level.LogicLevelExt;

@:autoCommandDefinition(VanillaCommandNames.save)
class Save extends CommandDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Invoke(parameters:Array<String>):Void
    {
        var level = Global.Level.GetLevel();
        if (level == null)
            return;
        LogicLevelExt.SaveStateData(level);
        PrintLine(Global.Localization.GetTextParticular(VanillaStrings.COMMAND_SAVE_SUCCESS, LogicStrings.CONTEXT_COMMAND_OUTPUT));
    }
}
