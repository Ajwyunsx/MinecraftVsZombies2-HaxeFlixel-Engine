// Ported from: Assets/Scripts/MVZ2/Metas/LoreTalkMeta.cs
package mvz2.metas;

import mvz2.saves.MVZ2SaveExt;
import mvz2logic.games.IGlobalSaveData;
import pvzengine.NamespaceID;
import system.xml.XmlNode;

using mvz2.saves.MVZ2SaveExt;

class LoreTalkMetaList {
    public function new(talks:Array<LoreTalkMeta>) {
        Talks = talks;
    }

    public var Talks:Array<LoreTalkMeta>;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):LoreTalkMetaList {
        if (node == null)
            return null;
        var metas:Array<LoreTalkMeta> = [];
        for (i in 0...node.ChildNodes.Count) {
            var child = node.ChildNodes.getAt(i);
            if (child.Name == "talk") {
                var meta = LoreTalkMeta.FromXmlNode(child, defaultNsp);
                if (meta != null)
                    metas.push(meta);
            }
        }
        return new LoreTalkMetaList(metas);
    }
    public function GetLoreTalks(save:IGlobalSaveData):Array<NamespaceID> {
        var results:Array<NamespaceID> = [];
        for (talk in Talks) {
            if (talk.Conditions != null && save.MeetsXMLConditions(talk.Conditions)) {
                results.push(talk.ID);
            }
        }
        return results;
    }
}
