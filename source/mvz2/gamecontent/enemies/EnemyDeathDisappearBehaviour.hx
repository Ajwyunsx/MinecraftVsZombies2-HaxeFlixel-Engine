// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Common/EnemyDeathDisappearBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEnemyStates;
import pvzengine.damages.DeathInfo;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import tools.FrameTimer;
using mvz2.vanilla.enemies.VanillaEnemyExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.enemyDeathDisappear)
class EnemyDeathDisappearBehaviour extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        if (entity.State == STATE_DEATH && entity.IsDead)
        {
            var deathTimer = GetDeathTimer(entity);
            if (deathTimer == null)
            {
                deathTimer = new FrameTimer(GetDeathTimeout(entity));
                SetDeathTimer(entity, deathTimer);
            }
            deathTimer.Run();
            if (deathTimer.Expired)
            {
                entity.FaintRemove();
            }
        }
    }
    public override function PostDeath(entity:Entity, info:DeathInfo):Void
    {
        super.PostDeath(entity, info);
        SetDeathTimer(entity, new FrameTimer(GetDeathTimeout(entity)));
    }
    function GetDeathTimeout(entity:Entity):Int
    {
        return 30;
    }
    public static function GetDeathTimer(entity:Entity):Null<FrameTimer>
    {
        return entity.GetBehaviourField(PROP_DEATH_TIMER);
    }
    public static function SetDeathTimer(entity:Entity, frameTimer:FrameTimer):Void
    {
        entity.SetBehaviourField(PROP_DEATH_TIMER, frameTimer);
    }
    public static inline var STATE_DEATH:Int = LogicEnemyStates.DEATH;
    public static var PROP_DEATH_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("DeathTimer");
}
