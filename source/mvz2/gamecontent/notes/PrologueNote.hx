// Ported from: Assets/Scripts/Vanilla/GameContent/Notes/PrologueNote.cs
package mvz2.gamecontent.notes;

import mvz2.gamecontent.areas.VanillaAreaID;
import mvz2.gamecontent.stages.VanillaStageID;
import mvz2.vanilla.chaptertransitions.VanillaChapterTransitions;
import mvz2logic.Global;
import mvz2logic.notes.INote;
import mvz2logic.notes.NoteDefinition;

@:autoNoteDefinition(VanillaNoteNames.prologue)
class PrologueNote extends NoteDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function OnBack(note:INote):Void
    {
        super.OnBack(note);
        note.SetInteractable(false);
        Global.Game.StartCoroutine(VanillaChapterTransitions.TransitionToLevel(VanillaChapterTransitions.halloween, VanillaAreaID.halloween, VanillaStageID.halloween1));
    }
}
