// Ported from: Assets/Scripts/MVZ2/Models/Components/MobileColliderExpander.cs
package mvz2.models;

import mvz2logic.inputs.PointerTypes;
import Main;  // UNKNOWNIMPORT
import unity.BoxCollider2D;
import unity.CircleCollider2D;
import unity.Collider2D;

class MobileColliderExpander extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        var shouldActive = Main.InputManager.GetActivePointerType() == PointerTypes.TOUCH;
        if (active != shouldActive) {
            if (shouldActive) {
                Enable();
            } else {
                Disable();
            }
        }
    }
    private function OnDisable():Void {
        Disable();
    }
    private function Enable():Void {
        if (active)
            return;
        active = true;
        var collider = GetComponent(Collider2D);
        if (Std.isOfType(collider, CircleCollider2D)) {
            var circle:CircleCollider2D = cast collider;
            circle.radius *= scale;
        } else if (Std.isOfType(collider, BoxCollider2D)) {
            var box:BoxCollider2D = cast collider;
            box.size = box.size * scale;
        }
    }
    private function Disable():Void {
        if (!active)
            return;
        active = false;
        var collider = GetComponent(Collider2D);
        if (Std.isOfType(collider, CircleCollider2D)) {
            var circle:CircleCollider2D = cast collider;
            circle.radius /= scale;
        } else if (Std.isOfType(collider, BoxCollider2D)) {
            var box:BoxCollider2D = cast collider;
            box.size = box.size / scale;
        }
    }
    private var active:Bool;
    private var scale:Float = 2.5;
}
