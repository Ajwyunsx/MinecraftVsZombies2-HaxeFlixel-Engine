// Ported from: 音频管线（Assets/AddressableAssetsData/AssetGroups + Assets/**/*.meta + Assets/Mixers/Main.mixer
// + Assets/Prefabs/Init/MainManager.prefab 的音频部分）
package mvz2.audios;

import haxe.Json;
import unity.AudioClip;
import unity.AudioMixer;
import unity.AudioSource;
import unity.Debug;
import unity.addressableassets.Addressables;
import unity.addressableassets.Addressables.AsyncOperationHandle;
import unity.addressableassets.ResourceManifest;

/**
 * 音频资源管线：把 HaxePort/assets/audio_manifest.json（由
 * HaxePort/tools_build/export_audio_manifest.py 从 Unity 的 Addressables 组、.meta 导入设置、
 * 音频文件头、Mixers/Main.mixer 与 MainManager.prefab 导出的清单）接入运行期。
 *
 * 接入后按地址取 FlxSound 的链路是：
 *   ResourceManager.GetSoundClip/GetMusicClip(NamespaceID)
 *     → ModResource.Sounds/Musics（由 ResourceManager 按 "Init"/"Main" + "Sound"/"Music" 标签加载）
 *     → locator.Locate(label, AudioClip)（unity.addressableassets.ManifestResourceLocator）
 *     → Addressables.LoadAssetAsync(address)（先查注册表，命中 AudioManifest 登记的 AudioClip）
 *     → unity.AudioClip.newSound()（播放时由 lime 解码一次）
 *     → unity.AudioSource.Play()（走 AudioMixerGroup 总线）
 *
 * PORT-NOTE: 这里之所以抢先 Addressables.RegisterAsset 登记 AudioClip，是因为
 * unity.addressableassets.ResourceManifest 的默认音频加载路径会把**整个音频文件解码到内存**
 * （工程音频共 727MB，其中 44 首音乐占绝大部分），对应 Unity 的 Streaming 加载方式不成立。
 * 登记后的 AudioClip 只带清单里的时长/采样率/文件路径，解码推迟到真正播放时按需进行
 * （lime 会按资源 id 缓存解码结果）。若 audio_manifest.json 缺失，本类整体退化为
 * ResourceManifest 的默认解码路径（播放仍然可用，只是启动时一次性解码）。
 * PORT-NOTE: clips[].loadType 已导出（482 个音效是 DecompressOnLoad、44 首音乐是 Streaming），
 * 但移植层不区分加载方式，一律按需解码（等价于 Unity 的 Streaming 行为）；
 * 若首播卡顿需要优化，可预解码 loadType=0 的音效（合计约 67MB）。
 */
class AudioManifest {
    /** 音频清单文件名（位于 HaxePort/assets 下，随 Project.xml 的 <assets path="assets"/> 一起分发）。 */
    public static inline var MANIFEST_FILE:String = "audio_manifest.json";

    public static var loaded(default, null):Bool = false;
    public static var clipCount(default, null):Int = 0;
    /** 清单缺失/解析失败时置位，此时回退到 ResourceManifest 的解码路径。 */
    public static var failed(default, null):Bool = false;

    private static var byAddress:Map<String, AudioClip> = new Map();
    private static var templates:Array<Dynamic> = [];
    private static var mixerName:String = null;

    /**
     * 在资源目录初始化之前接入音频管线（调用点：mvz2.modding.ModManager.LoadModInfos，
     * 对应 C# 里 `await Addressables.InitializeAsync()` 取回 catalog 之后即可按地址取资源）。
     * PORT-NOTE: 兜底路径——即使这个调用点被改动，mvz2.audios.MusicManager.Awake 里的
     * applyTemplate 也会触发 ensureLoaded()（场景 Awake 早于 ResourceManager 的 Main 资源加载）。
     */
    public static function attach():Void {
        ensureLoaded();
    }

    public static function ensureLoaded():Void {
        if (loaded || failed)
            return;
        var data:Dynamic = null;
        try {
            data = loadJson();
        } catch (e:Dynamic) {
            Debug.LogWarning('音频清单解析失败（$MANIFEST_FILE）：$e');
        }
        if (data == null) {
            failed = true;
            Debug.LogWarning('未找到音频清单 $MANIFEST_FILE，音频回退到 ResourceManifest 的解码路径'
                + '（启动时会一次性解码全部音频）。');
            return;
        }
        ingestMixers(Reflect.field(data, "mixers"));
        ingestClips(Reflect.field(data, "clips"));
        ingestTemplates(Reflect.field(data, "audioSourceTemplates"));
        loaded = true;
        Debug.Log('音频清单已加载：$MANIFEST_FILE（clips=$clipCount，mixer=${mixerName != null ? mixerName : "无"}）');
    }

    // #region 清单读取
    private static function loadJson():Dynamic {
        var text:String = null;
        // 与 unity.addressableassets.ResourceManifest 一致的读取顺序：先按磁盘路径找
        // （仓库/部署目录里的 assets 根），再退回 lime 资源库。
        try {
            var path = ResourceManifest.get().resolvePath(MANIFEST_FILE);
            if (path != null)
                text = sys.io.File.getContent(path);
        } catch (e:Dynamic) {
            Debug.LogWarning('按磁盘路径读取 $MANIFEST_FILE 失败：$e');
        }
        if (text == null) {
            try {
                if (openfl.utils.Assets.exists(MANIFEST_FILE, openfl.utils.AssetType.TEXT))
                    text = openfl.utils.Assets.getText(MANIFEST_FILE);
            } catch (e:Dynamic) {
                Debug.LogWarning('按 lime 资源 id 读取 $MANIFEST_FILE 失败：$e');
            }
        }
        if (text == null)
            return null;
        return Json.parse(text);
    }

    private static function ingestClips(entries:Dynamic):Void {
        if (entries == null || !Std.isOfType(entries, Array))
            return;
        for (entry in (entries:Array<Dynamic>)) {
            if (entry == null)
                continue;
            var address:String = getString(entry, "address");
            if (address == null)
                continue;
            var clip = createClip(entry, address);
            byAddress.set(address, clip);
            // PORT-NOTE: 登记进 Addressables 的进程内注册表：ResourceManifest 加载资源前会先查它，
            // 于是音频走「按需解码」而不是「立即整包解码」。
            Addressables.RegisterAsset(address, clip);
            clipCount++;
        }
    }

    private static function createClip(entry:Dynamic, address:String):AudioClip {
        var clip = new AudioClip(address);
        clip.address = address;
        // PORT-NOTE: 清单里的 assetPath 是「相对 HaxePort/assets 的路径」，与 lime 的资源 id 同形，
        // 因此可以直接当 soundKey 交给 lime 或磁盘回退使用（见 unity.AudioClip.loadSoundData）。
        clip.soundKey = getString(entry, "assetPath");
        clip.format = getString(entry, "format");
        // PORT-NOTE: 时长等元数据来自转换阶段对音频文件头的探测（export_audio_manifest.py），
        // 因此不必解码文件就能满足 MusicManager 对 clip.length 的需求（Unity 侧同样由导入器提供）。
        clip.length = getFloat(entry, "length", 0);
        clip.frequency = getInt(entry, "frequency", 44100);
        clip.channels = getInt(entry, "channels", 1);
        // samples 也与文件头一致（wav 的帧数 / ogg 的 granule）；清单里没有时按 length × frequency 推算。
        clip.samples = getInt(entry, "samples", 0);
        if (clip.samples <= 0)
            clip.samples = Std.int(clip.length * clip.frequency);
        // Unity 的导入设置（.meta 的 AudioImporter）：loadType = DecompressOnLoad / CompressedInMemory / Streaming。
        clip.loadType = getInt(entry, "loadType", 0);
        clip.loadInBackground = getBool(entry, "loadInBackground", false);
        return clip;
    }

    private static function ingestMixers(mixers:Dynamic):Void {
        if (mixers == null || !Std.isOfType(mixers, Array) || (cast mixers:Array<Dynamic>).length == 0)
            return;
        // 工程只有一个 AudioMixer：Assets/Mixers/Main.mixer。
        var mixer:Dynamic = (cast mixers:Array<Dynamic>)[0];
        mixerName = getString(mixer, "name");
        var exposed = new Map<String, String>();
        var exposedRaw:Dynamic = Reflect.field(mixer, "exposedParameters");
        if (exposedRaw != null) {
            for (param in Reflect.fields(exposedRaw)) {
                var groupName:String = Reflect.field(exposedRaw, param);
                if (groupName != null)
                    exposed.set(param, groupName);
            }
        }
        AudioMixer.defineGraph(mixerName, Reflect.field(mixer, "groups"), exposed);
    }

    private static function ingestTemplates(list:Dynamic):Void {
        templates = [];
        if (list == null || !Std.isOfType(list, Array))
            return;
        for (item in (list:Array<Dynamic>)) {
            if (item != null)
                templates.push(item);
        }
    }
    // #endregion

    // #region 运行期查询
    /** 按 Addressables 地址取音频片段（等价于 Addressables.LoadAssetAsync<AudioClip>(address)）。 */
    public static function getClip(address:String):AudioClip {
        ensureLoaded();
        if (address == null)
            return null;
        if (byAddress.exists(address))
            return byAddress.get(address);
        // 清单里没有（例如 MOD 新增的音频）时交给 ResourceManifest 的默认路径。
        var handle:AsyncOperationHandle<Dynamic> = Addressables.LoadAssetAsync(address);
        return cast handle.WaitForCompletion();
    }

    /** 按地址直接取一个可播放的 FlxSound（调用方负责生命周期，循环音效需自行 Stop）。 */
    public static function createSound(address:String, looped:Bool = false):flixel.sound.FlxSound {
        var clip = getClip(address);
        if (clip == null)
            return null;
        return clip.newSound(looped);
    }

    /** 工程唯一的 AudioMixer（prefab 引用缺失时可用它设音量，见 unity.AudioMixer.main）。 */
    public static var mainMixer(get, never):AudioMixer;
    static function get_mainMixer():AudioMixer {
        ensureLoaded();
        return AudioMixer.main;
    }

    public static function getTemplates():Array<Dynamic> {
        ensureLoaded();
        return templates.copy();
    }

    public static function getTemplate(field:String):Dynamic {
        ensureLoaded();
        for (t in templates) {
            if (getString(t, "field") == field)
                return t;
        }
        return null;
    }

    /**
     * 按 MainManager.prefab 里的 AudioSource 配置（volume / loop / pitch / priority /
     * outputAudioMixerGroup）设置一个 AudioSource。
     *
     * PORT-NOTE: C# 侧这些值来自 prefab 的序列化数据（AudioSource 组件上的 m_Volume / Loop /
     * OutputAudioMixerGroup …）。prefab→场景 转换尚未完成时（见 mvz2/states/MainGameScene.hx 的
     * PORT-NOTE），场景里只 new 出了空的 AudioSource，可用本方法补齐；转换完成后这些值相同，重复调用无副作用。
     * 对应的 4 个模板：soundTemplate / loopSoundTemplate（Sound 总线）、mainTrackSource（MainTrack）、
     * subTrackSource（SubTrack）。
     */
    public static function applyTemplate(source:AudioSource, field:String):Bool {
        ensureLoaded();
        if (source == null)
            return false;
        var def:Dynamic = getTemplate(field);
        if (def == null) {
            Debug.LogWarning('音频模板「$field」不在 $MANIFEST_FILE 里，AudioSource 保持默认值。');
            return false;
        }
        source.playOnAwake = getBool(def, "playOnAwake", true);
        source.loop = getBool(def, "loop", false);
        source.mute = getBool(def, "mute", false);
        source.pitch = getFloat(def, "pitch", 1);
        source.volume = getFloat(def, "volume", 1);
        source.priority = getInt(def, "priority", 128);
        source.spatialBlend = getFloat(def, "spatialBlend", 0);
        source.dopplerLevel = getFloat(def, "dopplerLevel", 1);
        source.minDistance = getFloat(def, "minDistance", 1);
        source.maxDistance = getFloat(def, "maxDistance", 500);
        source.rolloffMode = getInt(def, "rolloffMode", 0);
        var groupName:String = getString(def, "mixerGroup");
        if (groupName != null) {
            var mixer:AudioMixer = mainMixer;
            var group = mixer.getGroup(groupName);
            if (group == null) {
                Debug.LogWarning('音频模板「$field」指定的 mixer 总线「$groupName」不存在（$MANIFEST_FILE）。');
            } else {
                source.outputAudioMixerGroup = group;
            }
        }
        return true;
    }
    // #endregion

    // #region 工具
    private static function getString(obj:Dynamic, field:String):String {
        var v:Dynamic = Reflect.field(obj, field);
        if (v == null)
            return null;
        if (Std.isOfType(v, String))
            return cast v;
        return null;
    }

    private static function getFloat(obj:Dynamic, field:String, def:Float):Float {
        var v:Dynamic = Reflect.field(obj, field);
        if (v == null)
            return def;
        if (Std.isOfType(v, Float) || Std.isOfType(v, Int))
            return Std.parseFloat(Std.string(v));
        return def;
    }

    private static function getInt(obj:Dynamic, field:String, def:Int):Int {
        var v:Dynamic = Reflect.field(obj, field);
        if (v == null)
            return def;
        if (Std.isOfType(v, Bool))
            return (cast v:Bool) ? 1 : 0;
        if (Std.isOfType(v, Int) || Std.isOfType(v, Float))
            return Std.int(Std.parseFloat(Std.string(v)));
        return def;
    }

    private static function getBool(obj:Dynamic, field:String, def:Bool):Bool {
        var v:Dynamic = Reflect.field(obj, field);
        if (v == null)
            return def;
        if (Std.isOfType(v, Bool))
            return cast v;
        if (Std.isOfType(v, Int))
            return (cast v:Int) != 0;
        return def;
    }
    // #endregion
}
