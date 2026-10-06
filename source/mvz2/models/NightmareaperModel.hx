// Ported from: Assets/Scripts/MVZ2/Models/Components/Boss/NightmareaperModel.cs
package mvz2.models;

import tools.Geometry;
import Main;  // UNKNOWNIMPORT
import tools.Transitions;
import unity.Camera;
import unity.Mathf;
import unity.Rect;
import unity.Transform;
import unity.Vector2;
import unity.Vector3;
using mvz2.cameras.CameraHelper;  // EXTUSING

class NightmareaperModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        var camera = Model.GetCamera();
        UpdateRage(camera);
    }
    private function UpdateRage(camera:Camera):Void {
        var leftDir = Main.UseMobileLayout() ? mobileRageLeftArmDir.normalized : rageLeftArmDir.normalized;
        var rightDir = Main.UseMobileLayout() ? mobileRageRightArmDir.normalized : rageRightArmDir.normalized;

        var rageState:Int = Model.GetProperty("RageState");
        var rageProgress:Float = Model.GetProperty("RageProgress");
        switch (rageState) {
            case 1:
                SetRagingArm(camera, leftArmParent, Vector2.left, leftDir, rageProgress);
                SetRagingArm(camera, rightArmParent, Vector2.right, rightDir, rageProgress);
            case 2:
                SetClosingArm(camera, leftArmParent, leftDir, rageProgress);
                SetClosingArm(camera, rightArmParent, rightDir, rageProgress);
            default:
        }
    }
    private function SetRagingArm(camera:Camera, arm:Transform, fromDir:Vector2, dir:Vector2, progress:Float):Void {
        var worldRect:Rect = camera.GetViewRect();
        var position:Vector2 = new Vector2(arm.transform.position.x, arm.transform.position.y);

        progress = Transitions.EaseIn(progress);
        var targetPoint:{value:Vector2} = {value: new Vector2()};
        if (!Geometry.DoRectAndRayIntersect(worldRect, position, dir, targetPoint))
            return;
        var point = targetPoint.value;
        // Scale
        var targetDistance = point - position;
        var targetScale = Vector3.Dot(new Vector3(targetDistance.x, targetDistance.y, 0), new Vector3(dir.x, dir.y, 0)) / 1.2;
        var leftScale = new Vector3(Mathf.Lerp(1, targetScale, progress) / arm.parent.lossyScale.x, 1, 1);
        arm.localScale = leftScale;

        // Angle
        var angle = Mathf.Lerp(0, Vector2.SignedAngle(fromDir, dir), progress);
        var angles = Vector3.forward * angle;
        arm.localEulerAngles = angles;

    }
    private function SetClosingArm(camera:Camera, arm:Transform, dir:Vector2, progress:Float):Void {
        var worldRect:Rect = camera.GetViewRect();
        var position:Vector2 = new Vector2(arm.transform.position.x, arm.transform.position.y);

        progress = Transitions.EaseIn(progress);
        var targetPos = worldRect.center + dir * 0.6;
        var targetDistance = targetPos - position;

        var targetScale = Vector3.Dot(new Vector3(targetDistance.x, targetDistance.y, 0), new Vector3(dir.x, dir.y, 0)) / 1.2;
        var targetPoint:{value:Vector2} = {value: new Vector2()};
        if (!Geometry.DoRectAndRayIntersect(worldRect, position, dir, targetPoint))
            return;
        var point = targetPoint.value;
        // Scale
        var fromDistance = point - position;
        var fromScale = Vector3.Dot(new Vector3(fromDistance.x, fromDistance.y, 0), new Vector3(dir.x, dir.y, 0)) / 1.2;

        var leftScale = new Vector3(Mathf.Lerp(fromScale, targetScale, progress) / arm.parent.lossyScale.x, 1, 1);
        arm.localScale = leftScale;

    }
    private var leftArmParent:Transform = null;
    private var rightArmParent:Transform = null;

    private var rageRightArmDir:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    private var rageLeftArmDir:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    private var mobileRageRightArmDir:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    private var mobileRageLeftArmDir:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
}
