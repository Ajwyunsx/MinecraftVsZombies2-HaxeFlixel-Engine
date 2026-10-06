package unity;

// Minimal UnityEngine.CanvasGroup shim.
class CanvasGroup extends Component {
    public var alpha:Float = 1;
    public var interactable:Bool = true;
    public var blocksRaycasts:Bool = true;
    public var ignoreParentGroups:Bool = false;

    public function new() {
        super();
    }
}
