// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/Spawn.cs
package mvz2.gamecontent.commands;

import mvz2logic.Global;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.commands.CommandUtility;
import pvzengine.NamespaceID;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.SpawnParams;
import unity.Mathf;
import unity.Vector3;

@:autoCommandDefinition(VanillaCommandNames.spawn)
class Spawn extends CommandDefinition
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

        var id = NamespaceID.Parse(parameters[1], Global.BuiltinNamespace);

        var x = level.GetEntityColumnX(Mathf.FloorToInt(level.GetMaxColumnCount() * 0.5));
        var z = level.GetEntityLaneZ(Mathf.FloorToInt(level.GetMaxLaneCount() * 0.5));
        var y = level.GetGroundY(x, z);
        var faction = -1;
        if (parameters[0] == "pos")
        {
            if (parameters.length >= 3)
            {
                x = CommandUtility.ParseOptionalFloat(parameters[2], x);
            }
            if (parameters.length >= 4)
            {
                y = CommandUtility.ParseOptionalFloat(parameters[3], y);
            }
            if (parameters.length >= 5)
            {
                z = CommandUtility.ParseOptionalFloat(parameters[4], z);
            }
            if (parameters.length >= 6)
            {
                faction = CommandUtility.ParseOptionalInt(parameters[5], faction);
            }
        }
        else if (parameters[0] == "tile")
        {
            var column = Mathf.Floor(level.GetMaxColumnCount() * 0.5);
            var lane = Mathf.Floor(level.GetMaxLaneCount() * 0.5);

            if (parameters.length >= 3)
            {
                column = CommandUtility.ParseOptionalFloat(parameters[2], column);
            }
            if (parameters.length >= 4)
            {
                lane = CommandUtility.ParseOptionalFloat(parameters[3], lane);
            }
            if (parameters.length >= 5)
            {
                faction = CommandUtility.ParseOptionalInt(parameters[4], faction);
            }

            x = level.GetEntityColumnXFloat(column);
            z = level.GetEntityLaneZFloat(lane);
            y = level.GetGroundY(x, z);
        }

        var spawnParam = new SpawnParams();
        if (faction >= 0)
        {
            spawnParam.SetProperty(EngineEntityProps.FACTION, faction);
        }
        level.Spawn(id, new Vector3(x, y, z), null, spawnParam);
    }
}
