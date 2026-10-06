// Ported from: Assets/Scripts/MVZ2/Managers/FontManager.cs
package mvz2.managers;

import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;
import unity.*;
import unity.Debug;
import Main;

class FontManager extends MonoBehaviour
{
	public function Init():Void
	{
		//TMP_Text.OnSpriteAssetRequest += OnSpriteAssetRequestCallback;
	}
	public function InitFontSprites():Void
	{
	}
	// PORT-NOTE: 以下 #region「自动生成字体贴图，暂时弃用」中的代码依赖 TextMeshPro 的
	// TMP_SpriteAsset / TMP_SpriteGlyph / TMP_SpriteCharacter / ShaderUtilities 内部实现。
	// HaxeFlixel 侧没有等价的运行期字体图集生成 API，该区域整体不移植。
	// 原文件中 Init() 只是把回调注释掉、InitFontSprites() 为空实现，因此运行时行为与原文一致。
	// TODO-PORT: TextMeshPro 运行期 sprite asset 生成无等价实现。
	/*
	private function OnSpriteAssetRequestCallback(hashCode:Int, assetName:String):TMP_SpriteAsset { ... }
	private function InitAlmanacTagIcons():Void { ... }
	private function GenerateSpritesForTexture(...):Void { ... }
	private function GenerateSpriteGlyph(...):Void { ... }
	private function GetOrCreateSpriteAsset(...):TMP_SpriteAsset { ... }
	private function GetSpriteAsset(name:String):TMP_SpriteAsset { ... }
	private function CreateSpriteAsset():TMP_SpriteAsset { ... }
	*/

	public var Main(get, never):MainManager;
	function get_Main():MainManager return MainManager.Instance;
}
