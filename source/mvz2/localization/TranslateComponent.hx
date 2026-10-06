// Ported from: Assets/Scripts/MVZ2/Localization/TranslateComponent.cs
package mvz2.localization;

import mvz2.managers.MainManager;
import unity.Component;
import unity.MonoBehaviour;

// abstract
class TranslateComponent<T:Component> extends MonoBehaviour {
    // PORT-NOTE: Haxe 无法把泛型参数当作 Class 值使用（GetComponent<T>() 等价物），
    // 因此由子类在构造时显式传入组件类型。
    public function new(componentType:Class<T>) {
        super();
        this.componentType = componentType;
    }

    private function OnEnable():Void {
        lang.OnLanguageChanged.add(OnLanguageChangedCallback);
        Translate(lang.GetCurrentLanguage());
    }
    private function OnDisable():Void {
        lang.OnLanguageChanged.remove(OnLanguageChangedCallback);
    }
    // virtual
    private function Translate(language:String):Void {

    }
    private function OnLanguageChangedCallback(language:String):Void {
        Translate(language);
    }
    public var Component(get, never):Null<T>;
    function get_Component():Null<T> {
        if (component == null && gameObject != null) {
            component = gameObject.GetComponent(componentType);
        }
        return component;
    }
    private var lang(get, never):LanguageManager;
    function get_lang():LanguageManager {
        return MainManager.Instance.LanguageManager;
    }
    private var componentType:Class<T>;
    private var component:T;
}
