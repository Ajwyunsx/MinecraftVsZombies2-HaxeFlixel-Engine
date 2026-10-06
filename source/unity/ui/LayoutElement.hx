package unity.ui;

// Minimal UnityEngine.UI.LayoutElement shim.
class LayoutElement extends UIBehaviour {
    public var ignoreLayout:Bool = false;
    public var minWidth:Float = -1;
    public var minHeight:Float = -1;
    public var preferredWidth:Float = -1;
    public var preferredHeight:Float = -1;
    public var flexibleWidth:Float = -1;
    public var flexibleHeight:Float = -1;
    public var layoutPriority:Int = 1;

    public function new() {
        super();
    }
    public function CalculateLayoutInputHorizontal():Void {}
    public function CalculateLayoutInputVertical():Void {}
    public function SetProperty(property:Dynamic, value:Float):Void {}
    public function GetProperty(property:Dynamic):Float return -1;
}

// Minimal UnityEngine.UI.LayoutGroup shim.
class LayoutGroup extends UIBehaviour {
    public var padding:RectOffset = new RectOffset();
    public var childAlignment:unity.TextAnchor = unity.TextAnchor.UpperLeft;
    public var rectTransform(get, never):unity.RectTransform;
    function get_rectTransform():unity.RectTransform return cast transform;
    public var layoutPriority(get, never):Int;
    function get_layoutPriority():Int return 0;

    public function new() {
        super();
    }

    public function CalculateLayoutInputHorizontal():Void {}
    public function CalculateLayoutInputVertical():Void {}
    public var minWidth(get, never):Float;
    function get_minWidth():Float return 0;
    public var preferredWidth(get, never):Float;
    function get_preferredWidth():Float return 0;
    public var flexibleWidth(get, never):Float;
    function get_flexibleWidth():Float return 0;
    public var minHeight(get, never):Float;
    function get_minHeight():Float return 0;
    public var preferredHeight(get, never):Float;
    function get_preferredHeight():Float return 0;
    public var flexibleHeight(get, never):Float;
    function get_flexibleHeight():Float return 0;
    public function SetLayoutHorizontal():Void {}
    public function SetLayoutVertical():Void {}
    public function CalculateLayoutInputHorizontalInternal():Void {}
    public function CalculateLayoutInputVerticalInternal():Void {}
}

// Minimal UnityEngine.RectOffset shim.
class RectOffset {
    public var left:Int = 0;
    public var right:Int = 0;
    public var top:Int = 0;
    public var bottom:Int = 0;

    public function new(?left:Int = 0, ?right:Int = 0, ?top:Int = 0, ?bottom:Int = 0) {
        this.left = left;
        this.right = right;
        this.top = top;
        this.bottom = bottom;
    }
    public var horizontal(get, never):Int;
    function get_horizontal():Int return left + right;
    public var vertical(get, never):Int;
    function get_vertical():Int return top + bottom;
}
