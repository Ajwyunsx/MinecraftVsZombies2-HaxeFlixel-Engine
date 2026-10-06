// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Entity/Chapter5/DragonToothBuff.cs
package mvz2.gamecontent.buffs.entities;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.models.VanillaModelID;
import mvz2.vanilla.callbacks.VanillaCallbackPriorities;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.models.VanillaModelKeys;
import mvz2logic.models.LogicModelHelper;
import pvzengine.NamespaceID;
import pvzengine.buffs.Buff;
import pvzengine.callbacks.CallbackResult;
import pvzengine.definitions.BuffDefinition;
import unity.Mathf;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PreTakeDamageParams;

@:autoBuffDefinition(VanillaBuffNames.Entity_dragonTooth)
class DragonToothBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModelInsertion(LogicModelHelper.ANCHOR_CENTER, modelKey, VanillaModelID.vulnerable);
        AddTrigger(VanillaLevelCallbacks.PRE_ENTITY_TAKE_DAMAGE, PreEntityTakeDamageCallback, VanillaCallbackPriorities.MULTIPLY);
    }
    private function PreEntityTakeDamageCallback(param:PreTakeDamageParams, result:CallbackResult):Void
    {
        var input = param.input;
        var entity = input.Entity;
        var buffCount = entity.GetBuffCount(DragonToothBuff);
        if (buffCount > 0)
        {
            input.Multiply(Mathf.Pow(DAMAGE_MULTIPLIER, buffCount));
        }
    }
    public static inline var DAMAGE_MULTIPLIER:Float = 2;
    public static var modelKey:NamespaceID = VanillaModelKeys.vulnerable;
}
