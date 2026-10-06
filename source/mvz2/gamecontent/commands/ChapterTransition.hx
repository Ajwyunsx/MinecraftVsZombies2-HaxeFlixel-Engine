// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/ChapterTransition.cs
package mvz2.gamecontent.commands;

import mvz2.gamecontent.maps.VanillaMapID;
import mvz2.vanilla.chaptertransitions.VanillaChapterTransitions;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2logic.Global;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.localization.LogicStrings;
import pvzengine.NamespaceID;
using mvz2logic.saves.LogicSaveExt;

@:autoCommandDefinition(VanillaCommandNames.chapterTransition)
class ChapterTransition extends CommandDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Invoke(parameters:Array<String>):Void
    {
        var game = Global.Game;
        var level = Global.Level;
        if (level.IsInLevel())
        {
            throw Global.Localization.GetTextParticular(VanillaStrings.COMMAND_CANNOT_BE_CALLED_IN_LEVEL, LogicStrings.CONTEXT_COMMAND_OUTPUT);
        }

        if (parameters[0] == "start")
        {
            var id = NamespaceID.Parse(parameters[1], Global.BuiltinNamespace);
            Global.Music.Stop();
            var lastMapID = Global.Saves.GetLastMapID();
            game.StartCoroutine(VanillaChapterTransitions.TransitionToMap(id, lastMapID != null ? lastMapID : VanillaMapID.halloween, false));
        }
        else if (parameters[0] == "end")
        {
            var id = NamespaceID.Parse(parameters[1], Global.BuiltinNamespace);
            Global.Music.Stop();
            var lastMapID = Global.Saves.GetLastMapID();
            game.StartCoroutine(VanillaChapterTransitions.TransitionToMap(id, lastMapID != null ? lastMapID : VanillaMapID.halloween, true));
        }
    }
}
