package unity;

// Minimal UnityEngine.ScriptableObject shim.
class ScriptableObject extends UnityObject {
    public function new() {
        super();
    }
    public static function CreateInstance(type:Class<Dynamic>):Dynamic return Type.createInstance(type, []);
    public static function CreateInstanceOf<T>(type:Class<T>):T return Type.createInstance(type, []);
}
