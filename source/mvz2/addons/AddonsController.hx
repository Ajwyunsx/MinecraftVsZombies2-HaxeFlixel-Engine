package mvz2.addons;

import mvz2.scenes.MainScenePage;
import mvz2.ui.addons.AddonsUI;
import mvz2.localization.LanguagePack;
import mvz2.ui.addons.AddonsUI.AddonsButtonType;

// Ported from: Assets/Scripts/MVZ2/Addons/AddonsController.cs
class AddonsController extends MainScenePage {
    override public function Display():Void {
        super.Display();
        DisplayIndex();
        languagePacks.Hide();
    }
    public function DisplayIndex():Void {
        ui.SetIndexVisible(true);
    }
    public function SetLoadingVisible(visible:Bool):Void {
        ui.SetLoadingVisible(visible);
    }
    private function Awake():Void {
        ui.OnButtonClick.add(OnButtonClickCallback);
    }
    // PORT-NOTE: C# `async void` callback → Void; the awaited task is started without blocking
    // (Haxe has no async/await).
    private function OnButtonClickCallback(button:AddonsButtonType):Void {
        switch (button) {
            case AddonsButtonType.Return:
                Return();
            case AddonsButtonType.LanguagePack:
                ui.SetIndexVisible(false);
                SetLoadingVisible(true);
                // TODO-PORT: `await languagePacks.Display()` requires coroutine restructuring.
                languagePacks.Display();
                SetLoadingVisible(false);
        }
    }

    @:serializeField
    private var ui:AddonsUI = null;
    @:serializeField
    private var languagePacks:LanguagePacksController = null;
}
