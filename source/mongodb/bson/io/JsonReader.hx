// Ported from: MongoDB.Bson.IO.JsonReader (minimal shim)
package mongodb.bson.io;

import haxe.io.Bytes;
import system.io.Stream;
import system.io.StreamReader;

// PORT-NOTE: MVZ2.IO.SerializeHelper 的 ReadBson<T> 以此为输入读取序列化数据。
class JsonReader extends haxe.io.BytesInput {
    public function new(source:Dynamic) {
        super(resolveBytes(source));
    }

    static function resolveBytes(source:Dynamic):Bytes {
        if (source == null) return Bytes.alloc(0);
        // PORT-NOTE: system.io.Stream shim 基类提供 ReadAll()（MemoryStream 覆写为返回缓冲区），
        //   等价于 C# MemoryStream.ToArray()。
        if (Std.isOfType(source, Stream)) return (cast source:Stream).ReadAll();
        if (Std.isOfType(source, StreamReader)) return Bytes.ofString((cast source:StreamReader).ReadToEnd());
        if (Std.isOfType(source, Bytes)) return cast source;
        if (Std.isOfType(source, String)) return Bytes.ofString(cast source);
        return Bytes.alloc(0);
    }

    public static function Create(source:Dynamic):JsonReader {
        return new JsonReader(source);
    }
}
