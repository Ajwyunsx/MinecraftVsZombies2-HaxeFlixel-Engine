package mvz2.scenes;

import mvz2.scenes.ScenePage;
import flixel.util.FlxSignal.FlxTypedSignal;

// Ported from: Assets/Scripts/MVZ2/Scene/MainScenePage.cs
class MainScenePage extends ScenePage {
    override public function Hide():Void {
        super.Hide();
        // PORT-NOTE: FlxTypedSignal 无 clear()，对应 C# 的 RemoveAllListeners() 用 removeAll()。
        OnReturnClick.removeAll();
    }
    private function Return():Void {
        OnReturnClick.dispatch();
        Hide();
    }
    public var OnReturnClick:FlxTypedSignal<Void->Void> = new FlxTypedSignal();
}
