// Ported from: Assets/Scripts/Vanilla/GameContent/Grids/WaterGrid.cs
package mvz2.gamecontent.grids;

import mvz2.gamecontent.grids.VanillaGridID.VanillaGridNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.grids.LogicGridProps;
import pvzengine.NamespaceID;
import pvzengine.definitions.GridDefinition;
import pvzengine.entities.Entity;

@:autoGridDefinition(VanillaGridNames.water)
class WaterGrid extends GridDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        SetProperty(LogicGridProps.IS_WATER, true);
    }

    public override function GetPlaceSound(entity:Entity):NamespaceID
    {
        return VanillaSoundID.water;
    }
}
