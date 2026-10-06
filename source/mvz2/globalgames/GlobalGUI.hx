package mvz2.globalgames;

import mvz2.managers.MainManager;
import mvz2logic.games.IGlobalGUI;

// Ported from: Assets/Scripts/MVZ2/Global/GlobalGUI.cs
class GlobalGUI implements IGlobalGUI {
    public function new(main:MainManager) {
        this.main = main;
    }
    public function ShowDialog(title:String, desc:String, options:Array<String>, onSelect:Int->Void = null):Void {
        main.Scene.ShowDialog(title, desc, options, onSelect);
    }
    private var main:MainManager;
}
