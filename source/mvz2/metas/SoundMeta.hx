// Ported from: Assets/Scripts/MVZ2/Metas/SoundMeta.cs
package mvz2.metas;

import mvz2.io.XMLHelper;
import pvzengine.Log;
import system.xml.XmlNode;
import unity.Random;
using mvz2.io.XMLHelper;  // EXTUSING

class SoundMeta {
    public var name:String;
    public var samples:Array<AudioSample>;
    public var priority:Int;
    public var maxCount:Int;
    public var loopPitchStart:Float;
    public var loopPitchEnd:Float;
    public var loopVolume:Float;
    public var loopFadeInSpeed:Float;
    public var loopFadeOutSpeed:Float;

    private function new(name:String, samples:Array<AudioSample>) {
        this.name = name;
        this.samples = samples;
    }

    public static function FromXmlNode(node:XmlNode, defaultNsp:String):SoundMeta {
        var name = XMLHelper.GetAttribute(node, "name");
        if (name == null || name.length == 0) {
            Log.LogError('The name of a SoundMeta is invalid.');
            return null;
        }
        var priorityAttr = XMLHelper.GetAttributeInt(node, "priority");
        var priority = priorityAttr != null ? priorityAttr : 128;
        var maxCountAttr = XMLHelper.GetAttributeInt(node, "maxCount");
        var maxCount = maxCountAttr != null ? maxCountAttr : 2;
        var loopVolumeAttr = XMLHelper.GetAttributeFloat(node, "loopVolume");
        var loopVolume = loopVolumeAttr != null ? loopVolumeAttr : 1;
        var loopPitchStartAttr = XMLHelper.GetAttributeFloat(node, "loopPitchStart");
        var loopPitchStart = loopPitchStartAttr != null ? loopPitchStartAttr : 1;
        var loopPitchEndAttr = XMLHelper.GetAttributeFloat(node, "loopPitchEnd");
        var loopPitchEnd = loopPitchEndAttr != null ? loopPitchEndAttr : 1;
        var loopFadeInSpeedAttr = XMLHelper.GetAttributeFloat(node, "loopFadeInSpeed");
        var loopFadeInSpeed = loopFadeInSpeedAttr != null ? loopFadeInSpeedAttr : 1;
        var loopFadeOutSpeedAttr = XMLHelper.GetAttributeFloat(node, "loopFadeOutSpeed");
        var loopFadeOutSpeed = loopFadeOutSpeedAttr != null ? loopFadeOutSpeedAttr : 1;
        var samples:Array<AudioSample> = [];
        for (i in 0...node.ChildNodes.Count) {
            var sample = AudioSample.FromXmlNode(node.ChildNodes.getAt(i), defaultNsp);
            if (sample != null)
                samples.push(sample);
        }
        var meta = new SoundMeta(name, samples);
        meta.priority = priority;
        meta.maxCount = maxCount;
        meta.loopVolume = loopVolume;
        meta.loopPitchStart = loopPitchStart;
        meta.loopPitchEnd = loopPitchEnd;
        meta.loopFadeInSpeed = loopFadeInSpeed;
        meta.loopFadeOutSpeed = loopFadeOutSpeed;
        return meta;
    }
    public function GetRandomSample():AudioSample {
        // PORT-NOTE: C# Random.Range(int,int) 返回 int；移植层用 RangeInt 对应整数重载。
        return samples[Random.RangeInt(0, samples.length)];
    }
}
