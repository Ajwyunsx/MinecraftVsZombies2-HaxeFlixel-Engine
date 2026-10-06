// Ported from: System.IO.Compression.ZipFileExtensions (minimal shim)
package system.io.compression;

import haxe.io.Bytes;
import system.io.File;
import system.io.Path;

// PORT-NOTE: C# 的 ZipArchive 扩展方法改为静态普通方法（PORTING.md §扩展方法）。
class ZipFileExtensions {
    public static function CreateEntryFromFile(archive:ZipArchive, sourceFileName:String, entryName:String):ZipArchiveEntry {
        var bytes = File.ReadAllBytes(sourceFileName);
        var entry = archive.CreateEntry(entryName);
        entry.data = bytes;
        return entry;
    }

    public static function ExtractToFile(entry:ZipArchiveEntry, destFileName:String, ?overwrite:Bool = false):Void {
        #if sys
        var dir = Path.GetDirectoryName(destFileName);
        if (dir != null && dir.length > 0) system.io.Directory.CreateDirectory(dir);
        if (!overwrite && File.Exists(destFileName)) return;
        File.WriteAllBytes(destFileName, entry.data == null ? Bytes.alloc(0) : entry.data);
        #end
    }
}
