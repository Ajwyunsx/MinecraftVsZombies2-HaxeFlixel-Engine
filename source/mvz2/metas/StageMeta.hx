// Ported from: Assets/Scripts/MVZ2/Metas/Stage/StageMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import mvz2logic.level.LevelCameraPosition;
import mvz2logic.level.StageTypes;
import pvzengine.Log;
import pvzengine.NamespaceID;
import pvzengine.PropertyKeyHelper;
import pvzengine.PropertyRegions;
import system.xml.XmlNode;
import tools.Ticks;
using mvz2.io.XMLHelper;  // EXTUSING
using pvzengine.PropertyKeyHelper;  // EXTUSING

class StageMeta {
    private function new(id:String, properties:Map<String, Dynamic>) {
        ID = id;
        Properties = properties;
    }

    public var ID(default, null):String;
    public var Name(default, null):String = "";
    public var DayNumber(default, null):Int;
    public var Type(default, null):String = StageTypes.TYPE_NORMAL;
    // [Obsolete]
    public var Unlocks(default, null):Array<NamespaceID>;
    public var UnlockConditions(default, null):XMLConditionList;
    public var StartEnergy(default, null):Float;

    public var MusicID(default, null):NamespaceID;

    public var NoStartTalkMusic(default, null):Bool;
    public var Talks(default, null):Array<StageMetaTalk>;

    public var ModelPreset(default, null):String = "default";

    public var ClearPickupModel(default, null):NamespaceID;
    public var ClearPickupContentID(default, null):NamespaceID;
    public var DropsTrophy(default, null):Bool;
    public var EndNote(default, null):NamespaceID;

    public var StartCameraPosition(default, null):LevelCameraPosition;
    public var StartTransition(default, null):String = "";

    public var TotalFlags(default, null):Int;
    public var SpawnPointsPower(default, null):Float;
    public var SpawnPointsMultiplier(default, null):Float;
    public var SpawnPointsAddition(default, null):Float;
    public var Spawns(default, null):Array<NamespaceID>;
    public var ConveyorPool(default, null):Array<ConveyorPoolEntry>;

    public var FirstWaveTime(default, null):Float;
    public var EndlessFirstWaveTime(default, null):Float;
    public var MaxWaveTime(default, null):Float;
    public var AdvanceWaveTime(default, null):Float;
    public var AdvanceHealthPercent(default, null):Float;

    public var NeedBlueprints(default, null):Bool;

    public var Properties(default, null):Map<String, Dynamic>;

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):StageMeta {
        var id = XMLHelper.GetAttribute(node, "id");
        if (id == null || id.length == 0) {
            Log.LogError("The ID of a StageMeta is invalid.");
            return null;
        }
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null) name = "";
        var type = XMLHelper.GetAttribute(node, "type");
        if (type == null) type = StageTypes.TYPE_NORMAL;
        var dayNumberAttr = XMLHelper.GetAttributeInt(node, "dayNumber");
        var dayNumber = dayNumberAttr != null ? dayNumberAttr : 0;
        var startEnergyAttr = XMLHelper.GetAttributeFloat(node, "startEnergy");
        var startEnergy = startEnergyAttr != null ? startEnergyAttr : 50.0;
        var musicID = XMLHelper.GetAttributeNamespaceID(node, "music", defaultNsp);
        var needBlueprintsAttr = XMLHelper.GetAttributeBool(node, "needBlueprints");
        var needBlueprints = needBlueprintsAttr != null ? needBlueprintsAttr : true;

        var unlockConditions = XMLHelper.GetUnlockConditionsOrObsoleteArray(node, "unlock", "unlock", defaultNsp);

        var modelNode = node["model"];
        var preset = modelNode != null ? XMLHelper.GetAttribute(modelNode, "preset") : null;
        if (preset == null) preset = "default";

        var talks:Array<StageMetaTalk> = [];
        var talksNode = node["talks"];
        var noStartTalkMusic = false;
        if (talksNode != null) {
            var noStartMusicAttr = XMLHelper.GetAttributeBool(talksNode, "noStartMusic");
            noStartTalkMusic = noStartMusicAttr != null ? noStartMusicAttr : false;
            for (i in 0...talksNode.ChildNodes.Count) {
                var child = talksNode.ChildNodes.getAt(i);
                if (child.Name == "talk") {
                    var meta = StageMetaTalk.FromXmlNode(child, defaultNsp);
                    if (meta != null)
                        talks.push(meta);
                }
            }
        }

        var clearNode = node["clear"];
        var clearPickupModel = clearNode != null ? XMLHelper.GetAttributeNamespaceID(clearNode, "pickupModel", defaultNsp) : null;
        var clearPickupContentID = clearNode != null ? XMLHelper.GetAttributeNamespaceID(clearNode, "pickupContentID", defaultNsp) : null;
        if (clearPickupContentID == null && clearNode != null) {
            clearPickupContentID = XMLHelper.GetAttributeNamespaceID(clearNode, "blueprint", defaultNsp);
        }
        var dropsTrophyAttr = clearNode != null ? XMLHelper.GetAttributeBool(clearNode, "trophy") : null;
        var dropsTrophy = dropsTrophyAttr != null ? dropsTrophyAttr : false;
        var endNote = clearNode != null ? XMLHelper.GetAttributeNamespaceID(clearNode, "note", defaultNsp) : null;

        var cameraNode = node["camera"];
        var cameraPositionStr = cameraNode != null ? XMLHelper.GetAttribute(cameraNode, "position") : null;
        if (cameraPositionStr == null) cameraPositionStr = "";
        var startCameraPosition = cameraPositionDict.exists(cameraPositionStr) ? cameraPositionDict.get(cameraPositionStr) : LevelCameraPosition.House;
        var transition = cameraNode != null ? XMLHelper.GetAttribute(cameraNode, "transition") : null;
        if (transition == null) transition = "";

        var conveyorNode = node["conveyor"];
        var conveyorPool:Array<ConveyorPoolEntry> = null;
        if (conveyorNode != null) {
            // PORT-NOTE: C# `new ConveyorPoolEntry[count]` → Array.resize 保持按下标占位。
            conveyorPool = [];
            conveyorPool.resize(conveyorNode.ChildNodes.Count);
            for (i in 0...conveyorPool.length) {
                var item = ConveyorPoolEntry.FromXmlNode(conveyorNode.ChildNodes.getAt(i), defaultNsp);
                if (item == null)
                    continue;
                conveyorPool[i] = item;
            }
        }

        var spawnNode = node["spawns"];
        var flagsAttr = spawnNode != null ? XMLHelper.GetAttributeInt(spawnNode, "flags") : null;
        var flags = flagsAttr != null ? flagsAttr : 1;
        var spawnPointsPowerAttr = spawnNode != null ? XMLHelper.GetAttributeFloat(spawnNode, "pointsPower") : null;
        var spawnPointsPower = spawnPointsPowerAttr != null ? spawnPointsPowerAttr : 1.0;
        var spawnPointsMultiplierAttr = spawnNode != null ? XMLHelper.GetAttributeFloat(spawnNode, "pointsMultiplier") : null;
        var spawnPointsMultiplier = spawnPointsMultiplierAttr != null ? spawnPointsMultiplierAttr : 1.0;
        var spawnPointsAdditionAttr = spawnNode != null ? XMLHelper.GetAttributeFloat(spawnNode, "pointsAddition") : null;
        var spawnPointsAddition = spawnPointsAdditionAttr != null ? spawnPointsAdditionAttr : 0.0;
        var spawns:Array<NamespaceID> = null;
        if (spawnNode != null) {
            // PORT-NOTE: C# `new NamespaceID[count]` → Array.resize 保持按下标占位。
            spawns = [];
            spawns.resize(spawnNode.ChildNodes.Count);
            for (i in 0...spawns.length) {
                var childNode = spawnNode.ChildNodes.getAt(i);
                var item = XMLHelper.GetAttributeNamespaceID(childNode, "id", defaultNsp);
                if (item == null)
                    continue;
                spawns[i] = item;
            }
        }

        var timeNode = node["time"];
        var firstWaveAttr = timeNode != null ? XMLHelper.GetAttributeFloat(timeNode, "firstWave") : null;
        var firstWaveTime = 0.0;
        if (firstWaveAttr != null) {
            firstWaveTime = firstWaveAttr;
        } else {
            var firstWaveTimeTicks = spawnNode != null ? XMLHelper.GetAttributeInt(spawnNode, "firstWaveTime") : null;
            firstWaveTime = Ticks.ToSeconds(firstWaveTimeTicks != null ? firstWaveTimeTicks : 540);
        }
        var endlessFirstWaveAttr = timeNode != null ? XMLHelper.GetAttributeFloat(timeNode, "endlessFirstWave") : null;
        var endlessFirstWaveTime = endlessFirstWaveAttr != null ? endlessFirstWaveAttr : 6.0;
        var maxWaveAttr = timeNode != null ? XMLHelper.GetAttributeFloat(timeNode, "waveMax") : null;
        var maxWaveTime = maxWaveAttr != null ? maxWaveAttr : 30.0;
        var advanceWaveAttr = timeNode != null ? XMLHelper.GetAttributeFloat(timeNode, "waveAdvance") : null;
        var advanceWaveTime = advanceWaveAttr != null ? advanceWaveAttr : 10.0;
        var advanceHealthAttr = timeNode != null ? XMLHelper.GetAttributeFloat(timeNode, "waveAdvanceHealthPercent") : null;
        var advanceHealthPercent = advanceHealthAttr != null ? advanceHealthAttr : 0.6;

        var propertiesNode = node["properties"];
        var props = XMLHelper.ToPropertyDictionary(propertiesNode, defaultNsp);
        var properties:Map<String, Dynamic> = new Map();
        for (propKey in props.keys()) {
            var fullName = PropertyKeyHelper.ParsePropertyFullName(propKey, defaultNsp, PropertyRegions.level);
            properties.set(fullName, props.get(propKey));
        }

        var meta = new StageMeta(id, properties);
        meta.Name = name;
        meta.DayNumber = dayNumber;
        meta.Type = type;
        meta.StartEnergy = startEnergy;
        meta.UnlockConditions = unlockConditions;
        meta.MusicID = musicID;

        meta.ModelPreset = preset;

        meta.NoStartTalkMusic = noStartTalkMusic;
        meta.Talks = talks;

        meta.ClearPickupModel = clearPickupModel;
        meta.ClearPickupContentID = clearPickupContentID;
        meta.DropsTrophy = dropsTrophy;
        meta.EndNote = endNote;

        meta.StartCameraPosition = startCameraPosition;
        meta.StartTransition = transition;

        meta.ConveyorPool = conveyorPool;

        meta.TotalFlags = flags;
        meta.Spawns = spawns;

        meta.FirstWaveTime = firstWaveTime;
        meta.EndlessFirstWaveTime = endlessFirstWaveTime;
        meta.MaxWaveTime = maxWaveTime;
        meta.AdvanceWaveTime = advanceWaveTime;
        meta.AdvanceHealthPercent = advanceHealthPercent;

        meta.SpawnPointsPower = spawnPointsPower;
        meta.SpawnPointsMultiplier = spawnPointsMultiplier;
        meta.SpawnPointsAddition = spawnPointsAddition;

        meta.NeedBlueprints = needBlueprints;
        return meta;
    }
    public static var cameraPositionDict:Map<String, LevelCameraPosition> = [
        "house" => LevelCameraPosition.House,
        "lawn" => LevelCameraPosition.Lawn,
        "choose" => LevelCameraPosition.Choose,
    ];
}
