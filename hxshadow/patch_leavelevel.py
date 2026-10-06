import io

p = 'source/mvz2/options/OptionsDialogController.hx'
s = io.open(p, encoding='utf-8').read()
old = '''                    if (level.IsGameStarted() || level.GetCurrentFlag() > 0) {
                        var title = Main.LanguageManager._(LogicStrings.BACK);
                        var desc = Main.LanguageManager._(DIALOG_DESC_LEAVE_LEVEL);

                        var result = Main.Scene.ShowDialogSelect(title, desc);
                        if (!result)
                            return;
                    }
                    if (level.IsGameStarted()) {
                        Main.LevelManager.SaveLevel();
                    }
                    level.ExitLevel();'''
new = '''                    // PORT-NOTE: C# \u7684 ShowDialogSelect \u8fd4\u56de bool\uff08\u540c\u6b65\u7b49\u5f85\u9009\u62e9\uff09\uff1b
                    // \u79fb\u690d\u5c42\u4e3a\u56de\u8c03\u5f0f API\uff0c\u6545\u628a\u201c\u786e\u8ba4\u9000\u51fa\u540e\u201d\u7684\u903b\u8f91\u653e\u8fdb\u56de\u8c03\u3002
                    var doLeaveLevel = function():Void {
                        if (level.IsGameStarted()) {
                            Main.LevelManager.SaveLevel();
                        }
                        level.ExitLevel();
                    };
                    if (level.IsGameStarted() || level.GetCurrentFlag() > 0) {
                        var title = Main.LanguageManager._(LogicStrings.BACK);
                        var desc = Main.LanguageManager._(DIALOG_DESC_LEAVE_LEVEL);

                        Main.Scene.ShowDialogSelect(title, desc, function(result:Bool):Void {
                            if (result)
                                doLeaveLevel();
                        });
                    }
                    else {
                        doLeaveLevel();
                    }'''
assert old in s, 'leavelevel'
s = s.replace(old, new)
io.open(p, 'w', encoding='utf-8', newline='').write(s)
print('ok')
