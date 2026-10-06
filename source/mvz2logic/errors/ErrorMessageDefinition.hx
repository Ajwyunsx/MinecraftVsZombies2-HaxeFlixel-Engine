// Ported from: Assets/Scripts/Logic/ErrorMessage/ErrorMessageDefinition.cs
package mvz2logic.errors;

import pvzengine.base.Definition;

class ErrorMessageDefinition extends Definition
{
	public function new(nsp:String, name:String, definitionType:String, errorMessage:String)
	{
		super(nsp, name);
		DefinitionType = definitionType;
		Message = errorMessage;
	}
	public override function GetDefinitionType():String
	{
		return DefinitionType;
	}
	public var Message:String;
	public var DefinitionType(default, null):String;
}
