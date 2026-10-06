// Ported from: Assets/Scripts/MVZ2/Talks/Data/TalkMeta.cs
package mvz2.talkdata;

import mvz2.io.XMLHelper;
import system.xml.XmlDocument;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class TalkMeta {
    public var order:Int;
    public var groups:Array<TalkGroup> = [];
    public function new() {}
    public function ToXmlDocument():XmlDocument {
        // PORT-NOTE: shim 的 XmlDocument 为 abstract，用 XmlDocument.create() 工厂创建。
        var xmlDoc = XmlDocument.create();
        xmlDoc.AppendChild(ToXmlNode(xmlDoc));
        return xmlDoc;
    }
    public function ToXmlNode(document:XmlDocument):XmlNode {
        var node = document.CreateElement("talks");
        XMLHelper.CreateAttribute(node, "order", Std.string(order));
        for (group in groups) {
            XMLHelper.AddComment(document, node, group.archive != null ? group.archive.name : null);

            var child = group.ToXmlNode(document);
            node.AppendChild(child);
        }
        return node;
    }
    public static function FromXmlDocument(document:XmlDocument, defaultNsp:String):TalkMeta {
        return TalkMeta.FromXmlNode(document.GetChildNode("talks"), defaultNsp);
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String):TalkMeta {
        var meta = new TalkMeta();
        var children = node.ChildNodes;
        var orderAttr = XMLHelper.GetAttributeInt(node, "order");
        var order = orderAttr != null ? orderAttr : 0;
        meta.order = order;
        for (i in 0...children.Count) {
            var child = children.getAt(i);
            var group = TalkGroup.FromXmlNode(child, defaultNsp, order, i);
            if (group != null)
                meta.groups.push(group);
        }
        return meta;
    }
}
