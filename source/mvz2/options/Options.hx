// Ported from: Assets/Scripts/MVZ2/Options/Options.cs
package mvz2.options;

import mvz2logic.options.LogicOptionItemID;
import pvzengine.NamespaceID;

class Options {
    public function new() {
        keyBindings = new KeyBindingOptions();
    }
    public function SetOptionBool(id:NamespaceID, value:Bool):Void {
        boolOptions.set(id, value);
    }
    public function SetOptionInt(id:NamespaceID, value:Int):Void {
        intOptions.set(id, value);
    }
    public function SetOptionFloat(id:NamespaceID, value:Float):Void {
        floatOptions.set(id, value);
    }
    public function SetOptionString(id:NamespaceID, value:String):Void {
        stringOptions.set(id, value);
    }
    public function SetOptionID(id:NamespaceID, value:NamespaceID):Void {
        idOptions.set(id, value);
    }
    public function ContainsOptionBool(id:NamespaceID):Bool {
        return boolOptions.exists(id);
    }
    public function ContainsOptionInt(id:NamespaceID):Bool {
        return intOptions.exists(id);
    }
    public function ContainsOptionFloat(id:NamespaceID):Bool {
        return floatOptions.exists(id);
    }
    public function ContainsOptionString(id:NamespaceID):Bool {
        return stringOptions.exists(id);
    }
    public function ContainsOptionID(id:NamespaceID):Bool {
        return idOptions.exists(id);
    }
    // PORT-NOTE: C# 的 out 参数在 Haxe 中改为返回值：找不到时返回 null。
    public function TryGetOptionBool(id:NamespaceID):Null<Bool> {
        return boolOptions.exists(id) ? boolOptions.get(id) : null;
    }
    public function TryGetOptionInt(id:NamespaceID):Null<Int> {
        return intOptions.exists(id) ? intOptions.get(id) : null;
    }
    public function TryGetOptionFloat(id:NamespaceID):Null<Float> {
        return floatOptions.exists(id) ? floatOptions.get(id) : null;
    }
    public function TryGetOptionString(id:NamespaceID):Null<String> {
        return stringOptions.exists(id) ? stringOptions.get(id) : null;
    }
    public function TryGetOptionID(id:NamespaceID):Null<NamespaceID> {
        return idOptions.exists(id) ? idOptions.get(id) : null;
    }
    public function ToSerializable():SerializableOptionsV1 {
        var seri = new SerializableOptionsV1();
        seri.keyBindings = keyBindings.ToSerializable();
        seri.boolOptions = new Map();
        for (key in boolOptions.keys()) {
            seri.boolOptions.set(key.toString(), boolOptions.get(key));
        }
        seri.intOptions = new Map();
        for (key in intOptions.keys()) {
            seri.intOptions.set(key.toString(), intOptions.get(key));
        }
        seri.floatOptions = new Map();
        for (key in floatOptions.keys()) {
            seri.floatOptions.set(key.toString(), floatOptions.get(key));
        }
        seri.stringOptions = new Map();
        for (key in stringOptions.keys()) {
            seri.stringOptions.set(key.toString(), stringOptions.get(key));
        }
        seri.idOptions = new Map();
        for (key in idOptions.keys()) {
            var value = idOptions.get(key);
            seri.idOptions.set(key.toString(), value != null ? value.toString() : null);
        }
        return seri;
    }
    public function LoadFromSerializableV0(options:SerializableOptions):Void {
        if (options == null)
            return;
        if (options.keyBindings != null)
            keyBindings.LoadFromSerializable(options.keyBindings);
        if (options.hpBar != null) {
            var hpBar = new HPBarOptions();
            hpBar.LoadFromSerializable(options.hpBar);
            SetOptionBool(LogicOptionItemID.hpBarEnabled, hpBar.enabled);
            SetOptionBool(LogicOptionItemID.hpBarAutoHide, hpBar.autoHide);
            SetOptionInt(LogicOptionItemID.hpBarAmountMode, hpBar.amountMode);
            SetOptionFloat(LogicOptionItemID.hpBarHoverDisplayRange, hpBar.hoverDisplayRange);
        }
        SetOptionBool(LogicOptionItemID.skipTalks, options.skipAllTalks);
        SetOptionBool(LogicOptionItemID.showSponsorNames, options.showSponsorNames);
        SetOptionBool(LogicOptionItemID.blueprintWarnings, !options.blueprintWarningsDisabled);
        SetOptionInt(LogicOptionItemID.commandBlockMode, options.commandBlockMode);
        SetOptionInt(LogicOptionItemID.fpsMode, options.fpsMode);
        SetOptionBool(LogicOptionItemID.showHotkeys, options.showHotkeyIndicators);
        SetOptionBool(LogicOptionItemID.hdrLighting, !options.hdrLightingDisabled);
        SetOptionBool(LogicOptionItemID.heightIndicator, options.heightIndicatorEnabled);
    }
    public function LoadFromSerializableV1(options:SerializableOptionsV1):Void {
        if (options == null)
            return;
        if (options.keyBindings != null)
            keyBindings.LoadFromSerializable(options.keyBindings);
        if (options.boolOptions != null) {
            for (key in options.boolOptions.keys()) {
                boolOptions.set(NamespaceID.ParseStrict(key), options.boolOptions.get(key));
            }
        }
        if (options.intOptions != null) {
            for (key in options.intOptions.keys()) {
                intOptions.set(NamespaceID.ParseStrict(key), options.intOptions.get(key));
            }
        }
        if (options.floatOptions != null) {
            for (key in options.floatOptions.keys()) {
                floatOptions.set(NamespaceID.ParseStrict(key), options.floatOptions.get(key));
            }
        }
        if (options.stringOptions != null) {
            for (key in options.stringOptions.keys()) {
                stringOptions.set(NamespaceID.ParseStrict(key), options.stringOptions.get(key));
            }
        }
        if (options.idOptions != null) {
            for (key in options.idOptions.keys()) {
                var value:NamespaceID = null;
                var raw = options.idOptions.get(key);
                if (raw != null) {
                    value = NamespaceID.ParseStrict(raw);
                }
                idOptions.set(NamespaceID.ParseStrict(key), value);
            }
        }
    }
    public var keyBindings:KeyBindingOptions;
    public var boolOptions:Map<NamespaceID, Bool> = new Map();
    public var intOptions:Map<NamespaceID, Int> = new Map();
    public var floatOptions:Map<NamespaceID, Float> = new Map();
    public var stringOptions:Map<NamespaceID, String> = new Map();
    public var idOptions:Map<NamespaceID, NamespaceID> = new Map();
}
