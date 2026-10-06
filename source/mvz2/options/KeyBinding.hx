// Ported from: Assets/Scripts/MVZ2/Options/KeyBinding.cs
package mvz2.options;

import pvzengine.NamespaceID;
import unity.KeyCode;

class KeyBindingMeta {
    public function new(id:NamespaceID, defaultCode:KeyCode, name:String) {
        ID = id;
        Name = name;
        DefaultCode = defaultCode;
    }
    public var ID(default, null):NamespaceID;
    public var Name(default, null):String;
    public var DefaultCode(default, null):KeyCode;
}
