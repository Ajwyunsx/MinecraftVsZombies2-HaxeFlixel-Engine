// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Contraption/Chapter5/StolenByUFOBuff.cs
package mvz2.gamecontent.buffs.contraptions;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.enemies.UFOBehaviourGreen;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaBuffPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.buffs.Buff;
import pvzengine.collisions.EntityCollisionHelper;
import pvzengine.damages.DamageEffectList;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.EntityID;
import pvzengine.modifiers.BooleanModifier;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import tools.FrameTimer;
import unity.Mathf;
import unity.Vector3;
import pvzengine.entities.EngineEntityExt;

@:autoBuffDefinition(VanillaBuffNames.Contraption_stolenByUFO)
class StolenByUFOBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new FloatModifier(VanillaEntityProps.FALL_RESISTANCE, NumberOperator.Add, 10000));
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.Multiply, 0));
        AddModifier(new Vector3Modifier(EngineEntityProps.DISPLAY_SCALE, NumberOperator.Multiply, PROP_SCALE));
        AddModifier(new Vector3Modifier(LogicEntityProps.SHADOW_SCALE, NumberOperator.Multiply, PROP_SCALE));
        AddModifier(new Vector3Modifier(EngineEntityProps.SCALE, NumberOperator.Multiply, PROP_SCALE));
        AddModifier(new BooleanModifier(VanillaEntityProps.AI_FROZEN, true));
        AddModifier(new BooleanModifier(EngineEntityProps.INVINCIBLE, true));
        AddModifier(new IntModifier(EngineEntityProps.COLLISION_DETECTION, IntegerOperator.BitOr, EntityCollisionHelper.DETECTION_NO_COLLISION));
    }
    public override function PostAdd(buff:Buff):Void
    {
        super.PostAdd(buff);
        buff.SetProperty(PROP_TIMER, new FrameTimer(TIMEOUT));
        buff.SetProperty(PROP_SCALE, Vector3.one);
    }
    public override function PostUpdate(buff:Buff):Void
    {
        super.PostUpdate(buff);
        var entity = buff.GetEntity();
        if (entity != null)
        {
            var ufoID = buff.GetProperty(PROP_UFO);
            var ufo = ufoID != null ? ufoID.GetEntity(buff.Level) : null;
            if (!EngineEntityExt.ExistsAndAlive(ufo))
            {
                VanillaEntityExt.DestroyConflictGridEntitiesOnLand(entity);
                buff.Remove();
                return;
            }

            var velocity = entity.Velocity;
            velocity.y = velocity.y * (1 - MOVE_FACTOR) + Mathf.Sign(ufo.Position.y - entity.Position.y) * ABSORB_SPEED * MOVE_FACTOR;
            entity.Velocity = velocity;

            var timer = buff.GetProperty(PROP_TIMER);
            if (timer != null)
            {
                timer.Run();
                buff.SetProperty(PROP_SCALE, Vector3.one * timer.GetTimeoutPercentage());
            }
            if (timer == null || timer.Expired)
            {
                buff.Remove();
                if (entity.Level.IsIZombie())
                {
                    var damageEffects = new DamageEffectList([VanillaDamageEffects.INSTA_KILL, VanillaDamageEffects.NO_DEATH_EFFECTS, VanillaDamageEffects.REMOVE_ON_DEATH]);
                    entity.Die(damageEffects, ufo);
                }
                else
                {
                    entity.Remove();
                    UFOBehaviourGreen.SetStolenEntityID(ufo, entity.GetDefinitionID());
                }
            }
        }
    }
    public static inline var TIMEOUT:Int = 60;
    public static inline var ABSORB_SPEED:Float = 2;
    public static inline var MOVE_FACTOR:Float = 0.2;
    public static var PROP_UFO:VanillaBuffPropertyMeta<EntityID> = new VanillaBuffPropertyMeta<EntityID>("ufo");
    public static var PROP_TIMER:VanillaBuffPropertyMeta<FrameTimer> = new VanillaBuffPropertyMeta<FrameTimer>("timer");
    public static var PROP_SCALE:VanillaBuffPropertyMeta<Vector3> = new VanillaBuffPropertyMeta<Vector3>("scale");
}
