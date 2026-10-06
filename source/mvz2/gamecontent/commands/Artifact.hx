// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/Artifact.cs
package mvz2.gamecontent.commands;

import mvz2.vanilla.localization.VanillaStrings;
import mvz2logic.Global;
import mvz2logic.ParseHelper;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.localization.LogicStrings;
import pvzengine.NamespaceID;
using mvz2logic.games.LogicGameDefinitionsExt;

@:autoCommandDefinition(VanillaCommandNames.artifact)
class Artifact extends CommandDefinition
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
            var definition = game.GetArtifactDefinition(id);
            level.ReplaceArtifact(slot, definition);
        }
        else if (mode == "remove")
        {
            level.SetArtifact(slot, null);
        }
    }
}
