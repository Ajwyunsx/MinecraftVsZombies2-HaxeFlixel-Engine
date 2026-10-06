package unity.rendering;

import unity.Component;

// Minimal UnityEngine.Rendering.SortingGroup shim.
class SortingGroup extends Component {
    public var sortingLayerID:Int = 0;
    public var sortingLayerName:String = "Default";
    public var sortingOrder:Int = 0;
    public var sortAtRoot:Bool = true;

    public function new() {
        super();
    }

    // PORT-NOTE: 补全 UnityEngine.Rendering.SortingGroup.UpdateAllSortingGroups（渲染层未实现，空实现）。
    public static function UpdateAllSortingGroups():Void {}
}
