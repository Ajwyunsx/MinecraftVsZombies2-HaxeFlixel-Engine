// Ported from: Assets/Scripts/MVZ2/Models/Components/Projectiles/KnockbackWaveModel.cs
package mvz2.models;

import unity.ParticleSystem;
import unity.Vector2;
import unity.Vector3;

class KnockbackWaveModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function Init():Void {
        super.Init();
        lastPosition = transform.position;
    }
    override public function UpdateLogic():Void {
        super.UpdateLogic();
        // PORT-NOTE: C# 中 Vector2/Vector3 隐式转换；Haxe 显式取 xy。
        var angle = Vector2.SignedAngle(Vector2.right, new Vector2(transVelocity.x, transVelocity.y));
        Model.SetProperty("Angle", angle);
    }
    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        SetDirection(Model.GetProperty("Angle"));
        transVelocity = transform.position - lastPosition;
        lastPosition = transform.position;
    }

    public function SetDirection(angle:Float):Void {
        particle.transform.eulerAngles = Vector3.forward * angle;
    }
    private var particle:ParticleSystem = null;
    private var lastPosition:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    private var transVelocity:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
}
