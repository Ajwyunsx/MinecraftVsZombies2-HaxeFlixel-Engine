// Ported from: Assets/Scripts/Logic/Command/ICommandMeta.cs
package mvz2logic.commands;

interface ICommandParameterMeta
{
	public var Name(get, never):String;
	public var Description(get, never):String;
	public var Optional(get, never):Bool;
	public var Type(get, never):String;
	public var IDType(get, never):String;
	function GetTypeName():String;
}
