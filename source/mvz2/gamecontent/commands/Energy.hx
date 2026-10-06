// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/Energy.cs
package mvz2.gamecontent.commands;

import mvz2logic.Global;
import mvz2logic.ParseHelper;
import mvz2logic.commands.CommandDefinition;

@:autoCommandDefinition(VanillaCommandNames.energy)
class Energy extends CommandDefinition
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
        var amount = ParseHelper.ParseFloat(parameters[1]);
        if (mode == "set")
        {
            level.SetEnergy(amount);
        }
        else if (mode == "add")
        {
            level.AddEnergy(amount);
        }
    }
}
