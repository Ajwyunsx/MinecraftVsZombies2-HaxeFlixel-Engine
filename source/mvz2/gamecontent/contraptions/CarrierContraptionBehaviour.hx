// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Common/CarrierContraptionBehaviour.cs
package mvz2.gamecontent.contraptions;

import mvz2.vanilla.contraptions.VanillaContraptionExt;
import pvzengine.NamespaceID;
import pvzengine.auras.AuraEffect;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.auras.IBuffTarget;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.contraptions.VanillaContraptionExt;
using mvz2logic.entities.LogicEntityProps;

// abstract
class CarrierContraptionBehaviour extends EntityBehaviourDefinition implements ICarrierBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddAura(new PassengerAura(GetPassenagerBuffID()));
        AddAura(new CarrierAura(GetCarrierBuffID()));
    }
    public function UpdateCarrier(carrier:Entity):Void
    {
        for (aura in carrier.GetAuraEffects())
        {
            aura.UpdateAura();
        }
    }
    function GetCarrierBuffID():NamespaceID throw "abstract"; // abstract
    function GetPassenagerBuffID():NamespaceID throw "abstract"; // abstract
}

// PORT-NOTE: C# 的嵌套私有类 CarrierAura 提升为同模块的模块级私有类（Haxe 不支持嵌套类）。
private class CarrierAura extends AuraEffectDefinition
{
    public function new(buffID:NamespaceID)
    {
        super(buffID);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var sourceEnt = auraEffect.Source.GetEntity();
        if (sourceEnt != null && sourceEnt.HasPassenger())
        {
            results.push(sourceEnt);
        }
    }
}

// PORT-NOTE: C# 的嵌套私有类 PassengerAura 提升为同模块的模块级私有类（Haxe 不支持嵌套类）。
private class PassengerAura extends AuraEffectDefinition
{
    public function new(buffID:NamespaceID)
    {
        super(buffID);
    }
    public override function GetAuraTargets(auraEffect:AuraEffect, results:Array<IBuffTarget>):Void
    {
        var sourceEnt = auraEffect.Source.GetEntity();
        if (sourceEnt == null)
            return;
        var grids = sourceEnt.GetGridsToTake();
        for (grid in grids)
        {
            if (grid == null)
                continue;
            for (layer in grid.GetLayers())
            {
                var others = grid.GetLayerEntities(layer);
                for (other in others)
                {
                    if (other != null && other != sourceEnt)
                        results.push(other);
                }
            }
        }
    }
}
