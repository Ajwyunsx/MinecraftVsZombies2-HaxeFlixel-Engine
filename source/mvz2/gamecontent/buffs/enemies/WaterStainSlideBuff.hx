// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Enemies/Chapter5/WaterStainSlideBuff.cs
package mvz2.gamecontent.buffs.enemies;

import mvz2.gamecontent.buffs.VanillaBuffID;
import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.EntityTypes;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
using mvz2.vanilla.entities.VanillaEntityExt;

@:autoBuffDefinition(VanillaBuffNames.Enemy_waterStainSlide)
class WaterStainSlideBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddTrigger(LevelCallbacks.POST_ENTITY_UPDATE, PostUpdateCallback, 0, EntityTypes.ENEMY);
        AddModifier(new FloatModifier(EngineEntityProps.FRICTION, NumberOperator.Multiply, 0.01));
        AddModifier(new FloatModifier(VanillaEntityProps.BLOW_MASS_OFFSET, NumberOperator.Add, -1));
    }
    private function PostUpdateCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        if (entity.IsDead)
            return;
        if (!entity.IsOnGround)
            return;
        if (!entity.HasBuff(VanillaBuffID.Enemy.waterStainSlide))
            return;
        if (!VanillaEntityExt.IsAboveLand(entity))
            return;
        entity.Position = entity.Position + entity.GetFacingDirection() * SLIDE_SPEED;
    }
    public static inline var SLIDE_SPEED:Float = 0.5;
}
