// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/NightmareEye.cs
package mvz2.models;

import unity.Color;
import unity.Mathf;
import unity.SpriteRenderer;

class NightmareEye extends unity.MonoBehaviour {
    public function new() {
        super();
    }

    public function GetAlpha():Float {
        var col = eyeRenderer.color;
        return col.a;
    }
    public function SetAlpha(value:Float):Void {
        var col = eyeRenderer.color;
        col.a = value;
        eyeRenderer.color = col;
    }
    public function SetTime(time:Int):Void {
        var index = Mathf.ClampInt(Std.int(time / interval), 0, indexes.length - 1);
        var i = indexes[index];
        spriteSetter.SetSpriteIndex(i);
    }

    private var interval:Float = 1.5;
    private static var indexes:Array<Int> = [
        0, 1, 2, 3, 4, 5, 6, 7, 6
    ];
    private var eyeRenderer:SpriteRenderer = null;
    private var spriteSetter:AnimationSpriteSetter = null;
}
