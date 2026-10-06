// Ported from: Assets/Scripts/Vanilla/GameContent/Grids/StoneSlabGrid.cs
package mvz2.gamecontent.grids;

import mvz2.gamecontent.grids.VanillaGridID.VanillaGridNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.grids.LogicGridProps;
import pvzengine.NamespaceID;
import pvzengine.definitions.GridDefinition;
import pvzengine.entities.Entity;

@:autoGridDefinition(VanillaGridNames.stoneSlab)
class StoneSlabGrid extends GridDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        SetProperty(LogicGridProps.IS_SLAB, true);
    }
    public override function GetPlaceSound(entity:Entity):NamespaceID
    {
        var entitySound = LogicEntityProps.GetPlaceSound(entity);
        if (NamespaceID.IsValid(entitySound))
        {
            return entitySound;
        }
        return VanillaSoundID.stone;
    }
}
