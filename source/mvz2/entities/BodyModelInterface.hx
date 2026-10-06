package mvz2.entities;

import mvz2.models.Model;

// Ported from: Assets/Scripts/MVZ2/Entities/BodyModelInterface.cs
class BodyModelInterface extends EntityModelInterface {
    public function new(ctrl:EntityController) {
        super(ctrl);
    }
    override function GetModel():Model {
        return controller.Model;
    }
}
