package unity;

// Minimal UnityEngine.Behaviour shim.
class Behaviour extends Component {
    public var enabled:Bool = true;
    public var isActiveAndEnabled(get, never):Bool;
    function get_isActiveAndEnabled():Bool return enabled && gameObject != null && gameObject.activeInHierarchy;

    public function new() {
        super();
    }
}
