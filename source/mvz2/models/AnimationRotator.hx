// Ported from: Assets/Scripts/MVZ2/Models/Components/Animation/AnimationRotator.cs
package mvz2.models;

import unity.Vector3;

// [ExecuteAlways]
class AnimationRotator extends ModelComponent {
    public function new() {
        super();
    }

    override public function UpdateFrame(deltaTime:Float):Void {
        transform.localEulerAngles = rotation;
    }
    private var rotation:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
}
