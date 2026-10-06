// Ported from: Assets/Scripts/Vanilla/GameContent/Maps/PinMapElement.cs
package mvz2.gamecontent.izombie;

import mvz2.gamecontent.maps.VanillaMapElementBehaviourNames;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.Global;
import mvz2logic.maps.IMapElement;
import mvz2logic.maps.MapElementBehaviourDefinition;
import pvzengine.NamespaceID;

@:autoMapElementBehaviourDefinition(VanillaMapElementBehaviourNames.pin)
class PinMapElement extends MapElementBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function OnClick(element:IMapElement):Void
    {
        var map = element.Map;
        if (IsToStore(element))
        {
            var mapID = map.GetMapID();
            Global.Scene.GotoStore(() -> Global.Scene.GotoMap(mapID), true);
            return;
        }
        var targetMap = GetTargetMapID(element);
        if (NamespaceID.IsValid(targetMap))
        {
            map.ChangeMap(targetMap);
        }
    }
    public static function IsToStore(element:IMapElement):Bool return element.GetProperty(PROP_TO_STORE);
    public static function SetToStore(element:IMapElement, value:Bool):Void element.SetProperty(PROP_TO_STORE, value);
    public static function GetTargetMapID(element:IMapElement):Null<NamespaceID> return element.GetProperty(PROP_TARGET_MAP_ID);
    public static function SetTargetMapID(element:IMapElement, value:Null<NamespaceID>):Void element.SetProperty(PROP_TARGET_MAP_ID, value);
    public static var PROP_TO_STORE:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("to_store");
    public static var PROP_TARGET_MAP_ID:VanillaEntityPropertyMeta<NamespaceID> = new VanillaEntityPropertyMeta<NamespaceID>("target_map_id");
}
