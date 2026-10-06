// Ported from: Assets/Scripts/Logic/Notes/NoteDefinition.cs
package mvz2logic.notes;

import mvz2logic.definitions.LogicDefinitionTypes;
import pvzengine.base.Definition;

// abstract
class NoteDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public function OnBack(note:INote):Void {}
	public override function GetDefinitionType():String
	{
		return LogicDefinitionTypes.NOTE;
	}
}
