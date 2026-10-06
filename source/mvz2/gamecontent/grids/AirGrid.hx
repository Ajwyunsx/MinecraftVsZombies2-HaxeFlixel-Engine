// Ported from: Assets/Scripts/Vanilla/GameContent/Grids/AirGrid.cs
package mvz2.gamecontent.grids;

import mvz2.gamecontent.grids.VanillaGridID.VanillaGridNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.entities.LogicEntityProps;
import mvz2logic.grids.LogicGridProps;
import pvzengine.NamespaceID;
import pvzengine.definitions.GridDefinition;
import pvzengine.entities.Entity;

@:autoGridDefinition(VanillaGridNames.air)
class AirGrid extends GridDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        SetProperty(LogicGridProps.IS_AIR, true);
    }

    public override function GetPlaceSound(entity:Entity):NamespaceID
    {
        var entitySound = LogicEntityProps.GetPlaceSound(entity);
        if (NamespaceID.IsValid(entitySound))
        {
            return entitySound;
        }
        return VanillaSoundID.cloth;
    }
}
