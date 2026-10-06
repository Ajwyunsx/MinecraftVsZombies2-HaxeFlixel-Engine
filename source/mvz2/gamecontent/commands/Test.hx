// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/Test.cs
package mvz2.gamecontent.commands;

import mvz2.gamecontent.areas.Ship;
import mvz2logic.Global;
import mvz2logic.ParseHelper;
import mvz2logic.armors.LogicArmorSlots;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.commands.CommandUtility;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import pvzengine.level.LevelEngine;

@:autoCommandDefinition(VanillaCommandNames.test)
class Test extends CommandDefinition
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

        if (parameters[0] == "spawnenemies")
        {
            var page = 0;
            if (parameters.length > 1)
            {
                page = CommandUtility.ParseOptionalInt(parameters[1], 0);
            }
            SpawnEnemies(level, page);
        }
        else if (parameters[0] == "armor")
        {
            var id = NamespaceID.Parse(parameters[1], Global.BuiltinNamespace);
            EquipArmors(level, id, LogicArmorSlots.main);
        }
        else if (parameters[0] == "shield")
        {
            var id = NamespaceID.Parse(parameters[1], Global.BuiltinNamespace);
            EquipArmors(level, id, LogicArmorSlots.shield);
        }
        else if (parameters[0] == "paratroops")
        {
            Ship.SpawnParatroops(level, 3);
        }
        else if (parameters[0] == "wave")
        {
            var count = ParseHelper.ParseInt(parameters[1]);
            level.CurrentWave = count;
        }
        else if (parameters[0] == "flags")
        {
            level.CurrentFlag = ParseHelper.ParseInt(parameters[1]);
            LogicLevelExt.UpdateLevelName(level);
        }
    }
    function SpawnEnemies(level:LevelEngine, page:Int):Void
    {
        var game = Global.Game;
        // PORT-NOTE: C# LINQ Where/ToArray → Lambda.filter。
        var enemies = Lambda.array(Lambda.filter(game.GetAllEntityDefinitions(), e -> e.Type == EntityTypes.ENEMY));

        var columns = level.GetMaxColumnCount();
        var lanes = level.GetMaxLaneCount();
        var halfColumns = Std.int(columns / 2);
        var enemiesPerPage = halfColumns * lanes;
        for (i in 0...enemiesPerPage)
        {
            var index = i + enemiesPerPage * page;
            if (index < 0 || index >= enemies.length)
                continue;
            var enemyDef = enemies[index];
            if (enemyDef == null)
                continue;
            var column = (i % halfColumns) * 2 + 1;
            var lane = Std.int(i / halfColumns);
            var pos = level.GetEntityGridPosition(column, lane);
            var spawned = level.Spawn(enemyDef, pos, null);
        }
    }
    function EquipArmors(level:LevelEngine, armorID:NamespaceID, slot:NamespaceID):Void
    {
        for (enemy in level.FindEntities(e -> e.Type == EntityTypes.ENEMY))
        {
            enemy.EquipArmorTo(slot, armorID);
        }
    }
}
