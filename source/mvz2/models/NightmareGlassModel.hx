// Ported from: Assets/Scripts/MVZ2/Models/Components/Effects/NightmareGlass/NightmareGlassModel.cs
package mvz2.models;

import unity.Transform;
import unity.Vector3;

class NightmareGlassModel extends ModelComponent {
    public function new() {
        super();
    }

    override public function Init():Void {
        super.Init();
        var infos = new Array<NightmareGlassShardInfo>();
        infos.resize(shards.length);
        for (i in 0...infos.length) {
            var shard = shards[i];
            var info = new NightmareGlassShardInfo();
            info.position = shard.localPosition;
            info.rotation = shard.eulerAngles;
            info.scale = shard.localScale;
            infos[i] = info;
        }
        Model.SetProperty("Infos", infos);
    }
    override public function UpdateLogic():Void {
        super.UpdateLogic();
        var infos:Array<NightmareGlassShardInfo> = Model.GetProperty("Infos");
        if (infos != null) {
            for (i in 0...infos.length) {
                var info = infos[i];
                info.position = info.position + info.velocity;
                info.rotation = info.rotation + info.angularSpeed;
                info.scale = info.scale + info.scaleSpeed;
            }
        }
    }
    override public function UpdateFrame(deltaTime:Float):Void {
        super.UpdateFrame(deltaTime);
        var infos:Array<NightmareGlassShardInfo> = Model.GetProperty("Infos");
        if (infos != null) {
            for (i in 0...infos.length) {
                var info = infos[i];
                var shard = shards[i];
                shard.localPosition = info.position;
                shard.eulerAngles = info.rotation;
                shard.localScale = info.scale;
            }
        }
    }
    override public function OnTrigger(name:String):Void {
        super.OnTrigger(name);
        if (name == "Break") {
            BreakShards();
        }
    }
    private function BreakShards():Void {
        var infos:Array<NightmareGlassShardInfo> = Model.GetProperty("Infos");
        var rng = Model.GetRNG();
        if (infos != null) {
            for (i in 0...infos.length) {
                var info = infos[i];
                info.velocity = info.position * 0.2;
                info.angularSpeed = new Vector3(rng.Next(-maxRotationSpeed, maxRotationSpeed), rng.Next(-maxRotationSpeed, maxRotationSpeed), rng.Next(-maxRotationSpeed, maxRotationSpeed));
                info.scaleSpeed = Vector3.one * -1 / 60;
            }
        }
    }

    private var maxRotationSpeed:Float = 30;
    private var shards:Array<Transform> = null;
}

// [SerializeField]
class NightmareGlassShardInfo {
    public var position:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var rotation:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var scale:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var velocity:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var angularSpeed:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用
    public var scaleSpeed:Vector3 = new Vector3(0, 0, 0); // PORT-NOTE: C# Vector3 为 struct，默认 (0,0,0)；显式初始化避免 abstract-over-class 的 null 解引用

    public function new() {
        position = new Vector3();
        rotation = new Vector3();
        scale = new Vector3();
        velocity = new Vector3();
        angularSpeed = new Vector3();
        scaleSpeed = new Vector3();
    }
}
