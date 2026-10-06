package unity.ui;

import unity.Component;

// Minimal UnityEngine.UI.UIBehaviour shim.
class UIBehaviour extends unity.MonoBehaviour {
    // PORT-NOTE: `enabled` 继承自 unity.MonoBehaviour，Haxe 不允许子类重定义变量。
    public var isActiveAndEnabled(get, never):Bool;
    function get_isActiveAndEnabled():Bool {
        return enabled && gameObject != null && gameObject.activeInHierarchy;
    }

    public function new() {
        super();
    }
    public function Awake():Void {}
    public function IsActive():Bool return gameObject != null && gameObject.activeInHierarchy;
    public function OnEnable():Void {}
    public function OnDisable():Void {}
    public function OnRectTransformDimensionsChange():Void {}
    public function OnDidApplyAnimationProperties():Void {}
    public function OnValidate():Void {}
}
