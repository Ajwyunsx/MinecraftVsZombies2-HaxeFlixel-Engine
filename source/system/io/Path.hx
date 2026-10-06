package system.io;

import haxe.io.Path as HaxePath;

// Minimal System.IO.Path shim.
// PORT-NOTE: System.IO.Directory lives in the shared shim system/io/Directory.hx (written by the
// core work package); the duplicate copy that used to live here was removed.
class Path {
    private function new() {}

    public static function GetDirectoryName(path:String):String return HaxePath.directory(path);
    public static function GetFileName(path:String):String return HaxePath.withoutDirectory(path);
    public static function GetFileNameWithoutExtension(path:String):String return HaxePath.withoutExtension(HaxePath.withoutDirectory(path));
    public static function GetExtension(path:String):String {
        var ext = HaxePath.extension(path);
        return ext == null ? "" : "." + ext;
    }
    public static function Combine(a:String, b:String):String return HaxePath.join([a, b]);
    public static function GetFullPath(path:String):String return HaxePath.normalize(path);
    public static function ChangeExtension(path:String, ext:String):String return HaxePath.withExtension(path, ext);
    // PORT-NOTE: System.IO.Path.GetRelativePath reimplemented for the shim.
    public static function GetRelativePath(relativeTo:String, path:String):String {
        var base = HaxePath.normalize(relativeTo);
        var full = HaxePath.normalize(path);
        if (base.length > 0 && !StringTools.endsWith(base, "/")) base += "/";
        if (StringTools.startsWith(full, base)) return full.substr(base.length);
        return full;
    }
    public static inline var DirectorySeparatorChar:String = "/";
    public static inline var AltDirectorySeparatorChar:String = "\\";
}
