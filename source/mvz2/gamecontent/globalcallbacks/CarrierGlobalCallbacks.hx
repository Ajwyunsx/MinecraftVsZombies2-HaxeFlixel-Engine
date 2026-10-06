// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/CarrierGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2.gamecontent.contraptions.ICarrierBehaviour;
import mvz2.vanilla.grids.VanillaGridExt;
import mvz2logic.modding.Mod;
import pvzengine.callbacks.CallbackResult;
import pvzengine.callbacks.EntityCallbackParams;
import pvzengine.callbacks.LevelCallbacks;
import pvzengine.entities.EntityTypes;
import pvzengine.grids.LawnGrid;

@:modGlobalCallbacks
class CarrierGlobalCallbacks extends VanillaGlobalCallbacks
{
    public override function Apply(mod:Mod):Void
    {
        mod.AddTrigger(LevelCallbacks.POST_ENTITY_INIT, EntityInitCallback, 0, EntityTypes.PLANT);
    }
    function EntityInitCallback(param:EntityCallbackParams, result:CallbackResult):Void
    {
        var entity = param.entity;
        gridBuffer = [];
        entity.GetTakenGridsNonAlloc(gridBuffer);
        for (grid in gridBuffer)
        {
            var carrier = VanillaGridExt.GetCarrierEntity(grid);
            if (carrier == null)
                continue;
            for (carrierBehaviour in carrier.Definition.GetBehaviours())
            {
                if (!Std.isOfType(carrierBehaviour, ICarrierBehaviour))
                    continue;
                var behaviour:ICarrierBehaviour = cast carrierBehaviour;
                behaviour.UpdateCarrier(carrier);
            }
        }
    }
    static var gridBuffer:Array<LawnGrid> = [];
}
