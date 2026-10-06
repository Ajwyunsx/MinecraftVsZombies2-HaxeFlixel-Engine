// Ported from: (HaxePort 新增) 启动失败的降级界面
// PORT-NOTE: 原工程的启动错误由 GameEntrance.ShowErrorDialog 通过 MainSceneUI 的对话框显示；
// 移植阶段 prefab 与语言包都还不可用（启动失败往往正是因为资源没转换），因此这里用一个最小的
// FlxState 直接把错误信息画出来，对应 GameEntrance.ERROR_FAILED_TO_INITIALIZE 的语义。
package mvz2.states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import unity.Application;

class ErrorState extends FlxState {
	// PORT-NOTE: 对应 GameEntrance.ERROR_FAILED_TO_INITIALIZE = "游戏加载失败：\n{0}"。
	public static inline var ERROR_FAILED_TO_INITIALIZE:String = "游戏加载失败：\n{0}";
	public static inline var QUIT_HINT:String = "按 ESC 退出游戏。";

	private var detail:String;

	public function new(?detail:String = null) {
		super();
		this.detail = detail != null ? detail : StartupError.describe();
	}

	override public function create():Void {
		super.create();

		BootTrace.step("ErrorState.create 进入（降级显示启动错误）");

		bgColor = FlxColor.BLACK;

		// TODO-PORT: flixel 的默认字体只有 ASCII 字形，中文会渲染成空白；而游戏的字体来自
		// FontManager（Unity Font 资源 + TMP SpriteAsset），尚未转换。这里先把文案降级为 ASCII，
		// 保证"错误信息一定看得见"；等字体/语言包接入后应改回 LanguageManager 的
		// LogicStrings.CONTEXT_ERROR 文案。
		var title = new FlxText(0, 0, FlxG.width, toAscii(ERROR_FAILED_TO_INITIALIZE.split("{0}")[0]));
		title.setFormat(null, 24, FlxColor.RED, CENTER);
		title.y = 40;
		add(title);

		var message = new FlxText(0, 0, FlxG.width - 80, toAscii(detail));
		message.setFormat(null, 14, FlxColor.WHITE, LEFT);
		message.x = 40;
		message.y = title.y + 48;
		message.wordWrap = true;
		add(message);

		var hint = new FlxText(0, 0, FlxG.width, toAscii(QUIT_HINT));
		hint.setFormat(null, 14, FlxColor.GRAY, CENTER);
		hint.y = FlxG.height - 40;
		add(hint);

		trace('[MVZ2] 启动失败：\n$detail');
		// PORT-NOTE: lime 的 Windows 程序是 GUI 子系统，trace/stdout 不可见；降级界面上的文字
		// 也没有别的途径取回。这里把详情一并写进 boot-trace.log，方便离线排查（该文件本身也是
		// 移植期临时产物）。
		BootTrace.error('启动失败详情：\n$detail');
		BootTrace.step("ErrorState 已显示错误信息（等待用户按 ESC 退出）");
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// PORT-NOTE: FlxG.keys 只在 FLX_KEYBOARD 下存在（FlxDefines.defineInversion(FLX_NO_KEYBOARD,
		// FLX_KEYBOARD)）；Project.xml 对 mobile 定义 FLX_NO_KEYBOARD，若同时命中 desktop/html5
		// （例如未来的 desktop+mobile 混合配置）就必须一起判断，否则这里会编译失败。
		#if ((desktop || html5) && FLX_KEYBOARD)
		if (FlxG.keys.justPressed.ESCAPE) {
			Application.Quit();
		}
		#end
	}

	// PORT-NOTE: 中文映射为等价的 ASCII 文案（默认字体无法渲染 CJK），未收录的字符直接丢弃。
	static var ASCII_TEXT:Map<String, String> = [
		"游戏加载失败：" => "Game failed to start:",
		"按 ESC 退出游戏。" => "Press ESC to quit.",
	];

	private static function toAscii(text:String):String {
		if (text == null)
			return "";
		for (key => value in ASCII_TEXT) {
			text = StringTools.replace(text, key, value);
		}
		var sb = new StringBuf();
		for (i in 0...text.length) {
			var code = text.charCodeAt(i);
			if (code == 10 || code == 13 || (code >= 32 && code < 127))
				sb.addChar(code);
		}
		return sb.toString();
	}
}
