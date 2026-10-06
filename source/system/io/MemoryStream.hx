package system.io;

import haxe.io.Bytes;
import system.io.Stream;
import unity.Task;

// Minimal System.IO.MemoryStream shim.
class MemoryStream extends Stream {
    private var buffer:Bytes;

    public function new(?initial:Bytes) {
        super();
        buffer = initial != null ? initial : Bytes.alloc(0);
        Length = buffer.length;
    }

    override public function Read(target:Bytes, offset:Int, count:Int):Int {
        if (Position >= buffer.length) return 0;
        var available = buffer.length - Position;
        var n = count < available ? count : available;
        target.blit(offset, buffer, Position, n);
        Position += n;
        return n;
    }
    override public function Write(source:Bytes, offset:Int, count:Int):Void {
        var need = Position + count;
        if (need > buffer.length) {
            var grown = Bytes.alloc(need);
            grown.blit(0, buffer, 0, buffer.length);
            buffer = grown;
        }
        buffer.blit(Position, source, offset, count);
        Position = need;
        Length = buffer.length;
    }
    override public function Seek(offset:Int, origin:Int):Int {
        var target = switch (origin) {
            case Stream.SeekOriginBegin: offset;
            case Stream.SeekOriginCurrent: Position + offset;
            case Stream.SeekOriginEnd: buffer.length + offset;
            default: offset;
        }
        Position = target;
        return Position;
    }
    override public function ReadToEnd():String {
        var s = buffer.sub(Position, buffer.length - Position).toString();
        Position = buffer.length;
        return s;
    }
    override public function ReadAll():Bytes return buffer;
    public function ToArray():Bytes return buffer;
    override public function Flush():Void {}
    override public function Close():Void {}
}
