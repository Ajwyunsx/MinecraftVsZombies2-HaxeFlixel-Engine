// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/Clear.cs
package mvz2.gamecontent.commands;

import mvz2logic.Global;
import mvz2logic.commands.CommandDefinition;

@:autoCommandDefinition(VanillaCommandNames.clear)
class Clear extends CommandDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Invoke(parameters:Array<String>):Void
    {
        Global.Debugs.ClearConsole();
    }
}
