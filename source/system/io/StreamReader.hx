package system.io;

import haxe.io.Bytes;
import system.io.Stream;

// Minimal System.IO.StreamReader shim.
class StreamReader {
    private var stream:Stream;
    private var encoding:Dynamic;

    public function new(stream:Stream, ?encoding:Dynamic) {
        this.stream = stream;
        this.encoding = encoding;
    }

    public function ReadToEnd():String {
        return stream.ReadToEnd();
    }
    public function ReadToEndAsync():unity.Task {
        return unity.Task.fromResult(ReadToEnd());
    }
    public function ReadLine():String {
        return null;
    }
    public function Close():Void {}
    public function Dispose():Void {}
}
