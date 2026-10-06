package mvz2.entities;

import mvz2.models.Model;
import mvz2.models.ModelInterface;

// Ported from: Assets/Scripts/MVZ2/Entities/EntityModelInterface.cs
// abstract
class EntityModelInterface extends ModelInterface {
    public function new(ctrl:EntityController) {
        super();
        this.controller = ctrl;
    }
    // PORT-NOTE: C# protected field; Haxe fields are private by default, access is kept internal
    // to the subclasses that live in this package.
    private var controller:EntityController;
}
