// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Boss/Chapter2/NightmareaperFallBuff.cs
package mvz2.gamecontent.buffs.bosses;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.entities.WaterInteraction;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.BuffDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.IntModifier;
import pvzengine.modifiers.IntegerOperator;
import pvzengine.modifiers.NumberOperator;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.WaterInteractionParams;

@:autoBuffDefinition(VanillaBuffNames.Boss_nightmareaperFall)
class NightmareaperFallBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new IntModifier(VanillaEntityProps.WATER_INTERACTION, IntegerOperator.Set, WaterInteraction.REMOVE));
        AddModifier(new IntModifier(VanillaEntityProps.AIR_INTERACTION, IntegerOperator.Set, WaterInteraction.REMOVE));
        AddModifier(new FloatModifier(EngineEntityProps.GRAVITY, NumberOperator.Add, 1));
        AddTrigger(VanillaLevelCallbacks.POST_WATER_INTERACTION, PostWaterInteractionCallback, WaterInteraction.ACTION_REMOVE);
    }
    function PostWaterInteractionCallback(param:WaterInteractionParams, callbackResult:CallbackResult):Void
    {
        var entity = param.entity;
        if (!entity.HasBuff(NightmareaperFallBuff))
            return;
        entity.Spawn(VanillaEffectID.nightmareaperSplash, entity.Position);
    }
}
