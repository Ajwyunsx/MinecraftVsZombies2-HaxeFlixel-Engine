package system.io;

import haxe.io.Bytes;
import unity.Task;

// Minimal System.IO.Stream shim.
class Stream {
    public function new() {}

    public function Read(buffer:Bytes, offset:Int, count:Int):Int {
        return 0;
    }
    public function Write(buffer:Bytes, offset:Int, count:Int):Void {}
    public function Seek(offset:Int, origin:Int):Int {
        return 0;
    }
    public function Flush():Void {}
    public function Close():Void {}
    public function Dispose():Void {}
    public function CopyTo(destination:Stream):Void {
        var data = ReadAll();
        destination.Write(data, 0, data.length);
    }
    // PORT-NOTE: async variants run synchronously; Haxe has no async streams.
    public function ReadToEndAsync():Task {
        return Task.fromResult(ReadToEnd());
    }
    public function CopyToAsync(destination:Stream):Task {
        CopyTo(destination);
        return Task.completedTask();
    }
    public function WriteAsync(content:String):Task {
        var bytes = Bytes.ofString(content);
        Write(bytes, 0, bytes.length);
        return Task.completedTask();
    }
    public function ReadToEnd():String {
        return "";
    }
    public function ReadAll():Bytes {
        return Bytes.alloc(0);
    }
    public var Position:Int = 0;
    public var Length:Int = 0;

    public static inline var SeekOriginBegin:Int = 0;
    public static inline var SeekOriginCurrent:Int = 1;
    public static inline var SeekOriginEnd:Int = 2;
}
