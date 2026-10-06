// Ported from: Assets/Scripts/MVZ2/Talks/Data/TalkGroup.cs
package mvz2.talkdata;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlDocument;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class TalkGroup {
    public var id:String;
    public var documentOrder:Int;
    public var groupOrder:Int;
    public var tags:Array<NamespaceID>;

    public var archive:TalkGroupArchiveInfo;
    public var sections:Array<TalkSection>;

    public function new(id:String, tags:Array<NamespaceID>, sections:Array<TalkSection>) {
        this.id = id;
        this.tags = tags;
        this.sections = sections;
    }

    public function ToXmlNode(document:XmlDocument):XmlNode {
        var node = document.CreateElement("group");
        XMLHelper.CreateAttribute(node, "id", id);
        if (tags != null)
            XMLHelper.CreateAttribute(node, "tags", tags.map(t -> t.toString()).join(";"));
        if (archive != null) {
            var archiveNode = archive.ToXmlNode(document);
            node.AppendChild(archiveNode);
            for (section in sections) {
                XMLHelper.AddComment(document, node, section.archiveText);

                var child = section.ToXmlNode(document);
                node.AppendChild(child);
            }
        }
        return node;
    }
    public static function FromXmlNode(node:XmlNode, defaultNsp:String, fileOrder:Int, groupOrder:Int):TalkGroup {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a TalkGroup is invalid.');
            return null;
        }
        var tags = XMLHelper.GetAttributeNamespaceIDArray(node, "tags", defaultNsp);
        if (tags == null) tags = [];

        var children = node.ChildNodes;


        var archive:TalkGroupArchiveInfo = null;
        var sections:Array<TalkSection> = [];
        for (i in 0...children.Count) {
            var child = children.getAt(i);
            switch (child.Name) {
                case "section":
                    sections.push(TalkSection.FromXmlNode(child, defaultNsp));
                case "archive":
                    archive = TalkGroupArchiveInfo.FromXmlNode(child, defaultNsp);
                default:
            }
        }
        if (archive == null) {
            archive = new TalkGroupArchiveInfo();
        }
        var group = new TalkGroup(id, tags.copy(), sections.copy());
        group.groupOrder = groupOrder;
        group.documentOrder = fileOrder;
        group.archive = archive;
        return group;
    }
}
