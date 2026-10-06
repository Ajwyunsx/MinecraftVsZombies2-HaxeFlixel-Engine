// Ported from: Assets/Scripts/MVZ2/Metas/MusicMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import pvzengine.NamespaceID;
import system.xml.XmlNode;
using mvz2.io.XMLHelper;  // EXTUSING

class MusicMeta {
    private function new(iD:String) {
        ID = iD;
    }

    public var ID(default, null):String;
    public var Name(default, null):String = "";
    public var MainTrack(default, null):NamespaceID;
    public var SubTrack(default, null):NamespaceID;
    public var UnlockConditions(default, null):XMLConditionList;
    public var Source(default, null):String = "";
    public var Origin(default, null):String = "";
    public var Author(default, null):String = "";
    public var Description(default, null):String = "";

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):MusicMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError('The id of a MusicMeta is invalid.');
            return null;
        }
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";

        var unlockConditions = XMLHelper.GetUnlockConditionsOrObsolete(node, "unlock", "unlock", defaultNsp);

        var mainTrack:NamespaceID = null;
        var subTrack:NamespaceID = null;
        var trackNode = node["track"];
        if (trackNode != null) {
            mainTrack = XMLHelper.GetAttributeNamespaceID(trackNode, "main", defaultNsp);
            subTrack = XMLHelper.GetAttributeNamespaceID(trackNode, "sub", defaultNsp);
        }
        var sourceNode = node["source"];
        var source = sourceNode != null ? sourceNode.InnerText : "";
        var originNode = node["origin"];
        var origin = originNode != null ? originNode.InnerText : "";
        var authorNode = node["author"];
        var author = authorNode != null ? authorNode.InnerText : "";
        var descriptionNode = node["description"];
        var description = "";
        if (descriptionNode != null) {
            description = XMLHelper.ConcatNodeParagraphs(descriptionNode);
        }
        var meta = new MusicMeta(id);
        meta.Name = name;
        meta.MainTrack = mainTrack;
        meta.SubTrack = subTrack;
        meta.UnlockConditions = unlockConditions;
        meta.Source = source;
        meta.Origin = origin;
        meta.Author = author;
        meta.Description = description;
        return meta;
    }
}
