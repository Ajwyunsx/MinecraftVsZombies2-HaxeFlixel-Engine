package unity.ui;

import unity.Color;
import unity.eventsystems.AxisEventData;
import unity.eventsystems.BaseEventData;
import unity.eventsystems.PointerEventData;

// Minimal UnityEngine.UI.Selectable shim.
class Selectable extends UIBehaviour {
    public static var allSelectablesArray:Array<Selectable> = [];

    public var navigation:Navigation = new Navigation();
    public var transition:Transition = Transition.ColorTint;
    public var colors:ColorBlock = new ColorBlock();
    public var spriteState:SpriteState = new SpriteState();
    public var animationTriggers:Dynamic;
    public var targetGraphic:Graphic;
    public var interactable:Bool = true;
    public var image(get, set):Graphic;
    function get_image():Graphic return targetGraphic;
    function set_image(v:Graphic):Graphic {
        targetGraphic = v;
        return v;
    }
    public var animator:Dynamic;
    // PORT-NOTE: `enabled` 继承自 unity.MonoBehaviour，Haxe 不允许子类重定义变量。

    public function new() {
        super();
    }

    public function IsInteractable():Bool return interactable && enabled;
    public function IsHighlighted():Bool return false;
    public function IsPressed():Bool return false;
    public function FindSelectable(direction:unity.Vector3):Selectable return null;
    public function Select():Void {}
    public function OnMove(eventData:AxisEventData):Void {}
    public function OnPointerDown(eventData:PointerEventData):Void {}
    public function OnPointerUp(eventData:PointerEventData):Void {}
    public function OnPointerEnter(eventData:PointerEventData):Void {}
    public function OnPointerExit(eventData:PointerEventData):Void {}
    public function OnSelect(eventData:BaseEventData):Void {}
    public function OnDeselect(eventData:BaseEventData):Void {}
    public function Select_Internal():Void {}
    public function InstantClearState():Void {}
    public function DoStateTransition(state:SelectionState, instant:Bool):Void {}
    public function Rebuild(update:CanvasUpdate):Void {}
    public function LayoutComplete():Void {}
    public function GraphicUpdateComplete():Void {}
}

// Minimal UnityEngine.UI.Selectable.Transition shim.
enum abstract Transition(Int) {
    var None = 0;
    var ColorTint = 1;
    var SpriteSwap = 2;
    var Animation = 3;
}

// Minimal UnityEngine.UI.Selectable.SelectionState shim.
enum abstract SelectionState(Int) {
    var Normal = 0;
    var Highlighted = 1;
    var Pressed = 2;
    var Selected = 3;
    var Disabled = 4;
}

// Minimal UnityEngine.UI.ColorBlock shim.
class ColorBlock {
    public var normalColor:Color = new Color(1, 1, 1, 1);
    public var highlightedColor:Color = new Color(245 / 255, 245 / 255, 245 / 255, 1);
    public var pressedColor:Color = new Color(200 / 255, 200 / 255, 200 / 255, 1);
    public var selectedColor:Color = new Color(245 / 255, 245 / 255, 245 / 255, 1);
    public var disabledColor:Color = new Color(200 / 255, 200 / 255, 200 / 255, 128 / 255);
    public var colorMultiplier:Float = 1;
    public var fadeDuration:Float = 0.1;

    public function new() {}
}

// Minimal UnityEngine.UI.SpriteState shim.
class SpriteState {
    public var highlightedSprite:unity.Sprite;
    public var pressedSprite:unity.Sprite;
    public var selectedSprite:unity.Sprite;
    public var disabledSprite:unity.Sprite;

    public function new() {}
}

// Minimal UnityEngine.UI.Navigation shim.
class Navigation {
    public var mode:NavigationMode = NavigationMode.Automatic;
    public var selectOnUp:Dynamic;
    public var selectOnDown:Dynamic;
    public var selectOnLeft:Dynamic;
    public var selectOnRight:Dynamic;

    public function new() {}

    public static var defaultNavigation(get, never):Navigation;
    static function get_defaultNavigation():Navigation return new Navigation();
}

// Minimal UnityEngine.UI.Navigation.Mode shim.
enum abstract NavigationMode(Int) {
    var None = 0;
    var Horizontal = 1;
    var Vertical = 2;
    var Automatic = 3;
    var Explicit = 4;
}

// Minimal UnityEngine.UI.CanvasUpdate shim.
enum abstract CanvasUpdate(Int) {
    var Prelayout = 0;
    var Layout = 1;
    var PostLayout = 2;
    var PreRender = 3;
    var LatePreRender = 4;
    var MaxUpdateValue = 5;
}

// Minimal UnityEngine.UI.ICanvasElement shim.
interface ICanvasElement {
    function Rebuild(executing:CanvasUpdate):Void;
    function LayoutComplete():Void;
    function GraphicUpdateComplete():Void;
    function IsDestroyed():Bool;
    function get_transform():unity.Transform;
}

// Minimal UnityEngine.UI.ILayoutElement shim.
interface ILayoutElement {
    function CalculateLayoutInputHorizontal():Void;
    function CalculateLayoutInputVertical():Void;
    var minWidth(get, never):Float;
    var preferredWidth(get, never):Float;
    var flexibleWidth(get, never):Float;
    var minHeight(get, never):Float;
    var preferredHeight(get, never):Float;
    var flexibleHeight(get, never):Float;
    var layoutPriority(get, never):Int;
}
