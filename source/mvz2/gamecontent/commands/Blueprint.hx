// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/Blueprint.cs
package mvz2.gamecontent.commands;

import mvz2.vanilla.localization.VanillaStrings;
import mvz2logic.Global;
import mvz2logic.ParseHelper;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.localization.LogicStrings;
import pvzengine.NamespaceID;

@:autoCommandDefinition(VanillaCommandNames.blueprint)
class Blueprint extends CommandDefinition
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

        var mode = parameters[0];
        var slot = ParseHelper.ParseInt(parameters[1]);
        if (slot < 0 || slot >= level.GetSeedSlotCount())
        {
            var msg = Global.Localization.GetTextParticular(VanillaStrings.COMMAND_BLUEPRINT_SLOT_OUT_OF_RANGE, LogicStrings.CONTEXT_COMMAND_OUTPUT, [Std.string(slot)]);
            throw msg;
        }
        if (mode == "set")
        {
            var idParam = parameters[2];
            var id = NamespaceID.Parse(idParam, Global.BuiltinNamespace);

            if (!LogicLevelExt.IsConveyorMode(level))
            {
                var seedPack = level.CreateSeedPack(id);
                if (seedPack != null)
                    seedPack.SetStartRecharge(true);
                level.ReplaceSeedPackAt(slot, seedPack);
            }
        }
        else if (mode == "remove")
        {
            if (!LogicLevelExt.IsConveyorMode(level))
            {
                level.RemoveSeedPackAt(slot);
            }
        }
    }
}
