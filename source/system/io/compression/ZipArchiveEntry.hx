// Ported from: System.IO.Compression.ZipArchiveEntry (minimal shim)
package system.io.compression;

import haxe.io.Bytes;
import system.io.MemoryStream;
import system.io.Stream;

class ZipArchiveEntry {
    public var Name(default, null):String;
    public var FullName(default, null):String;
    public var Length(get, never):haxe.Int64;
    function get_Length():haxe.Int64 return haxe.Int64.ofInt(getBytes().length);

    // PORT-NOTE: 条目的原始（解压后）字节，供 MVZ2.IO 的读取扩展方法使用。
    public var data(get, set):Bytes;
    function get_data():Bytes return getBytes();
    function set_data(value:Bytes):Bytes {
        buffer = new MemoryStream(value);
        return value;
    }

    private var buffer:MemoryStream;

    public function new(fullName:String, ?bytes:Bytes) {
        FullName = fullName;
        var i = fullName.lastIndexOf("/");
        Name = i < 0 ? fullName : fullName.substr(i + 1);
        buffer = new MemoryStream(bytes);
    }

    public function Open():Stream {
        buffer.Seek(0, system.io.SeekOrigin.Begin);
        return buffer;
    }

    public function getBytes():Bytes {
        return buffer.ToArray();
    }

    public function Delete():Void {}

    public function ToString():String {
        return FullName;
    }
}
