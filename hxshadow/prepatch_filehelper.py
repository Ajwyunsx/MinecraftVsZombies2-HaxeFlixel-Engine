import io

P = 'hxshadow/mvz2/io/FileHelper.hx'
s = io.open(P, encoding='utf-8').read()
s = s.replace("""        new lime.ui.FileDialog().open(extensions, function(path:String) {
            if (path == null || path.length == 0) {
                t.SetResult(null);
                return;
            }
            if (importAction != null) importAction(path);
            t.SetResult(path);
        });
        return t.task;""", """        // SHADOWFIX: lime 8.x 的 FileDialog.open 是实例方法，回调经 onSelect 事件返回（参数为 filter 字符串）。
        var dialog = new lime.ui.FileDialog();
        dialog.onSelect.add(function(path:String):Void {
            if (path == null || path.length == 0) {
                t.SetResult(null);
                return;
            }
            if (importAction != null) importAction(path);
            t.SetResult(path);
        });
        dialog.open(extensions.join(";"));
        return t.task;""")
s = s.replace("""        new lime.ui.FileDialog().save(defaultName, extensions, function(exportPath:String) {""",
              """        var dialog = new lime.ui.FileDialog();
        dialog.onSave.add(function(exportPath:String):Void {""")
if "dialog.save(" not in s:
    s = s.replace("""            if (saveAction != null) saveAction(exportPath);
            t.SetResult(exportPath);
        });
        return t.task;""", """            if (saveAction != null) saveAction(exportPath);
            t.SetResult(exportPath);
        });
        dialog.save(defaultName, extensions.join(";"));
        return t.task;""")
io.open(P, 'w', encoding='utf-8', newline='').write(s)
print('patched')
