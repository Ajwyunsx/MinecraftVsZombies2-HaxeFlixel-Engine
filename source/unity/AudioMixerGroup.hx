// Ported from: UnityEngine.Audio.AudioMixerGroup (minimal shim)
package unity;

import flixel.sound.FlxSoundGroup;

/**
 * Unity 的 AudioMixerGroup 是 AudioMixer 里的一条总线，AudioSource.outputAudioMixerGroup 决定声音走哪条总线，
 * 声音的最终增益 = 自身总线与所有祖先总线音量的乘积（本工程：Master → Music → Fade → MainTrack/SubTrack）。
 *
 * PORT-NOTE: 移植层没有音频 DSP 图，用 flixel 的 FlxSoundGroup 承载实际增益：一条总线一个 FlxSoundGroup，
 * 它的 volume 事先乘上了全部祖先的增益；音源播放时把 FlxSound 挂到这条组上，于是改动总线音量会立刻作用于
 * 正在播放的声音（与 Unity 一致）。总线音量按 dB 保存（Unity 的 AudioMixer.SetFloat 语义，
 * AudioHelper.PercentageToDbA 的返回值），换算成线性增益后交给 flixel。
 */
class AudioMixerGroup extends UnityObject {
    /** Unity 的 AudioMixer 音量范围是 [-80, 20] dB（见 Mixers/Main.mixer 的 m_SuspendThreshold: -80）。 */
    public static inline var MIN_DB:Float = -80;
    public static inline var MAX_DB:Float = 20;

    public var parent:AudioMixerGroup;
    public var children:Array<AudioMixerGroup> = [];
    /** 该总线在 Mixer 里暴露的参数名（SoundVolume / MusicVolume / ...），未暴露时为 null。 */
    public var exposedParameter:String;
    /** 实际承载增益的 flixel 声音组。 */
    public var group:FlxSoundGroup;
    public var volumeDb(default, set):Float = 0;

    public function new(?name:String) {
        super();
        this.name = name != null ? name : "Group";
        group = new FlxSoundGroup(1);
    }

    function set_volumeDb(value:Float):Float {
        volumeDb = clampDb(value);
        refresh();
        return volumeDb;
    }

    /** 自身与全部祖先的线性增益乘积（即声音挂在这条总线上的实际增益）。 */
    public function getLinearVolume():Float {
        var linear = dbToLinear(volumeDb);
        var g = parent;
        while (g != null) {
            linear *= dbToLinear(g.volumeDb);
            g = g.parent;
        }
        return linear;
    }

    /** 把这条总线及其子树的增益写进 flixel 的声音组。 */
    public function refresh():Void {
        group.volume = getLinearVolume();
        for (c in children)
            c.refresh();
    }

    public function addChild(child:AudioMixerGroup):Void {
        if (child == null || child == this || child.parent == this)
            return;
        if (child.parent != null)
            child.parent.children.remove(child);
        child.parent = this;
        children.push(child);
        child.refresh();
    }

    /** dB → 线性增益（Unity 的 dB 到音量倍数的换算：10^(dB/20)）。 */
    public static function dbToLinear(db:Float):Float {
        if (Math.isNaN(db))
            return 1;
        return Math.pow(10, db / 20);
    }

    public static function clampDb(db:Float):Float {
        if (Math.isNaN(db))
            return 0;
        if (db < MIN_DB) return MIN_DB;
        if (db > MAX_DB) return MAX_DB;
        return db;
    }
}
