package mvz2.blueprints;

import mvz2.level.BlueprintController;
import mvz2.models.Model;
import mvz2.models.ModelInterface;

// Ported from: Assets/Scripts/MVZ2/SeedPacks/BlueprintModelInterface.cs
class BlueprintModelInterface extends ModelInterface {
    public function new(ctrl:BlueprintController) {
        super();
        controller = ctrl;
    }
    override private function GetModel():Model {
        return controller.GetModel();
    }
    private var controller:BlueprintController;
}
