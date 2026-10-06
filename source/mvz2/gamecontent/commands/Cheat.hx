// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/Cheat.cs
package mvz2.gamecontent.commands;

import mvz2.gamecontent.buffs.level.DebugEnergyBuff;
import mvz2.gamecontent.buffs.level.DebugGodmodeBuff;
import mvz2.gamecontent.buffs.level.DebugNoRechargeBuff;
import mvz2.gamecontent.buffs.level.DebugStarshardBuff;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2logic.Global;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.localization.LogicStrings;
import pvzengine.buffs.BuffDefinition;

@:autoCommandDefinition(VanillaCommandNames.cheat)
class Cheat extends CommandDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Invoke(parameters:Array<String>):Void
    {
        var game = Global.Game;
        var level = Global.Level.GetLevel();
        if (level == null)
            return;

        var msg:String;
        var cheatNameKey:String;
        var buffDefinition:Null<BuffDefinition> = null;

        var cheatCode = parameters[0];
        switch (cheatCode)
        {
            case "godmode":
                buffDefinition = game.GetBuffDefinitionByType(DebugGodmodeBuff);
                cheatNameKey = VanillaStrings.CHEAT_NAME_GODMODE;
            case "energy":
                buffDefinition = game.GetBuffDefinitionByType(DebugEnergyBuff);
                cheatNameKey = VanillaStrings.CHEAT_NAME_ENERGY;
            case "recharge":
                buffDefinition = game.GetBuffDefinitionByType(DebugNoRechargeBuff);
                cheatNameKey = VanillaStrings.CHEAT_NAME_RECHARGE;
            case "starshard":
                buffDefinition = game.GetBuffDefinitionByType(DebugStarshardBuff);
                cheatNameKey = VanillaStrings.CHEAT_NAME_STARSHARD;
            default:
                throw Global.Localization.GetTextParticular(VanillaStrings.COMMAND_CHEAT_NOT_FOUND, LogicStrings.CONTEXT_COMMAND_OUTPUT, [cheatCode]);
        }

        if (level.HasBuff(buffDefinition))
        {
            level.RemoveBuffs(buffDefinition);
            msg = VanillaStrings.COMMAND_CHEAT_DISABLED;
        }
        else
        {
            level.AddBuff(buffDefinition);
            msg = VanillaStrings.COMMAND_CHEAT_ENABLED;
        }
        var cheatName = Global.Localization.GetTextParticular(cheatNameKey, VanillaStrings.CONTEXT_COMMAND_CHEAT_NAME);
        PrintLine(Global.Localization.GetTextParticular(msg, LogicStrings.CONTEXT_COMMAND_OUTPUT, [cheatName]));
    }
}
