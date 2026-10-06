// Ported from: Assets/Scripts/Vanilla/GameContent/Notes/ShipNote.cs
package mvz2.gamecontent.notes;

import mvz2logic.Global;
import mvz2logic.notes.INote;
import mvz2logic.notes.NoteDefinition;

@:autoNoteDefinition(VanillaNoteNames.ship)
class ShipNote extends NoteDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function OnBack(note:INote):Void
    {
        super.OnBack(note);
        Global.Scene.GotoMapOrMainmenu();
    }
}
