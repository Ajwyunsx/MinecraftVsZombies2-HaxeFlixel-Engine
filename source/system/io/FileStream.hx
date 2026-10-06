package system.io;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import system.io.Stream;

// Minimal System.IO.FileStream shim.
class FileStream extends Stream {
    private var path:String;
    private var mode:String;
    private var writing:Bool;
    private var output:BytesOutput;

    public function new(path:String, mode:String) {
        super();
        this.path = path;
        this.mode = mode;
        this.writing = mode.indexOf("w") >= 0 || mode.indexOf("a") >= 0;
        if (!writing) {
            var bytes = sys.io.File.getBytes(path);
            Length = bytes.length;
        } else {
            output = new BytesOutput();
        }
    }

    override public function Read(target:Bytes, offset:Int, count:Int):Int {
        var bytes = sys.io.File.getBytes(path);
        if (Position >= bytes.length) return 0;
        var available = bytes.length - Position;
        var n = count < available ? count : available;
        target.blit(offset, bytes, Position, n);
        Position += n;
        return n;
    }
    override public function Write(source:Bytes, offset:Int, count:Int):Void {
        output.writeBytes(source, offset, count);
        Position += count;
        Length = Position;
    }
    override public function ReadToEnd():String {
        var bytes = sys.io.File.getBytes(path);
        var s = bytes.sub(Position, bytes.length - Position).toString();
        Position = bytes.length;
        return s;
    }
    override public function ReadAll():Bytes return sys.io.File.getBytes(path);
    override public function Flush():Void {
        if (writing && output != null) {
            File.WriteAllBytes(path, output.getBytes());
        }
    }
    override public function Close():Void {
        Flush();
    }
}
