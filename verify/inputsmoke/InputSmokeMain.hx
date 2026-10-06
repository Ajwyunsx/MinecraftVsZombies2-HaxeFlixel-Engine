// PORT-NOTE: 验证用（不参与游戏构建）。tools_build/verify_input 这个隔离 lime 工程的应用入口：
// 与常规 HaxeFlixel 工程一样把 FlxGame 挂到 stage 上，首帧进入 InputSmokeState 跑输入冒烟测试，
// 这样 FlxG.mouse / FlxG.keys 真实存在，可以断言鼠标三键的路由。
// 只被 tools_build/verify_input/Project.xml 的 <app main="inputsmoke.InputSmokeMain"/> 引用，
// 不参与 HaxePort/Project.xml 的构建。
package inputsmoke;

import flixel.FlxGame;
import openfl.display.Sprite;

class InputSmokeMain extends Sprite {
    public function new() {
        super();
        addChild(new FlxGame(320, 240, InputSmokeState, 60, 60, true, false));
    }
}
