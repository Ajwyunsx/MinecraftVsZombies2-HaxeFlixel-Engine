package unity;

// Minimal UnityEngine.Component shim.
class Component extends UnityObject {
    public var gameObject:GameObject;
    public var transform:Transform;
    public var tag(get, set):String;
    function get_tag():String return gameObject != null ? gameObject.tag : "";
    function set_tag(v:String):String {
        if (gameObject != null) gameObject.tag = v;
        return v;
    }

    public function new() {
        super();
    }

    // PORT-NOTE: 泛型参数不加 `:Component` 约束，以便查询接口类型（如 IModelComponent）。
    public function GetComponent<T>(type:Class<T>):T return gameObject.GetComponent(type);
    public function GetComponents<T>(type:Class<T>):Array<T> return gameObject.GetComponents(type);
    public function GetComponentInChildren<T>(type:Class<T>, ?includeInactive:Bool = false):T return gameObject.GetComponentInChildren(type, includeInactive);
    public function GetComponentsInChildren<T>(type:Class<T>, ?includeInactive:Bool = false):Array<T> return gameObject.GetComponentsInChildren(type, includeInactive);
    public function GetComponentInParent<T>(type:Class<T>):T return gameObject.GetComponentInParent(type);
    public function GetComponentsInParent<T>(type:Class<T>, ?includeInactive:Bool = false):Array<T> return gameObject.GetComponentsInParent(type, includeInactive);
}
