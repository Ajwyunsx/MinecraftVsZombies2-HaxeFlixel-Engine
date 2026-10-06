// Ported from: Assets/Scripts/MVZ2/Localization/TranslateComponentSprite.cs
package mvz2.localization;

import unity.Component;
import unity.Sprite;

// abstract
class TranslateComponentSprite<T:Component> extends TranslateComponent<T> {
    public function new(componentType:Class<T>) {
        super(componentType);
    }

    // virtual
    private function GetKeyInner():Sprite {
        return null;
    }
    public var Key(get, never):Sprite;
    function get_Key():Sprite {
        if (key == null)
            key = GetKeyInner();
        return key;
    }
    private var key:Sprite;
}

// abstract
class TranslateComponentSpriteMultiple<T:Component> extends TranslateComponent<T> {
    public function new(componentType:Class<T>) {
        super(componentType);
    }

    // virtual
    private function GetKeysInner():Array<Sprite> {
        return null;
    }
    public var Keys(get, never):Array<Sprite>;
    function get_Keys():Array<Sprite> {
        if (keys == null)
            keys = GetKeysInner();
        return keys;
    }
    private var keys:Array<Sprite>;
}
