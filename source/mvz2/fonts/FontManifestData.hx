// Ported from: (新增文件) TMPro.TMP_FontAsset / TMP_Character / TMP_Glyph 的移植层数据模型
package mvz2.fonts;

import unity.tmpro.TMP_FontAsset;

// PORT-NOTE: 移植层新增（无 C# 对应源码）。对应 Unity 里 `TMP_FontAsset` 资产本身持有的数据。
//
// C# 侧这些字段由 Unity 的序列化系统填充，字体资产是 `.asset`（YAML）：
//   m_FaceInfo（pointSize / scale / lineHeight / ascentLine …）、
//   m_GlyphTable（每个字形的 metrics + 图集矩形）、
//   m_CharacterTable（unicode → glyphIndex）、
//   m_AtlasTextures（Alpha8 图集贴图）。
// 移植层没有这套序列化，改由 `tools_build/export_fonts.py` 在构建期导出成
// `assets/fonts_manifest.json`，本包在运行期把它还原成等价对象。
//
// 两个消费者：
//   1. `mvz2.ui.UiRenderer` —— 按 TMP 的 `requestedPointSize / faceInfo.pointSize` 算出
//      「用 OTF 渲染时该给 openfl 多少像素」（见 FontManifest.scaleFactorFor）；
//   2. `mvz2.fonts.TmpBitmapFontBuilder`（可选路线）—— 用字形矩形 + 图集 PNG 建 FlxBitmapFont。

/** 一个 TMP 字形的度量（TMP_Glyph.metrics，单位 = 像素 @ faceInfo.pointSize）。 */
class FontGlyphMetrics {
	public var width:Float = 0;
	public var height:Float = 0;
	/** 相对笔位置的横向偏移（左边缘）。 */
	public var bearingX:Float = 0;
	/** 相对基线的纵向偏移（上边缘）。 */
	public var bearingY:Float = 0;
	/** 前进量。 */
	public var advance:Float = 0;

	public function new() {}
}

/** 字形在图集里的像素矩形（左上角原点，与 Unity 的 m_GlyphRect 一致）。 */
class FontGlyphRect {
	public var x:Int = 0;
	public var y:Int = 0;
	public var width:Int = 0;
	public var height:Int = 0;

	public function new() {}
}

/** 一个字形（TMP_Glyph / Glyph）。 */
class FontGlyph {
	public var index:Int = 0;
	public var metrics:FontGlyphMetrics = new FontGlyphMetrics();
	public var rect:FontGlyphRect = new FontGlyphRect();
	public var scale:Float = 1;
	/** 该字形在哪一张图集里（对应 FontAsset.atlasTextures 的下标）。 */
	public var atlasIndex:Int = 0;

	public function new() {}
}

/** 字符 → 字形索引（TMP_Character）。 */
class FontCharacter {
	public var unicode:Int = 0;
	public var glyphIndex:Int = 0;
	public var scale:Float = 1;

	public function new() {}
}

/** TMP 的 FaceInfo：字体的全局度量，单位 = 像素 @ pointSize。 */
class FontFaceInfo {
	public var familyName:String = "";
	public var styleName:String = "";
	/** 烘焙时用的字号。TMP 运行期的 `fontSize` 是"请求字号"，实际图集是按它烘焙的。 */
	public var pointSize:Float = 0;
	/** TMP 的全局缩放（`TMP_FontAsset.faceInfo.scale`）。 */
	public var scale:Float = 1;
	public var unitsPerEM:Float = 0;
	public var lineHeight:Float = 0;
	/** 基线以上的距离（正数）。 */
	public var ascentLine:Float = 0;
	public var capLine:Float = 0;
	public var meanLine:Float = 0;
	public var baseline:Float = 0;
	/** 基线以下的距离（负数）。 */
	public var descentLine:Float = 0;
	public var superscriptOffset:Float = 0;
	public var superscriptSize:Float = 0.5;
	public var subscriptOffset:Float = 0;
	public var subscriptSize:Float = 0.5;
	public var underlineOffset:Float = 0;
	public var underlineThickness:Float = 0;
	public var strikethroughOffset:Float = 0;
	public var strikethroughThickness:Float = 0;
	public var tabWidth:Float = 0;

	public function new() {}
}

/** 源字体文件（OTF/TTF）在移植层的落点。 */
class FontSourceFile {
	/** 相对仓库根的路径（`Assets/Fonts/mojangles/minecraft_font.otf`）。 */
	public var path:String;
	/** lime 资源库里的 id（`assets/Fonts/mojangles/minecraft_font.otf`）。 */
	public var assetId:String;
	public var guid:String;
	/** 直接从 SFNT 读出的度量（em 归一化），用于交叉校验 / faceInfo 缺失时兜底。 */
	public var metrics:FontSourceMetrics;

	public function new() {}
}

/** SFNT（head/hhea/OS2）的度量，单位是 em 的倍数。 */
class FontSourceMetrics {
	public var unitsPerEm:Int = 0;
	public var ascent:Float = 0;
	public var descent:Float = 0;
	public var lineGap:Float = 0;
	public var typoAscender:Float = 0;
	public var typoDescender:Float = 0;
	public var winAscent:Float = 0;
	public var winDescent:Float = 0;

	public function new() {}
}

/** 一张图集贴图（Alpha8 导出成 PNG）。 */
class FontAtlasTexture {
	/** `glyph.atlasIndex` 指向本项。 */
	public var atlasIndex:Int = 0;
	public var name:String = "";
	public var width:Int = 0;
	public var height:Int = 0;
	/** Unity 的 TextureFormat（1 = Alpha8）。 */
	public var textureFormat:Int = 1;
	/** 相对 HaxePort/assets 的 PNG 路径。 */
	public var pngPath:String;

	public function new() {}
}

/**
 * 一个 TMP 字体资产的完整移植层表示。
 *
 * PORT-NOTE: `guid` / `assetPath` 用来把 prefab 里的资产引用
 * （`TextMeshProUGUI.font` = `{guid, fileID, path}`）解析到本对象；
 * `sourceFontFile` 是"用 OTF 渲染"路线的入口；`glyphs`/`characters`/`atlasTextures`
 * 是"用位图字体渲染"路线的入口。
 */
class FontAsset {
	/** Unity 资产名（`minecraft_font`）。 */
	public var name:String = "";
	public var guid:String;
	/** Unity 工程内路径（`Assets/Fonts/mojangles/minecraft_font.asset`）。 */
	public var assetPath:String;
	/** lime 资源库里的 id（`assets/Fonts/mojangles/minecraft_font.asset`）。 */
	public var assetId:String;
	/** `m_AtlasPopulationMode`：0 = Static（字形已烘焙），1 = Dynamic（运行时从 OTF 光栅化）。 */
	public var atlasPopulationMode:Int = 0;
	public var isMultiAtlasTexturesEnabled:Bool = false;
	public var atlasWidth:Int = 0;
	public var atlasHeight:Int = 0;
	/** 烘焙时字形四周留的像素（图集矩形已含它，这里仅作诊断）。 */
	public var atlasPadding:Int = 0;

	public var faceInfo:FontFaceInfo = new FontFaceInfo();
	public var sourceFontFile:FontSourceFile;
	public var atlasTextures:Array<FontAtlasTexture> = [];
	/** glyphIndex → FontGlyph。 */
	public var glyphs:Map<Int, FontGlyph> = new Map();
	/** unicode → FontCharacter。 */
	public var characters:Map<Int, FontCharacter> = new Map();
	/** 回退字体（`m_FallbackFontAssetTable`）的 assetPath 列表。 */
	public var fallbackAssetPaths:Array<String> = [];

	public function new() {}

	/** 该字体是否有这个字符的字形（TMP 的 `HasCharacter`）。 */
	public function hasCharacter(unicode:Int):Bool {
		return characters.exists(unicode);
	}

	/** 取某字符的字形（没有则 null）。 */
	public function getGlyph(unicode:Int):FontGlyph {
		var c = characters.get(unicode);
		if (c == null)
			return null;
		return glyphs.get(c.glyphIndex);
	}

	/** 取某字符的字形索引（没有则 0，与 TMP 的 glyphIndex==0 表示缺字形一致）。 */
	public function getGlyphIndex(unicode:Int):Int {
		var c = characters.get(unicode);
		return c == null ? 0 : c.glyphIndex;
	}

	/**
	 * 「请求字号 → 用源 OTF 渲染时应给的像素字号」的换算系数。
	 *
	 * PORT-NOTE: TMP 的烘焙流程是「按 `pointSize` 光栅化字形，图集里每个字形的高度就是
	 * `pointSize` 下的像素高度」；运行期渲染字号 `fontSize` 时，TMP 把字形按
	 * `fontSize / pointSize` 缩放（`TMP_Text` 的 `m_CurrentFontSize / m_fontSize` 与
	 * `faceInfo.scale` 一起算 `m_ScaleMultiplier`）。因此用 OTF 渲染时，
	 * openfl 的像素字号应当取 `fontSize / pointSize`（faceInfo.scale 已在烘焙时吸收进字形度量，
	 * 实测 `m_GlyphTable.m_HorizontalAdvance` == OTF 的 advance/unitsPerEM*pointSize，
	 * 即字形度量**不含**额外 scale —— 见 tools_build/font_render_findings.md §度量校验）。
	 */
	public function otfPixelSize(requestedSize:Float):Float {
		var ps = faceInfo.pointSize;
		if (ps <= 0)
			return requestedSize;
		return requestedSize / ps;
	}
}
