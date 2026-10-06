package unity.tmpro;

// Minimal TMPro.TMP_Asset shim.
class TMP_Asset extends unity.ScriptableObject {
    public var material:unity.Material;
    public var materialHashCode:Int = 0;
    public var version:String = "";
    public var hashCode:Int = 0;

    public function new() {
        super();
    }
}

// Minimal TMPro.TMP_FontAsset shim.
class TMP_FontAsset extends TMP_Asset {
    public var faceInfo:Float = 0;
    public var atlasTexture:unity.Texture2D;
    public var atlasTextures:Array<unity.Texture2D> = [];
    public var fallbackFontAssetTable:Array<TMP_FontAsset> = [];
    public var characterTable:Map<Int, TMP_Character> = [];
    public var sourceFontFile:unity.Font;
    public var fontSize:Float = 36;
    public var isMultiAtlasTexturesEnabled:Bool = false;

    public function new() {
        super();
    }
    public function HasCharacter(c:Int):Bool return false;
    public function AddSourceFontFile(fontFile:unity.Font):Bool return true;
}

// Minimal TMPro.TMP_Character shim.
class TMP_Character {
    public var unicode:Int = 0;
    public var glyph:Int = 0;
    public var scale:Float = 1;
    public function new(?unicode:Int = 0, ?glyph:Int = 0) {
        this.unicode = unicode;
        this.glyph = glyph;
    }
}

// Minimal TMPro.TMP_SpriteAsset shim.
class TMP_SpriteAsset extends TMP_Asset {
    public var spriteInfoList:Array<TMP_Sprite> = [];
    public var spriteSheet:unity.Texture2D;
    public var spriteLookupTable:Map<Int, Int> = [];

    public function new() {
        super();
    }
}

// Minimal TMPro.TMP_Sprite shim.
class TMP_Sprite {
    public var id:Int = 0;
    public var name:String = "";
    public var unicode:Int = 0;
    public var x:Float = 0;
    public var y:Float = 0;
    public var width:Float = 0;
    public var height:Float = 0;
    public function new() {}
}
