// Ported from: Assets/Scripts/MVZ2/Localization/TranslateComponentText.cs
package mvz2.localization;

import mukioi18n.ITranslateComponent;
import system.text.StringBuilder;
import unity.Component;
import unity.Transform;

// abstract
class TranslateComponentText<T:Component> extends TranslateComponent<T> implements ITranslateComponent {
    public function new(componentType:Class<T>) {
        super(componentType);
    }

    // virtual
    private function GetKeyInner():String {
        return null;
    }
    // virtual
    private function GetKeysInner():Array<String> {
        return null;
    }
    public var Context(get, never):String;
    function get_Context():String return context;
    public var Comment(get, never):String;
    function get_Comment():String return comment;
    public var Key(get, never):String;
    function get_Key():String {
        if (key == null)
            key = GetKeyInner();
        return key;
    }
    public var Keys(get, never):Array<String>;
    function get_Keys():Array<String> {
        if (keys == null)
            keys = GetKeysInner();
        return keys;
    }
    public var Path(get, never):String;
    function get_Path():String {
        var sb = new StringBuilder();

        var tr:Transform = transform;
        do {
            sb.Insert(0, tr.name);
            sb.Insert(0, "/");
            tr = tr.parent;
        } while (tr != null);

        return sb.ToString();
    }
    private var context:String = null;
    private var comment:String = null;
    private var key:String;
    private var keys:Array<String>;
}
