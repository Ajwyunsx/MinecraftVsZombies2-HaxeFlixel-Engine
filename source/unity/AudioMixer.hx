package unity;

import unity.AudioMixer.MixerGraph;
import unity.Mathf.FloatRef;

/**
 * Minimal UnityEngine.Audio.AudioMixer shim.
 *
 * PORT-NOTE: Unity 的 AudioMixer 是「资源对象」（Assets/Mixers/Main.mixer），场景里 MusicManager 与
 * SoundManager 引用的都是同一个资源，所以 SetFloat("MusicVolume", ...) 与 SetFloat("SoundVolume", ...)
 * 改的是同一张总线路由表。移植层按 mixer 名把总线路由表放在静态表里：同名 AudioMixer 实例共享同一张图，
 * 未命名/其它名字的实例在「工程只定义了一张图」时也复用它（export_audio_manifest.py 从 Mixers/Main.mixer
 * 导出的唯一一张图，见 HaxePort/assets/audio_manifest.json 的 mixers 字段）。
 *
 * 总线的分层与暴露参数（全部来自 Main.mixer）：
 *   Master
 *   ├── Sound   (SoundVolume)
 *   └── Music   (MusicVolume)
 *       └── Fade (FadeVolume)
 *           ├── MainTrack (MainWeight)
 *           └── SubTrack  (SubWeight)
 */
class AudioMixer extends UnityObject {
    /** 工程唯一的 AudioMixer 资源是 Assets/Mixers/Main（address: Assets/Mixers/Main）。 */
    public static inline var MAIN_NAME:String = "Main";

    private static var graphs:Map<String, MixerGraph> = new Map();
    private static var _defaultGraph:MixerGraph = null;
    private static var _main:AudioMixer = null;
    private static var warnedNames:Map<String, Bool> = new Map();

    private var graph:MixerGraph;

    public function new(?name:String) {
        super();
        this.name = name != null ? name : MAIN_NAME;
        graph = getGraph(this.name);
    }

    /** 工程唯一的 mixer 实例（供 prefab 接线阶段在缺少序列化引用时兜底）。 */
    public static var main(get, never):AudioMixer;
    static function get_main():AudioMixer {
        if (_main == null)
            _main = new AudioMixer(MAIN_NAME);
        return _main;
    }

    /**
     * 按名称取总线路由图；没有专门定义过该名字时退回工程里唯一定义过的那张图。
     * Unity 侧一个 mixer 资源可以被多处引用，移植层的名字只是定位用的标签。
     */
    public static function getGraph(name:String):MixerGraph {
        if (name != null && graphs.exists(name))
            return graphs.get(name);
        if (_defaultGraph != null) {
            if (name != null && !warnedNames.exists(name)) {
                warnedNames.set(name, true);
                Debug.LogWarning('AudioMixer：没有名为「$name」的 Mixer，改用工程唯一的 Mixer「${_defaultGraph.name}」'
                    + '（见 assets/audio_manifest.json 的 mixers）。');
            }
            return _defaultGraph;
        }
        var created = new MixerGraph(name != null ? name : MAIN_NAME);
        graphs.set(created.name, created);
        if (_defaultGraph == null)
            _defaultGraph = created;
        return created;
    }

    /**
     * 按清单定义一条 Mixer 的总线图（由 mvz2.audios.AudioManifest 用 audio_manifest.json 调用）。
     * `defs` 里的每条记录形如 {name, parent, exposedParameter}；`exposed` 是「参数名 → 总线名」。
     */
    public static function defineGraph(mixerName:String, defs:Array<Dynamic>, exposed:Map<String, String>):MixerGraph {
        var name = mixerName != null ? mixerName : MAIN_NAME;
        var graph = new MixerGraph(name);
        if (defs != null) {
            // 先建全部总线（父子关系可能前向引用），再连父子。
            for (def in defs) {
                var groupName:String = Reflect.field(def, "name");
                if (groupName == null)
                    continue;
                graph.defineGroup(groupName, Reflect.field(def, "exposedParameter"));
            }
            for (def in defs) {
                var groupName:String = Reflect.field(def, "name");
                var parentName:String = Reflect.field(def, "parent");
                if (groupName == null || parentName == null)
                    continue;
                var group = graph.groups.get(groupName);
                var parent = graph.groups.get(parentName);
                if (group != null && parent != null)
                    parent.addChild(group);
            }
        }
        for (groupName in graph.groups.keys()) {
            var group = graph.groups.get(groupName);
            if (group.exposedParameter != null)
                graph.defineExposed(group.exposedParameter, group.name);
        }
        if (exposed != null) {
            for (param in exposed.keys())
                graph.defineExposed(param, exposed.get(param));
        }
        graph.refreshMasterGroup();
        graphs.set(name, graph);
        if (_defaultGraph == null)
            _defaultGraph = graph;
        return graph;
    }

    /** mixer 的暴露参数（AddFloat/SetFloat 用）。 */
    public function getGroup(groupName:String):AudioMixerGroup {
        return graph.groups.get(groupName);
    }

    // C#: public bool SetFloat(string name, float value)
    // PORT-NOTE: Unity 在参数不存在时返回 false 且不生效。移植层为保证音量设置不会静默失效
    // （清单缺失或 prefab 尚未接线时），按参数名补建一条挂到 Master 下的总线并告警。
    public function SetFloat(name:String, value:Float):Bool {
        if (name == null)
            return false;
        var group = graph.getExposedGroup(name);
        if (group == null) {
            group = graph.defineGroup(name, name);
            if (graph.masterGroup != null)
                graph.masterGroup.addChild(group);
            graph.defineExposed(name, name);
            Debug.LogWarning('AudioMixer.SetFloat：Mixer「${graph.name}」没有暴露参数「$name」，'
                + '已按同名总线处理（见 assets/audio_manifest.json 的 mixers）。');
        }
        graph.setParameterDb(name, value);
        return true;
    }
    public function GetFloat(name:String, outValue:FloatRef):Bool {
        if (name == null)
            return false;
        var group = graph.getExposedGroup(name);
        outValue.value = graph.getParameterDb(name);
        return group != null;
    }
    public function ClearFloat(name:String):Bool {
        if (name == null)
            return false;
        graph.clearParameter(name);
        return true;
    }
}


/**
 * 一条 Mixer 的总线路由表：总线树 + 暴露参数表。
 * PORT-NOTE: 与被替换前的 AudioMixer shim 不同，参数表按 mixer 共享（原实现是每个实例一份），
 * 因为 Unity 里 SoundManager/MusicManager 引用的是同一个 mixer 资源。
 */
class MixerGraph {
    public var name:String;
    public var groups:Map<String, AudioMixerGroup> = new Map();
    public var masterGroup:AudioMixerGroup;
    /** 暴露参数名 → 总线名。 */
    public var exposed:Map<String, String> = new Map();
    /** 暴露参数名 → 当前 dB 值（未设置过时按 0 dB，即 Unity 里 Mixer 的默认音量）。 */
    public var parameters:Map<String, Float> = new Map();

    public function new(name:String) {
        this.name = name;
    }

    public function defineGroup(groupName:String, exposedParameter:String):AudioMixerGroup {
        var group = groups.get(groupName);
        if (group == null) {
            group = new AudioMixerGroup(groupName);
            groups.set(groupName, group);
        }
        if (exposedParameter != null)
            group.exposedParameter = exposedParameter;
        return group;
    }

    /** 把没有父节点的总线记为 Master（Unity 的 Mixer 有且只有一条 Master 总线）。 */
    public function refreshMasterGroup():AudioMixerGroup {
        for (group in groups) {
            if (group.parent == null) {
                masterGroup = group;
                return group;
            }
        }
        return masterGroup;
    }

    public function defineExposed(parameter:String, groupName:String):Void {
        if (parameter == null || groupName == null)
            return;
        exposed.set(parameter, groupName);
        if (!parameters.exists(parameter))
            parameters.set(parameter, 0);
    }

    public function getExposedGroup(parameter:String):AudioMixerGroup {
        if (parameter == null)
            return null;
        var groupName = exposed.get(parameter);
        if (groupName == null) {
            var direct = groups.get(parameter);
            if (direct != null && direct.exposedParameter == parameter)
                return direct;
            return null;
        }
        return groups.get(groupName);
    }

    public function getParameterDb(parameter:String):Float {
        if (parameters.exists(parameter))
            return parameters.get(parameter);
        var group = getExposedGroup(parameter);
        return group != null ? group.volumeDb : 0;
    }

    public function setParameterDb(parameter:String, db:Float):Void {
        parameters.set(parameter, db);
        var group = getExposedGroup(parameter);
        if (group != null)
            group.volumeDb = db;
    }

    public function clearParameter(parameter:String):Void {
        parameters.remove(parameter);
        var group = getExposedGroup(parameter);
        if (group != null)
            group.volumeDb = 0;
    }
}
