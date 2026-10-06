// Ported from: Assets/Scripts/MVZ2/Models/Components/TrailController.cs
package mvz2.models;

import unity.LineRenderer;
import unity.Mathf;
import unity.Vector3;

class TrailController extends ModelComponent {
    public function new() {
        super();
    }

    override public function Init():Void {
        super.Init();
        trailPoints = [];
        trailPoints.resize(trail.positionCount);
        worldPositions = [];
        worldPositions.resize(trail.positionCount);
        defaultWidthMultiplier = trail.widthMultiplier;
        trail.GetPositions(trailPoints);
        for (i in 0...worldPositions.length) {
            worldPositions[i] = GetCurrentWorldPosition();
            trailPoints[i] = ToTrailPosition(worldPositions[i]);
        }
        trail.SetPositions(trailPoints);
    }
    override public function UpdateLogic():Void {
        trail.GetPositions(trailPoints);
        var i = worldPositions.length - 1;
        while (i >= 0) {
            var position:Vector3;
            if (i == 0) {
                position = GetCurrentWorldPosition();
            } else {
                position = worldPositions[i - 1] + velocity * i;
            }
            worldPositions[i] = position;
            trailPoints[i] = ToTrailPosition(position);
            i--;
        }
        trail.SetPositions(trailPoints);
    }
    override public function UpdateFrame(deltaTime:Float):Void {
        var worldPos = GetCurrentWorldPosition();
        var position = ToTrailPosition(worldPos);
        trail.SetPosition(0, position);
        if (scaleWithHierarchy) {
            var scale = transform.lossyScale;
            trail.widthMultiplier = Mathf.Min(scale.x, scale.y) * defaultWidthMultiplier;
        } else {
            trail.widthMultiplier = defaultWidthMultiplier;
        }
    }
    private function ToTrailPosition(worldPos:Vector3):Vector3 {
        if (!trail.useWorldSpace) {
            return transform.InverseTransformPoint(worldPos);
        }
        return worldPos;
    }
    private function GetCurrentWorldPosition():Vector3 {
        return transform.position;
    }
    private var trail:LineRenderer = null;
    private var velocity:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    private var scaleWithHierarchy:Bool;
    private var defaultWidthMultiplier:Float;
    private var trailPoints:Array<Vector3> = [];
    private var worldPositions:Array<Vector3> = [];
}
