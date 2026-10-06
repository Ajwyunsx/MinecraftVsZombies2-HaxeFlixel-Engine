// Ported from: Assets/Scripts/Logic/Command/CommandDefinition.cs
package mvz2logic.commands;

import mvz2logic.definitions.LogicDefinitionTypes;
import mvz2logic.Global;
import pvzengine.base.Definition;

// abstract
class CommandDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	// abstract
	public function Invoke(parameters:Array<String>):Void
	{
		throw "abstract";
	}
	// PORT-NOTE: C# protected -> Haxe 无 protected，改为 public。
	public function Print(text:String):Void
	{
		Global.Debugs.Print(text);
	}
	// PORT-NOTE: C# 有 PrintLine(string) 与 PrintLine() 两个重载，Haxe 不支持重载，用默认参数合并。
	public function PrintLine(text:String = ""):Void
	{
		Print(text + "\n");
	}
	public override function GetDefinitionType():String
	{
		return LogicDefinitionTypes.COMMAND;
	}
}
