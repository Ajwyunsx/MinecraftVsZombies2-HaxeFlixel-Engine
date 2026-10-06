// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/Recharge.cs
package mvz2.gamecontent.commands;

import mvz2logic.Global;
import mvz2logic.commands.CommandDefinition;

@:autoCommandDefinition(VanillaCommandNames.recharge)
class Recharge extends CommandDefinition
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

        level.FullRechargeAll();
    }
}
