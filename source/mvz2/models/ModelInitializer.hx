// Ported from: Assets/Scripts/MVZ2/Models/Utilities/ModelInitializer.cs
package mvz2.models;

import mvz2.models.Model;
import pvzengine.NamespaceID;
import tools.ObjectExtensions;
import unity.Camera;
using pvzengine.PropertyKeyHelper;  // EXTUSING

class ModelInitializer extends unity.MonoBehaviour {
    public function new() {
        super();
    }

    function Awake():Void {
        if (model.Exists() && NamespaceID.IsValid(modelID) && modelCamera.Exists()) {
            model.Init(modelID, modelCamera);
        }
    }

    public var model:Model;
    public var modelID:NamespaceID;
    public var modelCamera:Camera;
}
