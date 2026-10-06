package unity.tmpro;

// Minimal TMPro.TMP_TextInfo shim.
class TMP_TextInfo {
    public var characterCount:Int = 0;
    public var spriteCount:Int = 0;
    public var spaceCount:Int = 0;
    public var wordCount:Int = 0;
    public var linkCount:Int = 0;
    public var lineCount:Int = 0;
    public var pageCount:Int = 0;
    public var materialCount:Int = 0;
    public var characterInfo:Array<TMP_CharacterInfo> = [];
    public var wordInfo:Array<TMP_WordInfo> = [];
    public var linkInfo:Array<TMP_LinkInfo> = [];
    public var lineInfo:Array<TMP_LineInfo> = [];
    public var pageInfo:Array<TMP_PageInfo> = [];
    public var meshInfo:Array<TMP_MeshInfo> = [];

    public function new() {}
    public function Clear():Void characterCount = 0;
    public function ClearMeshInfo(updateMesh:Bool):Void {}
    public function ClearAllMeshInfo():Void {}
}

// Minimal TMPro.TMP_CharacterInfo shim.
class TMP_CharacterInfo {
    public var character:String = "";
    public var index:Int = 0;
    public var stringLength:Int = 0;
    public var isVisible:Bool = true;
    public var lineNumber:Int = 0;
    public var pageNumber:Int = 0;
    public var pointSize:Float = 0;
    public var bottomLeft:unity.Vector3 = new unity.Vector3();
    public var topLeft:unity.Vector3 = new unity.Vector3();
    public var topRight:unity.Vector3 = new unity.Vector3();
    public var bottomRight:unity.Vector3 = new unity.Vector3();
    public var origin:Float = 0;
    public var xAdvance:Float = 0;
    public var ascender:Float = 0;
    public var baseLine:Float = 0;
    public var descender:Float = 0;
    public function new() {}
}

// Minimal TMPro.TMP_WordInfo shim.
class TMP_WordInfo {
    public var firstCharacterIndex:Int = 0;
    public var lastCharacterIndex:Int = 0;
    public var characterCount:Int = 0;
    public function new() {}
    public function GetWord():String return "";
}

// Minimal TMPro.TMP_LineInfo shim.
class TMP_LineInfo {
    public var characterCount:Int = 0;
    public var firstCharacterIndex:Int = 0;
    public var lastCharacterIndex:Int = 0;
    public var visibleCharacterCount:Int = 0;
    public var lineExtents:Dynamic;
    public var length:Float = 0;
    public var ascender:Float = 0;
    public var descender:Float = 0;
    public var baseline:Float = 0;
    public function new() {}
}

// Minimal TMPro.TMP_LinkInfo shim.
class TMP_LinkInfo {
    public var hashCode:Int = 0;
    public var linkIdFirstCharacterIndex:Int = 0;
    public var linkIdLength:Int = 0;
    public var linkTextfirstCharacterIndex:Int = 0;
    public var linkTextLength:Int = 0;
    public var linkID:Array<String> = [];
    public function new() {}
    public function GetLinkID():String return "";
    public function GetLinkText():String return "";
}

// Minimal TMPro.TMP_PageInfo shim.
class TMP_PageInfo {
    public var firstCharacterIndex:Int = 0;
    public var lastCharacterIndex:Int = 0;
    public var ascender:Float = 0;
    public var baseLine:Float = 0;
    public var descender:Float = 0;
    public function new() {}
}

// Minimal TMPro.TMP_MeshInfo shim.
class TMP_MeshInfo {
    public var vertices:Array<unity.Vector3> = [];
    public var uvs0:Array<unity.Vector2> = [];
    public var colors32:Array<unity.Color32> = [];
    public var triangles:Array<Int> = [];
    public function new() {}
    public function Clear():Void {}
}
