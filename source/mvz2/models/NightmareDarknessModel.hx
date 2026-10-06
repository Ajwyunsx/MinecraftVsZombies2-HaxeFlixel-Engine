// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/NightmareDarknessModel.cs
package mvz2.models;

import mvz2.gamecontent.effects.NightmareDarkness.NightmareEyeInfo;
import unity.GameObject;
import unity.Mathf;
import unity.Transform;
import unity.Vector3;
using pvzengine.models.HasModelExt;  // EXTUSING

class NightmareDarknessModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        var infos:Array<NightmareEyeInfo> = Model.GetProperty("Eyes");
        var timeout:Int = Model.GetProperty("Timeout");
        var time = 180 - timeout;
        var darknessRadius = Mathf.Lerp(maxRadius, 0, (30 - timeout) / 30);
        darknessRenderer.SetFloat("_Radius", darknessRadius / maxRadius);
        darknessRenderer.ApplyShaderProperties();

        if (infos != null) {
            for (i in 0...infos.length) {
                var info = infos[i];
                var eye:NightmareEye;
                if (i >= eyes.length) {
                    eye = CreateEye(info);
                } else {
                    eye = eyes[i];
                }
                var eyeTime = Std.int(Mathf.Max(time - info.time, 0));
                eye.SetTime(eyeTime);

                var eyeRadius = (info.position - darknessCenter).magnitude;
                var alpha = Mathf.Clamp01((darknessRadius - eyeRadius) / 100 * info.scale);
                eye.SetAlpha(alpha);
            }
        }

    }
    private function CreateEye(info:NightmareEyeInfo):NightmareEye {
        var eyeGo:GameObject = unity.UnityObject.Instantiate(eyePrefab, null, null, eyesParent);
        var eye = eyeGo.GetComponent(NightmareEye);
        eye.gameObject.SetActive(true);
        var trans = eye.transform;
        trans.localPosition = Lawn2TransPosition(info.position);

        var angles = trans.localEulerAngles;
        angles.z = info.angle;
        trans.localEulerAngles = angles;

        trans.localScale = Vector3.one * info.scale;

        Model.AddElement(eye.GetComponent(GraphicElement));
        eyes.push(eye);
        return eye;
    }
    private var eyesParent:Transform = null;
    private var eyePrefab:GameObject = null;
    private var darknessRenderer:RendererElement = null;
    private var eyes:Array<NightmareEye> = [];
    private var maxRadius:Float = 1200;
    private var darknessCenter:Vector3 = new Vector3(510, 0, 300);
}
