// Ported from: TMPro.TextMeshPro (minimal shim)
package tmpro;

import unity.MonoBehaviour;

class TextMeshPro extends MonoBehaviour {
    public var text:String = "";
    public var richText:Bool = true;
    public var fontSize:Float = 36;
    public var color:unity.Color = new unity.Color(1, 1, 1, 1);
    public var alignment:Dynamic = null;
    public var enableWordWrapping:Bool = true;

    public function new() {
        super();
    }
}
