// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/BlueprintPickup/BlueprintPickup.cs
package mvz2.gamecontent.pickups;

import mvz2.gamecontent.helditems.VanillaHeldTypes;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.pickups.VanillaPickupProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.blueprints.SeedTypes;
import mvz2logic.level.LogicHeldItemProps;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.seedpacks.SeedDefinition;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.pickups.VanillaPickupProps;
using mvz2logic.blueprints.LogicSeedProps;

@:autoEntityBehaviourDefinition(VanillaPickupNames.blueprintPickup)
class BlueprintPickup extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        UpdateModel(entity);
    }
    public override function Update(pickup:Entity):Void
    {
        super.Update(pickup);
        UpdateModel(pickup);
    }
    public static function GetSeedDefinition(pickup:Entity):Null<SeedDefinition>
    {
        if (!pickup.IsBlueprintPickup())
            return null;
        var seedID = GetBlueprintID(pickup);
        if (seedID == null)
            return null;
        var seedDef = pickup.Level.Content.GetSeedDefinition(seedID);
        if (seedDef == null)
            return null;
        return seedDef;
    }
    public static function GetSeedEntityID(pickup:Entity):Null<NamespaceID>
    {
        var seedDef = GetSeedDefinition(pickup);
        if (seedDef == null)
            return null;
        if (seedDef.GetSeedType() != SeedTypes.ENTITY)
            return null;
        return seedDef.GetSeedEntityID();
    }
    private static function UpdateModel(pickup:Entity):Void
    {
        var level = pickup.Level;
        var heldItemData = level.GetHeldItemData();
        var isHolding = heldItemData != null && heldItemData.Type == VanillaHeldTypes.blueprintPickup && heldItemData.GetEntityID() == pickup.ID;
        pickup.SetModelProperty("CommandBlock", IsCommandBlock(pickup));
        pickup.SetAnimationBool("HideEnergy", true);
        pickup.SetAnimationBool("Dark", pickup.Timeout < 100 && pickup.Timeout % 20 < 10 && !isHolding);
        pickup.SetAnimationBool("Selected", isHolding);
    }

    public static function GetBlueprintID(pickup:Entity):Null<NamespaceID> return pickup.GetPickupContentID();
    public static function SetBlueprintID(pickup:Entity, id:NamespaceID):Void pickup.SetPickupContentID(id);
    public static function IsCommandBlock(pickup:Entity):Bool return pickup.GetBehaviourField(PROP_COMMAND_BLOCK);
    public static function SetCommandBlock(pickup:Entity, value:Bool):Void pickup.SetBehaviourField(PROP_COMMAND_BLOCK, value);
    public static function IgnoresTouchRaycast(pickup:Entity):Bool return pickup.GetBehaviourField(PROP_IGNORE_TOUCH_RAYCAST);
    public static function SetIgnoreTouchRaycast(pickup:Entity, value:Bool):Void pickup.SetBehaviourField(PROP_IGNORE_TOUCH_RAYCAST, value);

    public static var PROP_COMMAND_BLOCK:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("CommandBlock");
    public static var PROP_IGNORE_TOUCH_RAYCAST:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("IgnoreRaycast");
}
