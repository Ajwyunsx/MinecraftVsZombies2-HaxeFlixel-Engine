// Ported from: Assets/Scripts/MVZ2/Models/Components/Pickup/ArtifactPickupModel.cs
package mvz2.models;

import pvzengine.NamespaceID;
import Main;  // UNKNOWNIMPORT
import unity.SpriteRenderer;
using mvz2logic.artifacts.LogicArtifactProps;  // EXTUSING
using mvz2logic.games.LogicGameDefinitionsExt;  // EXTUSING

class ArtifactPickupModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        var artifactID:NamespaceID = Model.GetProperty("ContentID");
        if (lastID != artifactID) {
            lastID = artifactID;
            var artifactDef = Main.Game.GetArtifactDefinition(artifactID);
            if (artifactDef == null)
                return;
            var sprRef = artifactDef.GetSpriteReference();
            artifactSprite.sprite = Main.GetFinalSpriteFromRef(sprRef);
        }
    }
    private var artifactSprite:SpriteRenderer = null;
    private var lastID:NamespaceID;
}
