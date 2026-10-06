package mvz2.io;

import mvz2logic.serialization.SerializeHelper;
import system.io.MemoryStream;
import system.io.Stream;
import unity.Application;
import unity.MonoBehaviour;

// Ported from: Assets/Scripts/MVZ2/Files/FileManager.cs
class FileManager extends MonoBehaviour {
    public function WriteStringFile(path:String, content:String):Void {
        if (!compressed && IsEditor()) {
            SerializeHelper.Write(path, content);
        } else {
            SerializeHelper.WriteCompressedStringFile(path, content);
        }
    }
    public function ReadStringFile(path:String):String {
        if (SerializeHelper.IsGZipCompressed(path)) {
            return SerializeHelper.ReadCompressed(path);
        }
        return SerializeHelper.Read(path);
    }
    public function OpenFileWrite(path:String):Stream {
        if (!compressed && IsEditor()) {
            return SerializeHelper.OpenWrite(path);
        } else {
            return SerializeHelper.OpenCompressedWrite(path);
        }
    }
    public function OpenFileRead(path:String):MemoryStream {
        if (SerializeHelper.IsGZipCompressed(path)) {
            return SerializeHelper.OpenCompressedRead(path);
        }
        return SerializeHelper.OpenRead(path);
    }
    private function IsEditor():Bool {
        return Application.isEditor;
    }

    @:serializeField
    private var compressed:Bool = true;
}
