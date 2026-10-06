// Ported from: Assets/Scripts/MVZ2/Models/Utilities/ModelFactory.cs
package mvz2.models;
import mvz2.models.ModelFactories.IModelFactory;  // IMPORTAUTO

import mvz2.models.Model;
import pvzengine.NamespaceID;
import unity.Camera;
import unity.Transform;

class ModelFactory implements IModelFactory {
    public function new() {
    }
    // PORT-NOTE: IModelFactory 的签名为 (id:Null<NamespaceID>, camera, parent, ?seed:Int)，这里对齐。
    public function CreateModel(id:Null<NamespaceID>, camera:Camera, parent:Transform, ?seed:Int = 0):Null<Model> {
        var builder = new ModelBuilder(id, camera, seed);
        return builder.Build(parent);
    }
}
