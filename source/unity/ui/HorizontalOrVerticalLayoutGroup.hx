package unity.ui;

import unity.ui.LayoutElement.LayoutGroup;

// Minimal UnityEngine.UI.HorizontalOrVerticalLayoutGroup shim.
class HorizontalOrVerticalLayoutGroup extends LayoutGroup {
    public var spacing:Float = 0;
    public var childForceExpandWidth:Bool = true;
    public var childForceExpandHeight:Bool = true;
    public var childControlWidth:Bool = true;
    public var childControlHeight:Bool = true;
    public var childScaleWidth:Bool = false;
    public var childScaleHeight:Bool = false;
    public var reverseArrangement:Bool = false;

    public function new() {
        super();
    }
}

// Minimal UnityEngine.UI.VerticalLayoutGroup shim.
class VerticalLayoutGroup extends HorizontalOrVerticalLayoutGroup {
    public function new() {
        super();
    }
}

// Minimal UnityEngine.UI.HorizontalLayoutGroup shim.
class HorizontalLayoutGroup extends HorizontalOrVerticalLayoutGroup {
    public function new() {
        super();
    }
}

// Minimal UnityEngine.UI.GridLayoutGroup shim.
class GridLayoutGroup extends LayoutGroup {
    public var startCorner:Corner = Corner.UpperLeft;
    public var startAxis:GridAxis = GridAxis.Horizontal;
    public var cellSize:unity.Vector2 = new unity.Vector2(100, 100);
    public var spacing:unity.Vector2 = new unity.Vector2();
    public var constraint:Constraint = Constraint.Flexible;
    public var constraintCount:Int = 2;

    public function new() {
        super();
    }
    public var cellSizeDefault:unity.Vector2 = new unity.Vector2(100, 100);
}

// Minimal UnityEngine.UI.GridLayoutGroup.Corner shim.
enum abstract Corner(Int) {
    var UpperLeft = 0;
    var UpperRight = 1;
    var LowerLeft = 2;
    var LowerRight = 3;
}

// Minimal UnityEngine.UI.GridLayoutGroup.Axis shim.
enum abstract GridAxis(Int) {
    var Horizontal = 0;
    var Vertical = 1;
}

// Minimal UnityEngine.UI.GridLayoutGroup.Constraint shim.
enum abstract Constraint(Int) {
    var Flexible = 0;
    var FixedColumnCount = 1;
    var FixedRowCount = 2;
}

// Minimal UnityEngine.UI.ContentSizeFitter shim.
class ContentSizeFitter extends UIBehaviour {
    public var horizontalFit:FitMode = FitMode.Unconstrained;
    public var verticalFit:FitMode = FitMode.Unconstrained;

    public function new() {
        super();
    }
    public function SetLayoutHorizontal():Void {}
    public function SetLayoutVertical():Void {}
}

// Minimal UnityEngine.UI.ContentSizeFitter.FitMode shim.
enum abstract FitMode(Int) {
    var Unconstrained = 0;
    var MinSize = 1;
    var PreferredSize = 2;
}

// Minimal UnityEngine.UI.AspectRatioFitter shim.
class AspectRatioFitter extends UIBehaviour {
    public var aspectMode:AspectMode = AspectMode.None;
    public var aspectRatio:Float = 1;

    public function new() {
        super();
    }
    public function SetLayoutHorizontal():Void {}
    public function SetLayoutVertical():Void {}
}

// Minimal UnityEngine.UI.AspectRatioFitter.AspectMode shim.
enum abstract AspectMode(Int) {
    var None = 0;
    var WidthControlsHeight = 1;
    var HeightControlsWidth = 2;
    var FitInParent = 3;
    var EnvelopeParent = 4;
}
