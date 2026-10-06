// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter4/DelayedSpawnerTriggerBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.obstacles.MonsterSpawner;
import mvz2.gamecontent.obstacles.VanillaObstacleID;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.level.LogicLevelProps;
import pvzengine.buffs.Buff;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.BooleanModifier;
import tools.FrameTimer;

@:autoBuffDefinition(VanillaBuffNames.Level_delayedSpawnerTrigger)
class DelayedSpawnerTriggerBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new BooleanModifier(LogicLevelProps.ASSUME_HAS_ENEMIES, true));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMER, new FrameTimer(MAX_TIMEOUT));
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var timer = buff.GetProperty(PROP_TIMER);
        if (timer == null || timer.Expired)
        {
            for (spawner in buff.Level.FindEntities(VanillaObstacleID.monsterSpawner))
            {
                MonsterSpawner.Trigger(spawner);
            }
            buff.Remove();
        }
        else
        {
            timer.Run();
        }
    }
    public static inline var MAX_TIMEOUT:Int = 60;
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("Timer");
}
