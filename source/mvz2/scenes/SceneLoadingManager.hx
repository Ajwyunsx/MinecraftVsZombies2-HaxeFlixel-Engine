package mvz2.scenes;


import unity.MonoBehaviour;
import unity.Task;
import unity.scenemanagement.LoadSceneMode;
import unity.scenemanagement.SceneInstance;

// Ported from: Assets/Scripts/MVZ2/Scene/SceneLoadingManager.cs
// PORT-NOTE: Addressables/UnityEngine.SceneManagement are replaced by flixel state switching;
// scene instances are tracked by name and the scene reference is a lightweight handle.
class SceneLoadingManager extends MonoBehaviour {
    public function LoadSceneAsync(name:String, mode:LoadSceneMode):Task {
        // TODO-PORT: Additive scene loading has no Flixel equivalent; the scene is registered
        // here and actually entered through FlxG.switchState by the caller.
        var scene = new SceneInstance(name);
        sceneCaches.push(scene);
        return Task.fromResult(scene);
    }
    public function UnloadSceneAsyncByName(name:String):Task {
        var scene = GetSceneInstance(name);
        if (scene != null && scene.IsValid()) {
            return UnloadSceneAsync(scene);
        }
        return Task.completedTask();
    }
    // PORT-NOTE: C# overload `UnloadSceneAsync(SceneInstance)`; Haxe has no overloads.
    public function UnloadSceneAsync(scene:SceneInstance):Task {
        // TODO-PORT: Additive scene unloading has no Flixel equivalent.
        sceneCaches.remove(scene);
        return Task.completedTask();
    }
    public function IsSceneLoaded(name:String):Bool {
        var instance = GetSceneInstance(name);
        return instance != null && instance.IsValid();
    }
    public function GetSceneInstance(name:String):SceneInstance {
        return Lambda.find(sceneCaches, s -> s.name == name);
    }
    private var sceneCaches:Array<SceneInstance> = [];
}
