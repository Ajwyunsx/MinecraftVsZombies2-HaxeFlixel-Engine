package mvz2.io;

import ngettext.Catalog;
import system.io.MemoryStream;
import system.io.Stream;
import system.io.StreamReader;
import system.io.StreamWriter;
import system.io.compression.ZipArchiveEntry;
import system.text.Encoding;
import unity.Task;

// Ported from: Assets/Scripts/MVZ2/Files/ZipArchiveHelper.cs
// PORT-NOTE: C# extension methods on ZipArchiveEntry → static methods taking the entry first.
// The async overloads run synchronously (Haxe has no async streams) and return a completed Task.
class ZipArchiveHelper {
    private function new() {}

    public static function ReadString(entry:ZipArchiveEntry, encoding:Encoding):String {
        var zipStream = entry.Open();
        var reader = new StreamReader(zipStream, encoding);
        var result = reader.ReadToEnd();
        reader.Dispose();
        zipStream.Dispose();
        return result;
    }

    public static function ReadStringAsync(entry:ZipArchiveEntry, encoding:Encoding):Task {
        return Task.fromResult(ReadString(entry, encoding));
    }
    public static function WriteString(entry:ZipArchiveEntry, str:String, encoding:Encoding):Void {
        var zipStream = entry.Open();
        var reader = new StreamWriter(zipStream, encoding);
        reader.Write(str);
        reader.Dispose();
        zipStream.Dispose();
        // PORT-NOTE: ZipArchiveEntry.set_data 为私有实现函数，改用其公开属性 data（同 ZipFileExtensions 的写法）。
        entry.data = encoding.GetBytes(str);
    }

    public static function WriteStringAsync(entry:ZipArchiveEntry, str:String, encoding:Encoding):Task {
        WriteString(entry, str, encoding);
        return Task.completedTask();
    }
    public static function ReadCatalog(entry:ZipArchiveEntry, language:String):Catalog {
        var zipStream = entry.Open();
        var memory = new MemoryStream();
        zipStream.CopyTo(memory);
        memory.Seek(0, Stream.SeekOriginBegin);
        return new Catalog(memory, language);
    }
    public static function ReadCatalogAsync(entry:ZipArchiveEntry, language:String):Task {
        return Task.fromResult(ReadCatalog(entry, language));
    }
    public static function ReadBytes(entry:ZipArchiveEntry):haxe.io.Bytes {
        var entryStream = entry.Open();
        var memory = new MemoryStream();
        entryStream.CopyTo(memory);
        return memory.ToArray();
    }
    public static function ReadBytesAsync(entry:ZipArchiveEntry):Task {
        return Task.fromResult(ReadBytes(entry));
    }
}
