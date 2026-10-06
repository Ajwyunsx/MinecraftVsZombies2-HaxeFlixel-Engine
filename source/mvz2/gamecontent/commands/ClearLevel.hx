// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/ClearLevel.cs
package mvz2.gamecontent.commands;

import mvz2.gamecontent.pickups.ClearPickup;
import mvz2logic.Global;
import mvz2logic.commands.CommandDefinition;
import unity.Mathf;
import unity.Vector3;

@:autoCommandDefinition(VanillaCommandNames.clearLevel)
class ClearLevel extends CommandDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Invoke(parameters:Array<String>):Void
    {
        var level = Global.Level.GetLevel();
        if (level == null)
            return;

        var x = level.GetEntityColumnX(Mathf.FloorToInt(level.GetMaxColumnCount() * 0.5));
        var z = level.GetEntityLaneZ(Mathf.FloorToInt(level.GetMaxLaneCount() * 0.5));
        var y = level.GetGroundY(x, z);

        ClearPickup.Produce(level, new Vector3(x, y, z));
    }
}
