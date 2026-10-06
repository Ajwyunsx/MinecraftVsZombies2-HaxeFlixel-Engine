// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/ElectricArcModel.cs
package mvz2.models;

import mvz2.models.Model.SerializableModelData;
import unity.Quaternion;
import unity.Transform;
import unity.Vector3;

class ElectricArcModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function LoadFromSerializable(serializable:SerializableModelData):Void {
        super.LoadFromSerializable(serializable);
        UpdateLine();
    }
    override public function UpdateLogic():Void {
        super.UpdateLogic();
        UpdateLevitation();
        UpdateLine();
    }
    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        UpdateDirection();
    }
    override public function OnTrigger(name:String):Void {
        super.OnTrigger(name);
        if (name == "Update") {
            UpdateLinePoints();
            UpdateDirection();
            UpdateLine();
        }
    }
    private function UpdateLevitation():Void {
        var points:Array<Array<Vector3>> = Model.GetProperty("points");

        if (points == null)
            return;
        var rng = Model.GetRNG();

        for (p in 0...points.length) {
            var linePoints = points[p];
            if (linePoints == null)
                continue;
            var lightning = lightnings[p];
            var count = linePoints.length;
            var parent = lightning.transform.parent;
            for (i in 1...count - 1) {
                var percent = i / count;
                var modifier = -4 * Math.pow(percent - 0.5, 2) + 1;

                var localPosition = linePoints[i];
                var worldPosition = parent.TransformPoint(localPosition);
                worldPosition.x += rng.Next(-arcShiver, arcShiver) * modifier;
                worldPosition.y += (rng.Next(-arcShiver, arcShiver) + arcLevitation) * modifier;
                worldPosition.z += rng.Next(-arcShiver, arcShiver) * modifier;
                localPosition = parent.InverseTransformPoint(worldPosition);
                linePoints[i] = localPosition;
            }
        }
    }
    private function UpdateDirection():Void {
        var source = sourceTransform.position;
        var dest:Vector3 = Lawn2TransPosition(Model.GetProperty("Dest"));
        var distance = dest - source;
        sourceTransform.rotation = Quaternion.FromToRotation(Vector3.right, distance);
        sourceTransform.localScale = new Vector3(distance.magnitude, 1, 1);
    }
    private function UpdateLine():Void {
        var points:Array<Array<Vector3>> = Model.GetProperty("points");

        if (points == null)
            return;
        for (i in 0...points.length) {
            var lightning = lightnings[i];
            var renderer = lightning.LineRenderer;
            var linePoints = points[i];
            if (linePoints == null)
                continue;
            lightning.LineRenderer.positionCount = linePoints.length;
            renderer.SetPositions(linePoints);
        }
    }
    private function UpdateLinePoints():Void {
        var pointCount:Int = Model.GetProperty("PointCount");
        var points:Array<Array<Vector3>> = Model.GetProperty("points");
        if (points == null) {
            points = new Array<Array<Vector3>>();
            points.resize(lightnings.length);
            Model.SetProperty("points", points);
        }
        for (i in 0...points.length) {
            var lightning = lightnings[i];
            // PORT-NOTE: C# 中同名静态方法在移植层改名为 GenerateLightningPoints。
            var generated = mvz2.models.LightningGenerator.GenerateLightningPoints(pointCount, sourceTransform.localPosition, destTransform.localPosition, lightning.amplitude, Model.GetRNG());
            if (generated != null) {
                points[i] = generated;
            }
        }
    }
    private var lightnings:Array<LightningGenerator> = null;
    private var sourceTransform:Transform = null;
    private var destTransform:Transform = null;
    private var arcShiver:Float = 0.03;
    private var arcLevitation:Float = 0.01;
}
