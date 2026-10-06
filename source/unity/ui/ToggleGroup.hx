package unity.ui;

// Minimal UnityEngine.UI.ToggleGroup shim.
class ToggleGroup extends UIBehaviour {
    public var allowSwitchOff:Bool = false;
    public var toggles:Array<Toggle> = [];

    public function new() {
        super();
    }

    public function SetAllTogglesOff(?sendCallback:Bool = true):Void {
        for (toggle in toggles) {
            if (toggle == null) continue;
            if (sendCallback) toggle.isOn = false;
            else toggle.SetIsOnWithoutNotify(false);
        }
    }
    public function RegisterToggle(toggle:Toggle):Void {
        if (toggle != null && !toggles.contains(toggle)) toggles.push(toggle);
    }
    public function UnregisterToggle(toggle:Toggle):Void {
        toggles.remove(toggle);
    }
    public function NotifyToggleOn(toggle:Toggle, ?sendCallback:Bool = true):Void {}
    public function GetFirstActiveToggle():Toggle {
        for (toggle in toggles) {
            if (toggle != null && toggle.isOn) return toggle;
        }
        return null;
    }
    public function AnyTogglesOn():Bool return GetFirstActiveToggle() != null;
    public function ActiveToggles():Array<Toggle> return toggles;
}
