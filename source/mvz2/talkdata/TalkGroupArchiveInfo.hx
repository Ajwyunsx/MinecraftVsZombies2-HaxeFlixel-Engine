// Ported from: Assets/Scripts/MVZ2/Talks/Data/TalkGroupArchiveInfo.cs
package mvz2.talkdata;

import mvz2.io.XMLHelper;
import mvz2.metas.XMLConditionList;
import mvz2logic.resources.SpriteReference;
import pvzengine.NamespaceID;
import system.xml.XmlDocument;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class TalkGroupArchiveInfo {
    public var name:String = "";
    public var background:SpriteReference;
    public var unlockConditions:XMLConditionList;
    public var music:NamespaceID;
    public function new() {}
    public function ToXmlNode(document:XmlDocument):XmlNode {
        var node = document.CreateElement("archive");
        XMLHelper.CreateAttribute(node, "name", name);
        if (SpriteReference.IsValid(background))
            XMLHelper.CreateAttribute(node, "background", background.toString());
        if (NamespaceID.IsValid(music))
            XMLHelper.CreateAttribute(node, "music", music.toString());
        if (unlockConditions != null) {
            var unlockNode = unlockConditions.ToXmlNode("unlock", document);
            node.AppendChild(unlockNode);
        }
        return node;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):TalkGroupArchiveInfo {
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var background = XMLHelper.GetAttributeSpriteReference(node, "background", defaultNsp);
        var music = XMLHelper.GetAttributeNamespaceID(node, "music", defaultNsp);

        var unlockConditions = XMLHelper.GetUnlockConditionsOrObsolete(node, "unlock", "unlock", defaultNsp);
        var info = new TalkGroupArchiveInfo();
        info.name = name;
        info.background = background;
        info.unlockConditions = unlockConditions;
        info.music = music;
        return info;
    }
}
