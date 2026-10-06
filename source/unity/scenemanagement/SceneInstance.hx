package unity.scenemanagement;

// Minimal UnityEngine.ResourceManagement.ResourceProviders.SceneInstance shim.
// PORT-NOTE: the Haxe port has no additive scenes; an instance is just a named handle that the
// scene loading manager tracks.
class SceneInstance {
    public var name:String;
    public var Scene:Scene;
    public var loaded:Bool = true;

    public function new(?name:String) {
        this.name = name != null ? name : "";
        this.Scene = new Scene(this.name);
    }

    public function IsValid():Bool {
        return loaded && Scene != null && Scene.IsValid();
    }
}

// Minimal UnityEngine.SceneManagement.Scene shim.
class Scene {
    public var name:String;
    public var path:String;
    public var buildIndex:Int = -1;
    public var isLoaded:Bool = false;

    public function new(?name:String) {
        this.name = name != null ? name : "";
        this.path = this.name;
    }

    public function IsValid():Bool {
        return name != null && name.length > 0;
    }
    public function GetRootGameObjects():Array<unity.GameObject> {
        return [];
    }
    public function ToString():String return name;
}
