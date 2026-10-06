// Ported from: Assets/Scripts/MVZ2/Talks/Data/TalkSection.cs
package mvz2.talkdata;

import mvz2.io.XMLHelper;
import system.xml.XmlDocument;
import system.xml.XmlNode;
import mvz2.talk.TalkHelper; // PORT-NOTE: CreateTalkScriptNodes 是 TalkHelper 的扩展方法
using mvz2.io.XMLHelper;  // EXTUSING
using mvz2.talk.TalkHelper;  // EXTUSING

class TalkSection {
    public var archiveText:String = "";
    public var canAutoSkip:Bool;
    public var notUseSkipScriptsForAutoSkip:Bool;
    public var startScripts:Array<TalkScript>;
    public var autoSkipScripts:Array<TalkScript>;
    public var skipScripts:Array<TalkScript>;
    public var characters:Array<TalkCharacter>;
    public var sentences:Array<TalkSentence>;

    public function new(characters:Array<TalkCharacter>, sentences:Array<TalkSentence>) {
        this.characters = characters;
        this.sentences = sentences;
    }

    public function ToXmlNode(document:XmlDocument):XmlNode {
        var node = document.CreateElement("section");
        if (!canAutoSkip) {
            XMLHelper.CreateAttribute(node, "canAutoSkip", Std.string(false));
        }

        TalkHelper.CreateTalkScriptNodes(document, node, "onStart", startScripts, "分段开始脚本");
        TalkHelper.CreateTalkScriptNodes(document, node, "onAutoSkip", autoSkipScripts, "分段自动跳过脚本");
        var skipNode = TalkHelper.CreateTalkScriptNodes(document, node, "onSkip", skipScripts, "分段跳过脚本");
        if (skipNode != null && notUseSkipScriptsForAutoSkip) {
            XMLHelper.CreateAttribute(skipNode, "notForAutoSkip", Std.string(true));
        }

        if (archiveText != null && archiveText.length > 0) {
            XMLHelper.AddComment(document, node, "对话档案文本");
            XMLHelper.CreateTextOrCDataNode(document, node, "text", archiveText);
        }

        XMLHelper.AddComment(document, node, "角色列表");
        var charactersNode = document.CreateElement("characters");
        for (character in characters) {
            var child = character.ToXmlNode(document);
            charactersNode.AppendChild(child);
        }
        node.AppendChild(charactersNode);

        XMLHelper.AddComment(document, node, "语句列表");
        var sentencesNode = document.CreateElement("sentences");
        for (i in 0...sentences.length) {
            var sentence = sentences[i];
            XMLHelper.AddComment(document, sentencesNode, '语句${i}');
            var child = sentence.ToXmlNode(document);
            sentencesNode.AppendChild(child);
        }
        node.AppendChild(sentencesNode);

        return node;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):TalkSection {
        var canAutoSkipAttr = XMLHelper.GetAttributeBool(node, "canAutoSkip");
        var canAutoSkip = canAutoSkipAttr != null ? canAutoSkipAttr : true;

        var startScriptsNode = node.GetChildNode("onStart");
        var startScripts:Array<TalkScript>;
        if (startScriptsNode != null) {
            startScripts = TalkScript.FromArrayXmlNode(startScriptsNode);
        } else {
            startScripts = TalkScript.ParseArray(XMLHelper.GetAttribute(node, "onStart"));
        }

        var autoSkipScriptsNode = node.GetChildNode("onAutoSkip");
        var autoSkipScripts:Array<TalkScript>;
        if (autoSkipScriptsNode != null) {
            autoSkipScripts = TalkScript.FromArrayXmlNode(autoSkipScriptsNode);
        } else {
            autoSkipScripts = TalkScript.ParseArray(XMLHelper.GetAttribute(node, "onAutoSkip"));
        }


        var notUseSkipScriptsForAutoSkip = false;
        var skipScriptsNode = node.GetChildNode("onSkip");
        var skipScripts:Array<TalkScript>;
        if (skipScriptsNode != null) {
            skipScripts = TalkScript.FromArrayXmlNode(skipScriptsNode);
            var notForAutoSkip = XMLHelper.GetAttributeBool(skipScriptsNode, "notForAutoSkip");
            if (notForAutoSkip != null) notUseSkipScriptsForAutoSkip = notForAutoSkip;
        } else {
            skipScripts = TalkScript.ParseArray(XMLHelper.GetAttribute(node, "onSkip"));
        }

        var textNode = node.GetChildNode("text");
        var archiveText = "";
        if (textNode != null) {
            archiveText = textNode.InnerText;
        }

        var charactersNode = node.GetChildNode("characters");
        var characters:Array<TalkCharacter> = [];
        if (charactersNode != null) {
            var characterChildren = charactersNode.ChildNodes;
            for (i in 0...characterChildren.Count) {
                var child = characterChildren.getAt(i);
                var meta = TalkCharacter.FromXmlNode(child, defaultNsp);
                if (meta != null)
                    characters.push(meta);
            }
        }
        var sentencesNode = node.GetChildNode("sentences");
        var sentences:Array<TalkSentence> = [];
        if (sentencesNode != null) {
            var sentenceChildren = sentencesNode.ChildNodes;
            for (i in 0...sentenceChildren.Count) {
                var child = sentenceChildren.getAt(i);
                var meta = TalkSentence.FromXmlNode(child, defaultNsp);
                if (meta != null)
                    sentences.push(meta);
            }
        }
        var section = new TalkSection(characters, sentences);
        section.startScripts = startScripts;
        section.autoSkipScripts = autoSkipScripts;
        section.skipScripts = skipScripts;
        section.canAutoSkip = canAutoSkip;
        section.archiveText = archiveText;
        section.notUseSkipScriptsForAutoSkip = notUseSkipScriptsForAutoSkip;
        return section;
    }
}
