package mvz2.scenes;

import mvz2.managers.MainManager;
import unity.Mathf;
import unity.MonoBehaviour;
import unity.Physics2D;
import unity.Time;
import mvz2.level.LevelManager;

// Ported from: Assets/Scripts/MVZ2/Scene/GameUpdater.cs
class GameUpdater extends MonoBehaviour {
    private function Update():Void {
        var deltaTime = Time.deltaTime;
        timeModular += deltaTime;

        var fixedInterval = 1 / logicTicksPerSeconds;

        var level = main.LevelManager.GetLevelController();
        if (timeModular > fixedInterval) {
            var updateTimes = Std.int(timeModular / fixedInterval);
            updateTimes = Mathf.MinInt(updateTimes, maxUpdateTimePerFrame);
            for (i in 0...updateTimes) {
                if (level != null) {
                    level.UpdateLogic();
                }
                main.UpdateManagerFixed();
            }
            timeModular = timeModular % fixedInterval;
        }
        var updateDeltaTime = Mathf.Min(fixedInterval * maxUpdateTimePerFrame, deltaTime);
        if (level != null) {
            // PORT-NOTE: unity.Physics2D.SyncTransforms 在 shim 中是空实现（Flixel 无 2D 物理场景
            // 变换缓存需要同步），保留调用以对应 C# 原逻辑。
            Physics2D.SyncTransforms();
            level.UpdateFrame(updateDeltaTime);
        }
    }
    @:serializeField
    private var main:MainManager = null;
    @:serializeField
    private var logicTicksPerSeconds:Int = 30;
    @:serializeField
    private var maxUpdateTimePerFrame:Int = 1;
    private var timeModular:Float = 0;
}
