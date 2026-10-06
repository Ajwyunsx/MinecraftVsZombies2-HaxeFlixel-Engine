package mvz2.helditems;

import mvz2.level.LevelController;
import mvz2.models.Model;
import mvz2.models.ModelInterface;

// Ported from: Assets/Scripts/MVZ2/HeldItems/HeldItemModelInterface.cs
class HeldItemModelInterface extends ModelInterface {
    public function new(level:LevelController) {
        super();
        this.level = level;
    }
    override private function GetModel():Model {
        return level.GetHeldItemModel();
    }

    private var level:LevelController;
}
