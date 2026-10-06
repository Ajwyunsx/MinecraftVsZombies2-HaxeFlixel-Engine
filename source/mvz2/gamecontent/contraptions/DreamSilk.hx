// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter2/DreamSilk.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.buffs.contraptions.DreamSilkBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.grids.VanillaGridLayers;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.grids.LogicGridExt;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.dreamSilk)
class DreamSilk extends ContraptionBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(silk:Entity):Void
    {
        super.Init(silk);
        silk.PlaySound(VanillaSoundID.sparkle);
        var grid = silk.GetGrid();
        if (grid != null)
        {
            var layers = grid.GetLayers();
            var orderedLayers = VanillaGridLayers.dreamSilkLayers;
            for (layer in orderedLayers)
            {
                var entity = grid.GetLayerEntity(layer);
                if (entity == null || !CanSleep(entity))
                    continue;
                entity.AddBuff(DreamSilkBuff);
                break;
            }
        }
    }
    public static function CanSleep(entity:Entity):Bool
    {
        if (!entity.ExistsAndAlive())
            return false;
        if (entity.Type != EntityTypes.PLANT)
            return false;
        if (entity.IsAIFrozen())
            return false;
        if (!entity.CanDeactive())
            return false;
        if (!entity.IsFriendlyEntity())
            return false;
        return true;
    }
    public override function CanEvoke(entity:Entity):Bool
    {
        return false;
    }
}
