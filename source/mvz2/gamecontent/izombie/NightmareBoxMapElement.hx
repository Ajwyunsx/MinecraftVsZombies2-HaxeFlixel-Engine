// Ported from: Assets/Scripts/Vanilla/GameContent/Maps/NightmareBoxMapElement.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.maps.VanillaMapElementBehaviourNames;
import mvz2logic.Global;
import mvz2logic.maps.IMapElement;
import mvz2logic.maps.MapElementBehaviourDefinition;
import mvz2logic.saves.LogicSaveExt;

@:autoMapElementBehaviourDefinition(VanillaMapElementBehaviourNames.nightmareBox)
class NightmareBoxMapElement extends MapElementBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function OnClick(element:IMapElement):Void
    {
        var map = element.Map;
        LogicSaveExt.SetDreamIsNightmare(Global.Saves, !LogicSaveExt.DreamIsNightmare(Global.Saves));
        map.ChangeMap(map.GetMapID());
    }
}
