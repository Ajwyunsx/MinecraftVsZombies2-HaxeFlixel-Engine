package mvz2.debugs;

import mvz2.io.FileHelper;
import mvz2.managers.MainManager.DuplicateInstanceException;
import system.io.Directory;
import system.io.File;
import system.io.Path;
import system.io.Stream;
import system.io.StreamWriter;
import system.io.compression.ZipArchive;
import system.io.compression.ZipArchiveMode;
import unity.Application;
import unity.Application.LogType;
import unity.MonoBehaviour;
import unity.UnityObject;

// Ported from: Assets/Scripts/MVZ2/Debugs/MVZ2Logger.cs
// PORT-NOTE: C# `lock (obj)` has no Haxe counterpart (single-threaded runtime), so the lock
// blocks are dropped while keeping the guarded logic intact.
class MVZ2Logger extends MonoBehaviour {
    public function ExportLogFilePack(destPath:String):Bool {
        var dir = Application.persistentDataPath;
        if (!Directory.Exists(dir))
            return false;

        CloneCurrentLog();

        FileHelper.ValidateDirectory(destPath);
        var files = [
            GetLogClonePath(),
            GetPrevLogPath(),
        ];
        var stream = File.Open(destPath, "w");
        var archive = new ZipArchive(stream, ZipArchiveMode.Create);

        for (filePath in files) {
            if (!File.Exists(filePath))
                continue;
            var entryName = Path.GetRelativePath(dir, filePath);
            entryName = StringTools.replace(entryName, "\\", "/");
            // PORT-NOTE: C# 调 System.IO.Compression.ZipFileExtensions.CreateEntryFromFile(archive, filePath, entryName)。
            // system.io.compression 的 shim 未提供该扩展方法，这里用 CreateEntry + 写入文件字节等价实现。
            var entry = archive.CreateEntry(entryName);
            entry.data = File.ReadAllBytes(filePath);
        }

        archive.Dispose();
        stream.Dispose();
        DeleteLogClone();

        return true;
    }

    // #region 生命周期
    function OnEnable():Void {
        Application.logMessageReceivedThreaded.push(OnLogReceivedCallback);
    }
    function OnDisable():Void {
        Application.logMessageReceivedThreaded.remove(OnLogReceivedCallback);
    }
    private function Awake():Void {
        UnityObject.DontDestroyOnLoad(gameObject);

        var path = GetLogPath();
        // 开启游戏时将上一次的日志前缀加上-prev。
        if (File.Exists(path)) {
            var prevPath = GetPrevLogPath();
            if (File.Exists(prevPath)) {
                File.Delete(prevPath);
            }
            File.Move(path, prevPath);
        }
        StartLogWriter(path);

        if (Instance == null) {
            Instance = this;
        } else {
            throw new DuplicateInstanceException(name);
        }
    }
    // PORT-NOTE: the `#if UNITY_ANDROID` OnApplicationFocus overload is only needed to close the
    // log stream when the Android app loses focus; the Haxe port closes it on quit instead.
    private function OnApplicationQuit():Void {
        // 退出游戏后，关闭文件流。
        CloseLogWriter();
    }
    // #endregion

    // #region 事件回调
    function OnLogReceivedCallback(logString:String, stackTrace:String, type:LogType):Void {
        var d = Date.now();
        var timestamp = '${pad(d.getFullYear(), 4)}-${pad(d.getMonth() + 1, 2)}-${pad(d.getDate(), 2)} ${pad(d.getHours(), 2)}:${pad(d.getMinutes(), 2)}:${pad(d.getSeconds(), 2)}';
        var sb = new StringBuf();
        sb.add('[$timestamp] ');
        sb.add('[$type] ');
        sb.add(logString);
        sb.add("\n");
        sb.add(stackTrace);
        sb.add("\n\n");

        if (logWriter == null) {
            StartLogWriter(GetLogPath());
        }
        if (logWriter != null) {
            logWriter.WriteLine(sb.toString());
            logWriter.Flush();
        }
    }
    // #endregion

    // #region 输出日志内容
    private function GetLogPath():String {
        return Path.Combine(Application.persistentDataPath, '${fileName}${extension}');
    }
    private function GetPrevLogPath():String {
        return Path.Combine(Application.persistentDataPath, '${fileName}${prevSuffix}${extension}');
    }
    private function GetLogClonePath():String {
        return Path.Combine(Application.persistentDataPath, '${fileName}${cloneSuffix}${extension}');
    }
    private function StartLogWriter(path:String):Void {
        if (logWriter == null) {
            logWriter = new StreamWriter(new system.io.FileStream(path, "w"), null);
            AutoFlush(logWriter);
        }
    }
    private function CloseLogWriter():Void {
        if (logWriter != null) {
            logWriter.Close();
            logWriter = null;
        }
    }
    // PORT-NOTE: C# `StreamWriter.AutoFlush = true`.
    private function AutoFlush(writer:StreamWriter):Void {}
    private static function pad(value:Int, width:Int):String {
        var s = Std.string(value);
        while (s.length < width) s = "0" + s;
        return s;
    }
    // #endregion

    // #region 导出日志
    private function CloneCurrentLog():Void {
        CloseLogWriter();

        DeleteLogClone();
        var currentLogPath = GetLogPath();
        var cloneLogPath = GetLogClonePath();
        File.Copy(currentLogPath, cloneLogPath);
    }
    private function DeleteLogClone():Void {
        var cloneLogPath = GetLogClonePath();
        if (!File.Exists(cloneLogPath))
            return;
        File.Delete(cloneLogPath);
    }
    // #endregion

    public static var Instance(default, null):MVZ2Logger = null;
    @:serializeField
    private var fileName:String = "mvz2_log";
    @:serializeField
    private var cloneSuffix:String = "-current";
    @:serializeField
    private var prevSuffix:String = "-prev";
    @:serializeField
    private var extension:String = ".log";
    private var logWriter:StreamWriter;
}
