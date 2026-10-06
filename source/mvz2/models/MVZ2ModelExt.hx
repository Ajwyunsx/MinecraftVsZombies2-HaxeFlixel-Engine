// Ported from: Assets/Scripts/MVZ2/Models/MVZ2ModelExt.cs
package mvz2.models;

import mvz2logic.Global;
import pvzengine.NamespaceID;
import pvzengine.armors.EngineArmorExt;
using mvz2logic.games.LogicGameDefinitionsExt;  // EXTUSING
using pvzengine.armors.EngineArmorExt;  // EXTUSING
using pvzengine.models.HasModelExt;  // EXTUSING

class MVZ2ModelExt {
    public static function GetAnchorOfArmorSlot(slot:NamespaceID):String {
        var game = Global.Game;
        var slotMeta = game.GetArmorSlotDefinition(slot);
        if (slotMeta == null)
            return null;
        return slotMeta.Anchor;
    }
    public static function CreateArmor(model:Model, anchor:String, slot:NamespaceID, id:NamespaceID):Model {
        var key = EngineArmorExt.GetModelKeyOfArmorSlot(slot);
        return model.CreateChildModel(anchor, key, id);
    }
    public static function RemoveArmor(model:Model, slot:NamespaceID):Bool {
        var key = EngineArmorExt.GetModelKeyOfArmorSlot(slot);
        return model.RemoveChildModel(key);
    }
    public static function GetArmorModel(model:Model, slot:NamespaceID):Model {
        var key = EngineArmorExt.GetModelKeyOfArmorSlot(slot);
        return model.GetChildModel(key);
    }
}
