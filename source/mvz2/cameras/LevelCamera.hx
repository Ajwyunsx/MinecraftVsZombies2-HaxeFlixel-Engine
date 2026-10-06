package mvz2.cameras;

import unity.Camera;
import unity.MonoBehaviour;
import unity.Quaternion;
import unity.Screen;
import unity.Transform;
import unity.Vector2;
import unity.Vector3;

// Ported from: Assets/Scripts/MVZ2/Cameras/LevelCamera.cs
@:executeAlways
class LevelCamera extends MonoBehaviour {
    public function SetPosition(position:Vector3, anchor:Vector2):Void {
        cameraPosition = position;
        cameraAnchor = anchor;
        UpdatePosition();
    }
    public function SetSpace(left:Float):Void {
        leftspace = left;
        UpdatePosition();
    }
    public function SetRotation(rotation:Float):Void {
        cameraRotation = rotation;
        UpdatePosition();
    }
    public function GetRotation():Float {
        return cameraRotation;
    }
    private function OnEnable():Void {
        UpdatePosition();
    }
    private function Update():Void {
        UpdatePosition();
    }
    private function UpdatePosition():Void {
        if (_camera == null)
            return;
        var aspect = Screen.width * _camera.rect.width / (Screen.height * _camera.rect.height);
        var height = _camera.orthographicSize * 2;
        var cameraSize = new Vector2(height * aspect, height);
        var clippedSize = new Vector2(cameraSize.x - leftspace, cameraSize.y);
        var clippedOffset = clippedSize * cameraAnchor - clippedSize * 0.5;
        var viewportCenter = CameraPosition - clippedOffset;
        var quaternion = Quaternion.Euler(0, 0, cameraRotation);
        _viewportTransform.position = viewportCenter;
        _viewportTransform.rotation = quaternion;

        var offset = (Vector2.one * 0.5 - CameraAnchor) * cameraSize;
        _camera.transform.localPosition = CameraPosition + offset + ShakeOffset - viewportCenter;
    }
    public var CameraPosition(get, set):Vector3;
    function get_CameraPosition():Vector3 return cameraPosition;
    function set_CameraPosition(value:Vector3):Vector3 {
        cameraPosition = value;
        UpdatePosition();
        return value;
    }
    public var CameraAnchor(get, set):Vector2;
    function get_CameraAnchor():Vector2 return cameraAnchor;
    function set_CameraAnchor(value:Vector2):Vector2 {
        cameraAnchor = value;
        UpdatePosition();
        return value;
    }
    public var ShakeOffset(get, set):Vector3;
    function get_ShakeOffset():Vector3 return cameraShakeOffset;
    function set_ShakeOffset(value:Vector3):Vector3 {
        cameraShakeOffset = value;
        UpdatePosition();
        return value;
    }
    public var Camera(get, never):Camera;
    inline function get_Camera():Camera return _camera;

    @:serializeField
    private var _viewportTransform:Transform = null;
    @:serializeField
    private var _camera:Camera = null;
    @:serializeField
    private var cameraAnchor:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 null 解引用（该字段在 Unity 由 prefab 序列化赋值，移植层由 prefab 数据覆盖）
    @:serializeField
    private var cameraPosition:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 null 解引用（该字段在 Unity 由 prefab 序列化赋值，移植层由 prefab 数据覆盖）
    private var cameraShakeOffset:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    private var cameraRotation:Float;
    private var leftspace:Float;
}
