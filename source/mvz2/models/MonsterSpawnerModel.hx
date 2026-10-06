// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/MonsterSpawnerModel.cs
package mvz2.models;

import pvzengine.NamespaceID;
import Main;  // UNKNOWNIMPORT
import unity.SpriteRenderer;
using pvzengine.ContentProviderHelper;  // EXTUSING

class MonsterSpawnerModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        var currentID:NamespaceID = Model.GetProperty("EntityToSpawn");
        if (entityID != currentID) {
            entityID = currentID;

            var sprite = Main.ResourceManager.GetDefaultSprite();
            var def = Main.Game.GetEntityDefinition(entityID);
            if (def != null) {
                var modelID = def.GetModelID();
                sprite = Main.ResourceManager.GetModelIcon(modelID);
            }
            iconRenderer.sprite = sprite;
        }
    }
    private var iconRenderer:SpriteRenderer = null;
    private var entityID:NamespaceID;
}
