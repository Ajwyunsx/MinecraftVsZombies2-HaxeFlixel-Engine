package unity;

import flixel.graphics.FlxGraphic;

// Minimal UnityEngine.Texture2D shim.
class Texture2D extends UnityObject {
    public var width:Int;
    public var height:Int;
    public var filterMode:FilterMode = FilterMode.Bilinear;
    public var wrapMode:Dynamic = null;

    // PORT-NOTE: 移植层扩展（无 C# 对应字段）。Unity 的 Texture2D 自身持有 GPU 像素，
    // 移植层把解码后的像素放在 FlxGraphic 上（见 unity.addressableassets.ResourceManifest.decodeImage），
    // 这里挂一份引用，使「贴图 → 位图/帧」的取值只需要一次解码：
    //   SpriteFrameFactory.getGraphic(texture) → texture.graphic
    public var graphic:FlxGraphic = null;
    // PORT-NOTE: 移植层扩展。贴图在 HaxePort/assets/ 下的相对路径（如
    // GameContent/Assets/mvz2/sprites/init/titlescreen.png），由 SpriteTextureCache.getTexture 写入；
    // SpriteFrameFactory 按它到 ResourceManifest 取（并复用）同一份解码结果。
    public var assetPath:String = null;

    public function new(?width:Int = 0, ?height:Int = 0) {
        super();
        this.width = width;
        this.height = height;
    }

    // PORT-NOTE: 补全 RenderTexture 相关 API（移植层无 GPU 渲染，仅记录尺寸与像素矩形）。
    public function Reinitialize(width:Int, height:Int):Void {
        this.width = width;
        this.height = height;
    }
    public function ReadPixels(source:Rect, destX:Int, destY:Int):Void {}
    public function LoadImage(bytes:haxe.io.Bytes):Void {
        // PORT-NOTE: 贴图解码在资源整合阶段由 lime.graphics 实现，此处仅保留数据引用。
        rawBytes = bytes;
    }

    // PORT-NOTE: added for MVZ2.Sprites.SpriteHelper (pixel access + PNG encoding).
    private var rawBytes:haxe.io.Bytes;
    public var pixels32(default, null):Array<Color32>;

    public function GetPixels32(?buffer:Array<Color32>):Array<Color32> {
        if (buffer != null && pixels32 != null) {
            for (i in 0...Std.int(Math.min(buffer.length, pixels32.length))) buffer[i] = pixels32[i];
            return buffer;
        }
        if (pixels32 == null) pixels32 = [];
        return pixels32;
    }
    public function SetPixels32(colors:Array<Color32>):Void {
        pixels32 = colors;
    }
    public function GetPixels():Array<Color> {
        if (pixels32 == null) return [];
        return [for (p in pixels32) p.toColor()];
    }
    public function SetPixels(colors:Array<Color>):Void {
        pixels32 = [for (c in colors) new Color32(Std.int(c.r * 255), Std.int(c.g * 255), Std.int(c.b * 255), Std.int(c.a * 255))];
    }
    public function Apply():Void {}
    public function EncodeToPNG():haxe.io.Bytes {
        if (rawBytes != null) return rawBytes;
        return haxe.io.Bytes.alloc(0);
    }
    public function EncodeToJPG(?quality:Int = 75):haxe.io.Bytes {
        if (rawBytes != null) return rawBytes;
        return haxe.io.Bytes.alloc(0);
    }
    public function Resize(newWidth:Int, newHeight:Int):Bool {
        width = newWidth;
        height = newHeight;
        return true;
    }
}
