// Ported from: Assets/Scripts/MVZ2/Metas/MetaXMLParser.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2.modding.ModResource;
import pvzengine.collisions.ColliderConstructor;
import system.xml.XmlDocument;
import system.xml.XmlNode;
import unity.Vector3;
using mvz2.io.XMLHelper;  // EXTUSING

// PORT-NOTE: C# 扩展方法 `this ModResource resource` / `this XmlNode node`
// 按 PORTING.md 改为首参数为目标的静态方法（类保持全静态成员）。
class MetaXMLParser {
    private function new() {}

    public static function LoadMetaList(resource:ModResource, metaPath:String, document:XmlDocument, defaultNsp:String):Void {
        switch (metaPath) {
            case "talkcharacters":
                resource.TalkCharacterMetaList = TalkCharacterMetaList.FromXmlNode(document["characters"], defaultNsp);
            case "sounds":
                resource.SoundMetaList = SoundMetaList.FromXmlNode(document["sounds"], defaultNsp);
            case "models":
                resource.ModelMetaList = ModelMetaList.FromXmlNode(document["models"], defaultNsp);
            case "fragments":
                resource.FragmentMetaList = FragmentMetaList.FromXmlNode(document["fragments"]);
            case "difficulties":
                resource.DifficultyMetaList = DifficultyMetaList.FromXmlNode(document["difficulties"], defaultNsp);
            case "armors":
                resource.ArmorMetaList = ArmorMetaList.FromXmlNode(document["armors"], defaultNsp);
            case "entities":
                resource.EntityMetaList = EntityMetaList.FromXmlNode(resource.Namespace, document["entities"], defaultNsp);
            case "shapes":
                resource.ShapeMetaList = ShapeMetaList.FromXmlNode(document["shapes"], defaultNsp);
            case "artifacts":
                resource.ArtifactMetaList = ArtifactMetaList.FromXmlNode(document["artifacts"], defaultNsp);
            case "almanac":
                resource.AlmanacMetaList = AlmanacMetaList.FromXmlNode(document["almanac"], defaultNsp);
            case "notes":
                resource.NoteMetaList = NoteMetaList.FromXmlNode(document["notes"], defaultNsp);
            case "stages":
                resource.StageMetaList = StageMetaList.FromXmlNode(document["stages"], defaultNsp);
            case "maps":
                resource.MapMetaList = MapMetaList.FromXmlNode(document["maps"], defaultNsp);
            case "commands":
                resource.CommandMetaList = CommandMetaList.FromXmlNode(document["commands"], defaultNsp);
            case "areas":
                resource.AreaMetaList = AreaMetaList.FromXmlNode(document["areas"], defaultNsp);
            case "stats":
                resource.StatMetaList = StatMetaList.FromXmlNode(document["stats"], defaultNsp);
            case "achievements":
                resource.AchievementMetaList = AchievementMetaList.FromXmlNode(document["achievements"], defaultNsp);
            case "store":
                resource.StoreMetaList = StoreMetaList.FromXmlNode(document["store"], defaultNsp);
            case "archive":
                resource.ArchiveMetaList = ArchiveMetaList.FromXmlNode(document["archive"], defaultNsp);
            case "mainmenuviews":
                resource.MainmenuViewMetaList = MainmenuViewMetaList.FromXmlNode(document["views"], defaultNsp);
            case "musics":
                resource.MusicMetaList = MusicMetaList.FromXmlNode(document["musics"], defaultNsp);
            case "progressbars":
                resource.ProgressBarMetaList = ProgressBarMetaList.FromXmlNode(document["bars"], defaultNsp);
            case "blueprints":
                resource.BlueprintMetaList = BlueprintMetaList.FromXmlNode(resource.Namespace, document["blueprints"], defaultNsp);
            case "spawns":
                resource.SpawnMetaList = SpawnMetaList.FromXmlNode(document["spawns"], defaultNsp);
            case "chaptertransitions":
                resource.ChapterTransitionMetaList = ChapterTransitionMetaList.FromXmlNode(document["transitions"], defaultNsp);
            case "grids":
                resource.GridMetaList = GridMetaList.FromXmlNode(document["grids"], defaultNsp);
            case "credits":
                resource.CreditsMetaList = CreditMetaList.FromXmlNode(document["credits"], defaultNsp);
            case "arcade":
                resource.ArcadeMetaList = ArcadeMetaList.FromXmlNode(document["arcade"], defaultNsp);
            case "buffs":
                resource.BuffMetaList = BuffMetaList.FromXmlNode(document["buffs"], defaultNsp);
            case "unlocks":
                resource.UnlockMetaList = UnlockMetaList.FromXmlNode(document["unlocks"], defaultNsp);
            case "options":
                resource.OptionMetaList = OptionMetaList.FromXmlNode(document["options"], defaultNsp);
            default:
        }
    }

    public static function LoadColliderConstructor(node:XmlNode):ColliderConstructor {
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null)
            name = "";
        var sizeNode = node["size"];
        var size = Vector3.zero;
        if (sizeNode != null) {
            var sx = XMLHelper.GetAttributeFloat(sizeNode, "x");
            var sy = XMLHelper.GetAttributeFloat(sizeNode, "y");
            var sz = XMLHelper.GetAttributeFloat(sizeNode, "z");
            size = new Vector3(sx != null ? sx : 0, sy != null ? sy : 0, sz != null ? sz : 0);
        }
        var offsetNode = node["offset"];
        var offset = Vector3.zero;
        if (offsetNode != null) {
            var ox = XMLHelper.GetAttributeFloat(offsetNode, "x");
            var oy = XMLHelper.GetAttributeFloat(offsetNode, "y");
            var oz = XMLHelper.GetAttributeFloat(offsetNode, "z");
            offset = new Vector3(ox != null ? ox : 0, oy != null ? oy : 0, oz != null ? oz : 0);
        }
        var pivotNode = node["pivot"];
        var pivot = Vector3.one * 0.5;
        if (pivotNode != null) {
            var px = XMLHelper.GetAttributeFloat(pivotNode, "x");
            var py = XMLHelper.GetAttributeFloat(pivotNode, "y");
            var pz = XMLHelper.GetAttributeFloat(pivotNode, "z");
            pivot = new Vector3(px != null ? px : 0.5, py != null ? py : 0.5, pz != null ? pz : 0.5);
        }
        // PORT-NOTE: C# 对象初始化器 `new ColliderConstructor() { ... }` → 逐字段赋值。
        // TODO-PORT: pvzengine.collisions.ColliderConstructor 的 shim 尚未编写，此处假定它有无参构造
        // 且 name/size/offset/pivot 为可写字段；待 shim 落地后需按实际构造函数签名调整。
        var result = new ColliderConstructor();
        result.name = name;
        result.size = size;
        result.offset = offset;
        result.pivot = pivot;
        return result;
    }
}
