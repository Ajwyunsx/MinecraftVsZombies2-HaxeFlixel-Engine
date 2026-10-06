// Ported from: Assets/Scripts/MVZ2/Talks/Data/TalkSentence.cs
package mvz2.talkdata;

import mvz2.io.XMLHelper;
import mvz2.managers.MainManager;
import pvzengine.NamespaceID;
import system.xml.XmlDocument;
import system.xml.XmlNode;
import mvz2.talk.TalkHelper; // PORT-NOTE: CreateTalkScriptNodes 是 TalkHelper 的扩展方法
using mvz2.io.XMLHelper;  // EXTUSING
using mvz2.talk.TalkHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class TalkSentence {
    public var text:String;
    public var description:String;
    public var speaker:NamespaceID;
    public var speakerName:String;
    public var sounds:Array<NamespaceID>;
    public var variant:NamespaceID;
    public var startScripts:Array<TalkScript>;
    public var clickScripts:Array<TalkScript>;

    public function new(text:String, sounds:Array<NamespaceID>) {
        this.text = text;
        this.sounds = sounds;
    }

    public function ToXmlNode(document:XmlDocument):XmlNode {
        var node = document.CreateElement("sentence");
        if (NamespaceID.IsValid(speaker))
            XMLHelper.CreateAttribute(node, "speaker", speaker.toString());
        if (speakerName != null && speakerName.length > 0)
            XMLHelper.CreateAttribute(node, "speakerName", speakerName);
        if (description != null && description.length > 0)
            XMLHelper.CreateAttribute(node, "description", description);
        if (sounds.length > 0)
            XMLHelper.CreateAttribute(node, "sounds", sounds.map(s -> s.toString()).join(";"));
        if (NamespaceID.IsValid(variant))
            XMLHelper.CreateAttribute(node, "variant", variant.toString());


        TalkHelper.CreateTalkScriptNodes(document, node, "onStart", startScripts, "语句开始脚本");

        var lines = text.split("\n");
        for (line in lines) {
            XMLHelper.CreateTextOrCDataNode(document, node, "text", line);
        }

        TalkHelper.CreateTalkScriptNodes(document, node, "onClick", clickScripts, "语句点击脚本");

        return node;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):TalkSentence {
        var speaker = XMLHelper.GetAttributeNamespaceID(node, "speaker", defaultNsp);
        var speakerName = XMLHelper.GetAttribute(node, "speakerName");
        var description = XMLHelper.GetAttribute(node, "description");
        var sounds = XMLHelper.GetAttributeNamespaceIDArray(node, "sounds", defaultNsp);
        var variant = XMLHelper.GetAttributeNamespaceID(node, "variant", defaultNsp);
        var text = "";
        var startScripts:Array<TalkScript> = null;
        var clickScripts:Array<TalkScript> = null;

        var children = node.ChildNodes;
        for (i in 0...children.Count) {
            var child = children.getAt(i);
            switch (child.Name) {
                case "text":
                    if (text == null || text.length == 0) {
                        text = child.InnerText;
                    } else {
                        text += '\n${child.InnerText}';
                    }
                case "onStart":
                    startScripts = TalkScript.FromArrayXmlNode(child);
                case "onClick":
                    clickScripts = TalkScript.FromArrayXmlNode(child);
                default:
            }
        }
        var sentence = new TalkSentence(text, sounds != null ? sounds : []);
        sentence.speaker = speaker;
        sentence.speakerName = speakerName;
        sentence.description = description;
        sentence.variant = variant;
        sentence.startScripts = startScripts;
        sentence.clickScripts = clickScripts;
        return sentence;
    }
    public function GetSpeakerName(main:MainManager):String {
        if (speakerName != null && speakerName.length > 0) {
            // PORT-NOTE: C# 有 GetCharacterName(string) 重载，Haxe 无重载，按 key 的那个重载改为 GetCharacterNameByKey。
            return main.ResourceManager.GetCharacterNameByKey(speakerName);
        } else {
            return main.ResourceManager.GetCharacterName(speaker);
        }

    }
}
