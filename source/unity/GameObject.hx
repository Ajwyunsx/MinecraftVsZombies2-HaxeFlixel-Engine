package unity;

import flixel.group.FlxGroup;

// Minimal UnityEngine.GameObject shim (composes a FlxGroup).
class GameObject extends UnityObject {
    public var active:Bool = true;
    public var activeSelf(get, never):Bool;
    function get_activeSelf():Bool return active;
    public var activeInHierarchy(get, never):Bool;
    function get_activeInHierarchy():Bool return active && (transform == null || transform.parent == null || transform.parent.gameObject.activeInHierarchy);
    public var layer:Int = 0;
    public var tag:String = "Untagged";
    public var transform:Transform;
    public var scene:Dynamic = null;

    private var components:Array<Component> = [];

    public function new(?name:String) {
        super();
        this.name = name != null ? name : "GameObject";
        transform = new Transform();
        transform.gameObject = this;
    }

    public function SetActive(value:Bool):Void {
        active = value;
    }

    // PORT-NOTE: 泛型参数不加 `:Component` 约束，以便查询接口类型（如 IModelComponent）。
    public function AddComponent<T>(type:Class<T>):T {
        var c:Dynamic = Type.createInstance(type, []);
        c.gameObject = this;
        c.transform = transform;
        components.push(c);
        // PORT-NOTE: 渲染桥的登记点。Unity 的 AddComponent 会把组件交给引擎（渲染器自动参与绘制），
        // 移植层没有引擎，改为在这里显式登记 SpriteRenderer，由 RenderBridge 每帧同步
        // transform/enabled 到 renderSprite（见 unity/RenderBridge.hx）。
        if (Std.isOfType(c, SpriteRenderer))
            RenderBridge.registerRenderer(cast c);
        // PORT-NOTE: 协程驱动登记点。Unity 由引擎推进场景内**全部** MonoBehaviour 的协程；
        // 移植层原先只有 `MainGameScene.behaviours`（手工 new + attach 的那批）被驱动，
        // 于是 `ScenePrefabLoader` 用 AddComponent 建出来的关卡场景树 / 页面 prefab 子树的协程
        // 永远不会恢复。这里补上同一个登记点（见 unity/BehaviourRegistry.hx）。
        BehaviourRegistry.register(c);
        return c;
    }
    public function GetComponent<T>(type:Class<T>):T {
        if (transform != null && Std.isOfType(transform, type)) return cast transform;
        for (c in components) {
            if (Std.isOfType(c, type)) return cast c;
        }
        return null;
    }
    public function GetComponents<T>(type:Class<T>):Array<T> {
        var result:Array<T> = [];
        for (c in components) {
            if (Std.isOfType(c, type)) result.push(cast c);
        }
        return result;
    }
    public function GetComponentInChildren<T>(type:Class<T>, ?includeInactive:Bool = false):T {
        var c = GetComponent(type);
        if (c != null) return c;
        for (child in transform.children) {
            if (!includeInactive && !child.gameObject.active) continue;
            c = child.gameObject.GetComponentInChildren(type, includeInactive);
            if (c != null) return c;
        }
        return null;
    }
    public function GetComponentsInChildren<T>(type:Class<T>, ?includeInactive:Bool = false):Array<T> {
        var result = GetComponents(type);
        for (child in transform.children) {
            if (!includeInactive && !child.gameObject.active) continue;
            result = result.concat(child.gameObject.GetComponentsInChildren(type, includeInactive));
        }
        return result;
    }
    public function GetComponentInParent<T>(type:Class<T>):T {
        var c = GetComponent(type);
        if (c != null) return c;
        if (transform.parent != null) return transform.parent.gameObject.GetComponentInParent(type);
        return null;
    }
    public function GetComponentsInParent<T>(type:Class<T>, ?includeInactive:Bool = false):Array<T> {
        var result = GetComponents(type);
        if (transform.parent != null) result = result.concat(transform.parent.gameObject.GetComponentsInParent(type, includeInactive));
        return result;
    }
    public function CompareTag(t:String):Bool return tag == t;

    // PORT-NOTE: Unity 的 GameObject 本身没有 gameObject 属性（那是 Component.gameObject）。
    // 移植层若干字段（如 MainmenuUI.backgroundLight、MiscAlmanacPage.entryImageRegion）在 C# 里是
    // Component/RectTransform，移植后类型放宽成了 GameObject，调用点仍写 `.gameObject.SetActive(...)`。
    // 为保持调用点与 C# 一致，这里提供返回自身的自引用。
    public var gameObject(get, never):GameObject;
    function get_gameObject():GameObject return this;

    // PORT-NOTE: exposes the attached components so that shims (e.g. unity.Physics) can
    // dispatch Unity lifecycle messages such as OnTriggerStay.
    public function GetAllComponents():Array<Component> return components;

    public static function instantiate<T:UnityObject>(original:T, ?parent:Transform):T {
        // PORT-NOTE: real prefab instantiation is handled by factories in game code.
        return original;
    }
    public static function find(name:String):GameObject {
        return null; // TODO-PORT: scene-wide lookup requires a scene registry.
    }
}
