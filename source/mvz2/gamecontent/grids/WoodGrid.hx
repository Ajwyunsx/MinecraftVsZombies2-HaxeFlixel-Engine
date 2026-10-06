// Ported from: Assets/Scripts/Vanilla/GameContent/Grids/WoodGrid.cs
package mvz2.gamecontent.grids;

import mvz2.gamecontent.grids.VanillaGridID.VanillaGridNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.NamespaceID;
import pvzengine.definitions.GridDefinition;
import pvzengine.entities.Entity;

@:autoGridDefinition(VanillaGridNames.wood)
class WoodGrid extends GridDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function GetPlaceSound(entity:Entity):NamespaceID
    {
        var entitySound = LogicEntityProps.GetPlaceSound(entity);
        if (NamespaceID.IsValid(entitySound))
        {
            return entitySound;
        }
        return VanillaSoundID.wood;
    }
}
