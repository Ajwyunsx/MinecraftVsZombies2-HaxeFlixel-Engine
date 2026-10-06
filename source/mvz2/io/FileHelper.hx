package mvz2.io;

import haxe.io.Bytes;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import system.io.Directory;
import system.io.File;
import system.io.Path;
import system.io.Stream;
import unity.Application;
import unity.Task;
import unity.TaskCompletionSource;

// Ported from: Assets/Scripts/MVZ2/Files/FileHelper.cs
// PORT-NOTE: SFB.StandaloneFileBrowser / NativeFilePicker (Unity platform plugins) are replaced
// by lime.ui.FileDialog. The callbacks are asynchronous on every platform in the Haxe port.
class FileHelper {
    private function new() {}

    public static function ValidateDirectory(filePath:String):Void {
        var dir = Path.GetDirectoryName(filePath);
        if (dir == null || dir.length == 0)
            return;
        if (!Directory.Exists(dir)) {
            Directory.CreateDirectory(dir);
        }
    }
    public static function Move(src:String, dest:String, overwrite:Bool = false):Void {
        if (overwrite) {
            if (File.Exists(dest)) {
                File.Delete(dest);
            }
        }
        File.Move(src, dest);
    }
    public static function WriteBytes(stream:Stream, bytes:Bytes):Void {
        stream.Write(bytes, 0, bytes.length);
    }
    // PORT-NOTE: lime 的 FileDialog 只有实例方法（无静态 open/save）。本机 lime 为定制分支，
    // 其 Windows 后端把 filter 按逗号拆成扩展名并自动补 `*.` 前缀，因此这里传裸扩展名列表。
    private static function MakeFilter(extensions:Array<String>):String {
        return (extensions == null || extensions.length == 0) ? null : extensions.join(",");
    }
    public static function OpenExternalFile(extensions:Array<String>, importAction:String->Void):Task {
        var t = new TaskCompletionSource();
        // PORT-NOTE: lime's file dialog is always asynchronous; the standalone branch of the
        // original (which invoked the callback immediately) has the same observable result.
        var dialog = new FileDialog();
        dialog.onSelect.add(function(path:String) {
            if (path == null || path.length == 0) {
                t.SetResult(null);
                return;
            }
            if (importAction != null) importAction(path);
            t.SetResult(path);
        });
        dialog.onCancel.add(function() t.SetResult(null));
        dialog.browse(FileDialogType.OPEN, MakeFilter(extensions));
        return t.task;
    }
    // PORT-NOTE: C# `async Task<string?> SaveExternalFile(...)` → Task; the awaited value is
    // read through `task.awaitResult()` by the caller.
    // PORT-NOTE: 用 browse(SAVE) 而不是 save()：lime 的 save() 需要预先提供 Resource 数据，
    // 而本移植的调用方是在拿到路径后再自行写文件（与 C# 的 SFB 分支一致）。
    public static function SaveExternalFile(defaultName:String, extensions:Array<String>, saveAction:String->Void):Task {
        var t = new TaskCompletionSource();
        var dialog = new FileDialog();
        dialog.onSelect.add(function(exportPath:String) {
            if (exportPath == null || exportPath.length == 0) {
                t.SetResult(null);
                return;
            }
            if (saveAction != null) saveAction(exportPath);
            t.SetResult(exportPath);
        });
        dialog.onCancel.add(function() t.SetResult(null));
        dialog.browse(FileDialogType.SAVE, MakeFilter(extensions), defaultName);
        return t.task;
    }
}
