// Ported from: Assets/Scripts/Vanilla/GameContent/Placements/VanillaPlacementProps.cs
package mvz2.gamecontent.placements;

import pvzengine.NamespaceID;
import pvzengine.PropertyMeta;
import pvzengine.PropertyRegions;
import pvzengine.placements.PlacementDefinition;

@:propertyRegistryRegion(PropertyRegions.placement)
class VanillaPlacementProps
{
    public static var ALMANAC_TAG:PropertyMeta<NamespaceID> = new PropertyMeta<NamespaceID>("almanacTag");
    // C#: extension method GetAlmanacTag(this PlacementDefinition definition)
    public static function GetAlmanacTag(definition:PlacementDefinition):Null<NamespaceID>
    {
        return definition.GetProperty(ALMANAC_TAG);
    }
    // C#: extension method SetAlmanacTag(this PlacementDefinition definition, NamespaceID? value)
    public static function SetAlmanacTag(definition:PlacementDefinition, value:Null<NamespaceID>):Void
    {
        definition.SetProperty(ALMANAC_TAG, value);
    }
}
