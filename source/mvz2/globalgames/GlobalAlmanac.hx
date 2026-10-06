package mvz2.globalgames;

import mvz2.managers.MainManager;
import mvz2logic.games.IGlobalAlmanac;
import pvzengine.NamespaceID;

// Ported from: Assets/Scripts/MVZ2/Global/GlobalAlmanac.cs
class GlobalAlmanac implements IGlobalAlmanac {
    public function new(main:MainManager) {
        this.main = main;
    }
    public function IsContraptionInAlmanac(id:NamespaceID):Bool {
        return main.ResourceManager.IsContraptionInAlmanac(id);
    }

    public function IsEnemyInAlmanac(id:NamespaceID):Bool {
        return main.ResourceManager.IsEnemyInAlmanac(id);
    }
    private var main:MainManager;
}
