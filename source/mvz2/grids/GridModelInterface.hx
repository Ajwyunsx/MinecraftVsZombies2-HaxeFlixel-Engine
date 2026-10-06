package mvz2.grids;

import mvz2.models.Model;
import mvz2.models.ModelInterface;

// Ported from: Assets/Scripts/MVZ2/Grids/GridModelInterface.cs
class GridModelInterface extends ModelInterface {
    public function new(ctrl:GridController) {
        super();
        controller = ctrl;
    }
    override function GetModel():Model {
        return controller.GetModel();
    }
    private var controller:GridController;
}
