package system.io;

import haxe.io.Bytes;
import system.io.Stream;

// Minimal System.IO.StreamWriter shim.
class StreamWriter {
    private var stream:Stream;
    private var encoding:Dynamic;

    public function new(stream:Stream, ?encoding:Dynamic) {
        this.stream = stream;
        this.encoding = encoding;
    }

    public function Write(str:String):Void {
        var bytes = Bytes.ofString(str);
        stream.Write(bytes, 0, bytes.length);
    }
    public function WriteAsync(str:String):unity.Task {
        Write(str);
        return unity.Task.completedTask();
    }
    public function WriteLine(str:String):Void {
        Write(str + "\n");
    }
    public function Flush():Void stream.Flush();
    public function Close():Void {}
    public function Dispose():Void {}
}
