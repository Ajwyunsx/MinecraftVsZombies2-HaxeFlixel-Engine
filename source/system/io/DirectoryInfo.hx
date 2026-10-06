// Ported from: System.IO.DirectoryInfo (minimal shim)
package system.io;

class DirectoryInfo {
    public var FullName:String;
    public var Name(get, never):String;
    function get_Name():String return Path.GetFileName(FullName);

    public function new(path:String) {
        FullName = path;
    }

    public function Exists():Bool return Directory.Exists(FullName);
    public function GetFiles(?pattern:String, option:SearchOption = SearchOption.TopDirectoryOnly):Array<String> {
        return Directory.GetFiles(FullName, pattern, option);
    }
    public function GetDirectories(?pattern:String, option:SearchOption = SearchOption.TopDirectoryOnly):Array<String> {
        return Directory.GetDirectories(FullName, pattern, option);
    }
    public function Create():Void Directory.CreateDirectory(FullName);
    public function Delete(recursive:Bool):Void Directory.Delete(FullName, recursive);
}
