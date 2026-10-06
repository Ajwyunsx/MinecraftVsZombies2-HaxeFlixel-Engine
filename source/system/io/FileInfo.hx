// Ported from: System.IO.FileInfo (minimal shim)
package system.io;

class FileInfo {
    public var FullName:String;
    public var Name(get, never):String;
    function get_Name():String return Path.GetFileName(FullName);

    public function new(path:String) {
        FullName = path;
    }

    public function Exists():Bool return File.Exists(FullName);
    public function Delete():Void File.Delete(FullName);
}
