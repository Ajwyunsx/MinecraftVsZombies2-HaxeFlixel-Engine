// Ported from: Assets/Scripts/MVZ2/Metas/Entity/EntityMetaList.cs
package mvz2.metas;

import system.xml.XmlNode;

class EntityMetaList {
    public var counters:Array<EntityCounterMeta>;
    public var metas:Array<EntityMeta>;

    public function new(counters:Array<EntityCounterMeta>, metas:Array<EntityMeta>) {
        this.counters = counters;
        this.metas = metas;
    }

    public static function FromXmlNode(nsp:String, node:XmlNode, defaultNsp:String):EntityMetaList {
        var countersNode = node.GetChildNode("counters");
        var counters:Array<EntityCounterMeta> = [];
        if (countersNode != null) {
            for (i in 0...countersNode.ChildNodes.Count) {
                var meta = EntityCounterMeta.FromXmlNode(countersNode.ChildNodes.getAt(i), defaultNsp);
                if (meta != null)
                    counters.push(meta);
            }
        }

        var templatesNode = node.GetChildNode("templates");
        var metaTemplates = EntityMetaTemplate.LoadChildrenTemplates(templatesNode, defaultNsp);

        var entriesNode = node.GetChildNode("entries");
        var entries:Array<EntityMeta> = [];
        if (entriesNode != null) {
            for (i in 0...entriesNode.ChildNodes.Count) {
                var meta = EntityMeta.FromXmlNode(nsp, entriesNode.ChildNodes.getAt(i), defaultNsp, metaTemplates, i);
                if (meta == null)
                    continue;
                entries.push(meta);
            }
        }
        return new EntityMetaList(counters, entries);
    }
}
