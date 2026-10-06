// PORT-NOTE: 字体工作包的隔离自检入口（无 C# 对应源码）。
//
// 为什么必须单独跑：主工程启动要 15 秒 + 加载精灵 12 秒，而字体渲染的成败只取决于
// 「字体资产 → openfl Font → FlxText 出像素」这一小段。这里把这段拉出来单独跑（cpp 目标，
// 与游戏同目标；`--interp`/neko 下 lime 不支持 Image.fromBytes，位图恒 0x0，结论会假阴性），
// 并把每一步的**客观事实**写进 font-probe.log：
//   * lime 资源库里字体资产的 id / fontName（验证 Project.xml 的 assets 路径映射）；
//   * openfl 文本度量的实际像素（textWidth/textHeight）与字形覆盖（逐字符 hasGlyphs）；
//   * FlxText 渲染出的 BitmapData 里非透明像素数（= "文字可见" 的直接判据）。
//
// 走 `FlxGame`（而不是裸 main）：FlxText 依赖 `FlxG.bitmap` / `FlxG.renderTile` 等，
// 必须让 flixel 初始化完成。探针跑在第一个 FlxState.create 里，测完即落盘退出。
package fontcheck;

import flixel.FlxGame;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.utils.Assets;

class FontProbeState extends FlxState {
	public function new() {
		super();
	}

	override public function create():Void {
		super.create();
		bgColor = FlxColor.BLACK;
		var report = FontProbe.run();
		try {
			sys.io.File.saveContent(Sys.getCwd() + "/font-probe.log", report);
		} catch (e:Dynamic) {}
		Sys.println(report);
		Sys.exit(0);
	}
}

class FontProbe {
	public static function main():Void {
		var app = new Sprite();
		app.addChild(new FlxGame(1280, 720, FontProbeState, 60, 60, true, false));
		openfl.Lib.current.addChild(app);
	}

	static function line(buf:StringBuf, s:String):Void {
		buf.add(s + "\n");
	}

	public static function run():String {
		var log = new StringBuf();
		line(log, "=== FontProbe 开始 ===");
		line(log, 'cwd=${Sys.getCwd()}');

		// ---- 1. 字体资产 id ----
		var ids = [
			"assets/Fonts/unifont.otf",
			"assets/Fonts/mojangles/minecraft_font.otf",
			"assets/Fonts/mojangles/accented.otf",
			"assets/Fonts/mojangles/nonlatin_european.otf",
			"Fonts/unifont.otf",
		];
		for (id in ids) {
			var exists = false;
			try {
				exists = Assets.exists(id, openfl.utils.AssetType.FONT);
			} catch (e:Dynamic) {}
			var name = "-";
			if (exists) {
				try {
					name = Assets.getFont(id).fontName;
				} catch (e:Dynamic) {
					name = "ERR:" + Std.string(e);
				}
			}
			line(log, 'FONT $id exists=$exists fontName=$name');
		}

		// ---- 2. openfl 直接度量（与 FlxText 走同一条 openfl 文本栈）----
		var samples = ["版本0.1.0", "ABCDEFG", "开始游戏", "确认"];
		for (fontId in ["assets/Fonts/unifont.otf", "assets/Fonts/mojangles/minecraft_font.otf"]) {
			var exists = false;
			try {
				exists = Assets.exists(fontId, openfl.utils.AssetType.FONT);
			} catch (e:Dynamic) {}
			if (!exists) {
				line(log, '度量跳过（字体不存在）$fontId');
				continue;
			}
			var f = Assets.getFont(fontId);
			for (s in samples) {
				var tf = new TextField();
				tf.embedFonts = true;
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.defaultTextFormat = new TextFormat(f.fontName, 24, 0xFFFFFF);
				tf.text = s;
				// PORT-NOTE: openfl 9.3.4 的 Font **没有** hasGlyphs；字形覆盖要问 lime 的
				// `getGlyphs`（返回字形索引，0 = 该字符在字体里没有字形）。
				var covered = new StringBuf();
				var indices:Array<lime.text.Glyph> = null;
				try {
					indices = f.getGlyphs(s);
				} catch (e:Dynamic) {}
				for (i in 0...s.length) {
					var ch = s.charAt(i);
					// PORT-NOTE: `lime.text.Glyph` 是 abstract(Int)，字形索引 0 = 缺字形。
					var has = indices != null && i < indices.length && (indices[i]:Int) != 0;
					covered.add(ch + (has ? "+" : "-"));
				}
				line(log, '度量 font=${f.fontName} size=24 text="$s" w=${tf.textWidth} h=${tf.textHeight} '
					+ 'numGlyphs=${f.numGlyphs} glyphs=[$covered]');
			}
		}

		// ---- 3. FlxText 实际渲染像素 ----
		for (fontId in ["assets/Fonts/unifont.otf", "assets/Fonts/mojangles/minecraft_font.otf"]) {
			var exists = false;
			try {
				exists = Assets.exists(fontId, openfl.utils.AssetType.FONT);
			} catch (e:Dynamic) {}
			if (!exists)
				continue;
			for (t in samples) {
				var label = new FlxText(0, 0, 0, t);
				label.setFormat(fontId, 24, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.NONE);
				line(log, 'FlxText font=${fontId.split("/").pop()} text="$t" '
					+ 'frame=${label.frameWidth}x${label.frameHeight} nonZeroPixels=${countNonZero(label)}');
				label.destroy();
			}
		}

		// ---- 4. 对照：不设字体（flixel 默认内嵌字体）----
		var dflt = new FlxText(0, 0, 0, "版本0.1.0");
		line(log, '对照 默认内嵌字体 text="版本0.1.0" frame=${dflt.frameWidth}x${dflt.frameHeight} '
			+ 'nonZeroPixels=${countNonZero(dflt)}');

		// ---- 5. 对照：systemFont（非嵌入，走系统字体）----
		var sysf = new FlxText(0, 0, 0, "版本0.1.0");
		sysf.systemFont = "Arial";
		sysf.size = 24;
		line(log, '对照 systemFont=Arial text="版本0.1.0" nonZeroPixels=${countNonZero(sysf)}');

		line(log, "=== FontProbe 结束 ===");
		return log.toString();
	}

	/** FlxText 当前像素里非透明像素数 —— 「文字是否真的画出来了」的直接判据。 */
	static function countNonZero(label:FlxText):Int {
		var bd:BitmapData = null;
		try {
			bd = label.pixels;
		} catch (e:Dynamic) {}
		if (bd == null && label.graphic != null)
			bd = label.graphic.bitmap;
		if (bd == null)
			return -1;
		var n = 0;
		for (y in 0...bd.height) {
			for (x in 0...bd.width) {
				if ((bd.getPixel32(x, y) >>> 24) > 8)
					n++;
			}
		}
		return n;
	}
}
