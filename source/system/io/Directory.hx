// Ported from: System.IO.Directory (minimal shim)
package system.io;

class Directory {
    public static function Exists(path:String):Bool {
        #if sys
        return sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path);
        #else
        return false;
        #end
    }

    public static function CreateDirectory(path:String):Void {
        #if sys
        if (!sys.FileSystem.exists(path)) sys.FileSystem.createDirectory(path);
        #end
    }

    public static function Delete(path:String, recursive:Bool):Void {
        #if sys
        if (!sys.FileSystem.exists(path)) return;
        if (recursive) {
            for (entry in sys.FileSystem.readDirectory(path)) {
                var child = Path.Combine(path, entry);
                if (sys.FileSystem.isDirectory(child)) Delete(child, true);
                else sys.FileSystem.deleteFile(child);
            }
        }
        sys.FileSystem.deleteDirectory(path);
        #end
    }

    public static function GetFiles(path:String, pattern:String, option:SearchOption = SearchOption.TopDirectoryOnly):Array<String> {
        return Enumerate(path, pattern, option, false);
    }

    public static function GetDirectories(path:String, ?pattern:String, option:SearchOption = SearchOption.TopDirectoryOnly):Array<String> {
        return Enumerate(path, pattern, option, true);
    }

    public static function EnumerateFiles(path:String, ?pattern:String, option:SearchOption = SearchOption.TopDirectoryOnly):Array<String> {
        return Enumerate(path, pattern, option, false);
    }

    public static function EnumerateDirectories(path:String, ?pattern:String, option:SearchOption = SearchOption.TopDirectoryOnly):Array<String> {
        return Enumerate(path, pattern, option, true);
    }

    public static function GetCurrentDirectory():String {
        #if sys
        return Sys.getCwd();
        #else
        return "";
        #end
    }

    static function Enumerate(path:String, pattern:String, option:SearchOption, directories:Bool):Array<String> {
        var result:Array<String> = [];
        #if sys
        if (!sys.FileSystem.exists(path) || !sys.FileSystem.isDirectory(path)) return result;
        for (entry in sys.FileSystem.readDirectory(path)) {
            var full = Path.Combine(path, entry);
            var isDir = sys.FileSystem.isDirectory(full);
            if (isDir == directories) {
                if (pattern == null || matchPattern(entry, pattern)) result.push(full);
            }
            if (option == SearchOption.AllDirectories) {
                result = result.concat(Enumerate(full, pattern, option, directories));
            }
        }
        #end
        return result;
    }

    static function matchPattern(name:String, pattern:String):Bool {
        if (pattern == "*" || pattern == "*.*") return true;
        var suffix = pattern.lastIndexOf("*");
        if (suffix < 0) return name == pattern;
        return name.substr(name.length - (pattern.length - suffix - 1)) == pattern.substr(suffix + 1);
    }
}
