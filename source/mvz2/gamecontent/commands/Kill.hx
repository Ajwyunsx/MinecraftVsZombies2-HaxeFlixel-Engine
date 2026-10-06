// Ported from: Assets/Scripts/Vanilla/GameContent/Commands/Kill.cs
package mvz2.gamecontent.commands;

import mvz2logic.Global;
import mvz2logic.commands.CommandDefinition;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;

@:autoCommandDefinition(VanillaCommandNames.kill)
class Kill extends CommandDefinition
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
        var entities:Array<Entity>;
        if (parameters.length <= 0)
        {
            entities = level.FindEntities(e -> e.Type == EntityTypes.ENEMY && !e.IsDead);
        }
        else if (parameters[0] == "contraption")
        {
            entities = level.FindEntities(e -> e.Type == EntityTypes.PLANT && !e.IsDead);
        }
        else if (parameters[0] == "obstacle")
        {
            entities = level.FindEntities(e -> e.Type == EntityTypes.OBSTACLE && !e.IsDead);
        }
        else if (parameters[0] == "boss")
        {
            entities = level.FindEntities(e -> e.Type == EntityTypes.BOSS && !e.IsDead);
        }
        else if (parameters[0] == "all")
        {
            entities = level.FindEntities(e -> LogicEntityExt.IsVulnerableEntity(e) && !e.IsDead);
        }
        else
        {
            entities = level.FindEntities(e -> e.Type == EntityTypes.ENEMY && !e.IsDead);
        }
        for (enemy in entities)
        {
            enemy.Die();
        }
    }
}
