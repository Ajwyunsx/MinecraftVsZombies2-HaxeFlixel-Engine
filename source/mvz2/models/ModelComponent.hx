// Ported from: Assets/Scripts/MVZ2/Models/ModelComponent.cs
package mvz2.models;

import mvz2.managers.MainManager;
import mvz2.models.Model.SerializableModelData;
import unity.Vector3;

// abstract
class ModelComponent extends unity.MonoBehaviour implements IModelComponent {
    public function new() {
        super();
    }

    public function Init():Void {}
    public function UpdateLogic():Void {}
    public function UpdateFrame(deltaTime:Float):Void {}
    public function OnPropertySet(name:String, value:Dynamic):Void {}
    public function OnTrigger(name:String):Void {}
    public function SaveToSerializable(serializable:SerializableModelData):Void {}
    public function LoadFromSerializable(serializable:SerializableModelData):Void {}
    private function Lawn2TransPosition(pos:Vector3):Vector3 {
        return Main.LevelManager.LawnToTrans(pos);
    }
    private function Trans2LawnPosition(pos:Vector3):Vector3 {
        return Main.LevelManager.TransToLawn(pos);
    }
    private function Lawn2TransScale(scale:Vector3):Vector3 {
        return Main.LevelManager.LawnToTransScale * scale;
    }
    private function Trans2LawnScale(scale:Vector3):Vector3 {
        return Main.LevelManager.TransToLawnScale * scale;
    }
    public var Main(get, never):MainManager;
    function get_Main():MainManager return MainManager.Instance;
    private function OnEnable():Void {
        // PORT-NOTE: 对应 C# 中 `#if UNITY_EDITOR` 分支（编辑器预览）。移植后不存在编辑器构建，
        // 但保留逻辑以便在非运行状态下也能初始化模型。
        if (!unity.Application.isPlaying) {
            // PORT-NOTE: C# 为 GetComponentInParent<Model>()；Haxe 需用模块限定名避免与同名属性 Model 冲突。
            Model = GetComponentInParent(mvz2.models.Model);
            Init();
        }
    }
    private function Update():Void {
        // PORT-NOTE: 对应 C# 中 `#if UNITY_EDITOR` 分支（编辑器预览）。
        if (!unity.Application.isPlaying) {
            UpdateFrame(unity.Time.deltaTime);
        }
    }
    public var Model(default, null):Model = null;

    public function SetModel(model:Model):Void {
        Model = model;
    }

    public function IsEnabled():Bool {
        return this != null && enabled;
    }
}
