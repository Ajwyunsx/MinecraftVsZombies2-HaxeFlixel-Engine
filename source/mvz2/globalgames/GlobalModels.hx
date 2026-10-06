package mvz2.globalgames;

import mvz2.managers.MainManager;
import mvz2logic.games.IGlobalModels;
import pvzengine.NamespaceID;

// Ported from: Assets/Scripts/MVZ2/Global/GlobalModels.cs
class GlobalModels implements IGlobalModels {
    public function new(main:MainManager) {
        this.main = main;
    }
    public function ModelExists(id:NamespaceID):Bool {
        return main.ResourceManager.GetModelMeta(id) != null;
    }
    private var main:MainManager;
}
