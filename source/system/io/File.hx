package system.io;

import haxe.io.Bytes;
import system.io.FileStream;

// Minimal System.IO.File shim.
class File {
    private function new() {}

    public static function Exists(path:String):Bool return sys.FileSystem.exists(path) && !sys.FileSystem.isDirectory(path);
    public static function Delete(path:String):Void {
        if (Exists(path)) sys.FileSystem.deleteFile(path);
    }
    public static function Move(src:String, dest:String):Void {
        sys.io.File.saveBytes(dest, sys.io.File.getBytes(src));
        sys.FileSystem.deleteFile(src);
    }
    public static function Copy(src:String, dest:String, overwrite:Bool = false):Void {
        if (overwrite) Delete(dest);
        sys.io.File.saveBytes(dest, sys.io.File.getBytes(src));
    }
    // PORT-NOTE: C# 的 File.Open(string, FileMode) 在移植层用模式字符串实现（FileStream 依赖 "r"/"w"/"a"）；
    // 为兼容按原样书写的调用点，这里同时接受 FileMode 枚举值。
    public static function Open(path:String, mode:Dynamic):FileStream return new FileStream(path, normalizeMode(mode));
    private static function normalizeMode(mode:Dynamic):String {
        if (mode == null)
            return "r";
        if (Std.isOfType(mode, String))
            return cast mode;
        var fm:FileMode = cast mode;
        if (fm == FileMode.CreateNew || fm == FileMode.Create || fm == FileMode.Truncate || fm == FileMode.Append)
            return "w";
        return "r";
    }
    public static function OpenRead(path:String):FileStream return new FileStream(path, "r");
    public static function OpenWrite(path:String):FileStream return new FileStream(path, "w");
    public static function Create(path:String):FileStream return new FileStream(path, "w");
    public static function ReadAllText(path:String):String return sys.io.File.getContent(path);
    public static function WriteAllText(path:String, contents:String):Void sys.io.File.saveContent(path, contents);
    public static function ReadAllBytes(path:String):Bytes return sys.io.File.getBytes(path);
    public static function WriteAllBytes(path:String, bytes:Bytes):Void sys.io.File.saveBytes(path, bytes);
    public static function ReadAllLines(path:String):Array<String> {
        var content = sys.io.File.getContent(path);
        return content.split("\n");
    }
}
