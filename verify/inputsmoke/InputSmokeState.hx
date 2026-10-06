// PORT-NOTE: 验证用（不参与游戏构建）。真实 FlxGame 下的输入冒烟测试 state：此时 FlxG.mouse / FlxG.keys
// 已经由 FlxGame → FlxG.init 建立，可以断言鼠标三键的路由（0 左 / 1 右 / 2 中）与 Unity KeyCode.MouseN
// 在 GetKey/GetKeyDown/GetKeyUp 里的转发；断言结束由 InputSmokeTest.finish() 调 Sys.exit 结束进程。
package inputsmoke;

import flixel.FlxState;

class InputSmokeState extends FlxState {
    public function new() {
        super();
    }

    override public function create():Void {
        super.create();
        InputSmokeTest.runAll(true);
    }
}
