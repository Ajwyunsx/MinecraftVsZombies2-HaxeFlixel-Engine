// Ported from: Assets/Scripts/MVZ2/Talks/TalkHelper.cs
package mvz2.talk;

import mvz2.io.XMLHelper;
import mvz2.talkdata.TalkScript;
import pvzengine.NamespaceID;
import system.xml.XmlDocument;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING
using mvz2logic.level.LogicLevelExt;  // EXTUSING

// PORT-NOTE: C# 的扩展方法改为静态方法（PORTING.md §扩展方法），
// 调用处可 `using mvz2.talk.TalkHelper;` 保持原写法。
class TalkHelper {
    public static function SimpleStartTalk(controller:TalkController, groupId:NamespaceID, section:Int, delay:Float = 0, ?onSkipped:Void->Void, ?onStarted:Void->Void, ?onEnd:Void->Void):Void {
        if (controller.WillSkipTalk(groupId, section)) {
            controller.AutoSkipTalks(groupId, section, function() {
                if (onSkipped != null) onSkipped();
                if (onEnd != null) onEnd();
            });
        } else {
            if (onStarted != null) onStarted();
            controller.StartTalk(groupId, section, delay, onEnd);
        }
    }
    // PORT-NOTE: C# 的 async Task<TalkResult> 在 Haxe 中同步化，直接返回 TalkResult。
    public static function SimpleStartTalkAsync(controller:TalkController, groupId:NamespaceID, section:Int, delay:Float = 0, ?onStarted:Void->Void):TalkResult {
        if (controller.WillSkipTalk(groupId, section)) {
            controller.AutoSkipTalksAsync(groupId, section);
            return TalkResult.Skipped;
        }

        if (onStarted != null) onStarted();
        controller.StartTalkAsync(groupId, section, delay);
        return TalkResult.Started;
    }

    public static function CreateTalkScriptNodes(document:XmlDocument, node:XmlNode, name:String, scripts:Array<TalkScript>, ?comment:String):XmlNode {
        if (scripts != null && scripts.length > 0) {
            XMLHelper.AddComment(document, node, comment);

            var scriptsNode = document.CreateElement(name);
            for (script in scripts) {
                var scriptNode = document.CreateElement("script");
                scriptNode.InnerText = script.toString();
                scriptsNode.AppendChild(scriptNode);
            }
            node.AppendChild(scriptsNode);
            return scriptsNode;
        }
        return null;
    }
}

enum abstract TalkResult(Int) from Int to Int {
    var NotStarted = 0;
    var Skipped = 1;
    var Started = 2;
}
