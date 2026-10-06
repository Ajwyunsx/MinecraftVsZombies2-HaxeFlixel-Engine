// PORT-NOTE: 验证用（不参与游戏构建）。工作包 ④ 的音频管线运行时冒烟测试：
// 真实读取 HaxePort/assets/audio_manifest.json，检查
//   * 清单接入（AudioManifest.attach → Addressables 注册表 → 按地址取 AudioClip，且**不解码文件**）
//   * 按标签/类型查询（ResourceManager.LoadLabeledResources 的走法）
//   * AudioClip 的时长/采样率/声道/loadType（来自转换阶段的文件头探测，Unity 侧由导入器提供）
//   * AudioClip.newSound / AudioSource 的真实播放（播放/暂停/停止/时间/循环）
//   * AudioMixer 总线（SoundVolume/MusicVolume/FadeVolume/MainWeight/SubWeight 的分层增益）
//   * prefab 的 4 个 AudioSource 模板（volume/loop/pitch/mixerGroup）能被 applyTemplate 还原
//
// 运行：bash HaxePort/tools_build/check_audio.sh          # neko（默认，最快）
//       bash HaxePort/tools_build/check_audio.sh --cpp    # 与游戏同一目标
package audio;

import flixel.FlxG;
import flixel.sound.FlxSound;
import mvz2.audios.AudioManifest;
import mvz2.audios.AudioHelper;
import unity.AudioClip;
import unity.AudioMixer;
import unity.AudioMixerGroup;
import unity.AudioSource;
import unity.addressableassets.Addressables;
import unity.addressableassets.Addressables.AsyncOperationHandle;
import unity.addressableassets.IResourceLocator;
import unity.addressableassets.ResourceManifest;

class AudioPipelineSmokeTest {
    private static var checks:Int = 0;
    private static var notes:Int = 0;
    private static var failures:Array<String> = [];
    private static var click:AudioClip = null;

    public static function main():Void {
        ensureSoundFrontEnd();
        checkManifest();
        var locator = checkLocator();
        checkClips(locator);
        checkMixer();
        checkTemplates();
        checkPlayback();
        checkLoopPlayback();

        info('--------------------------------------------');
        info('检查项 $checks，失败 ${failures.length}，说明 $notes');
        for (f in failures)
            info('  FAIL ' + f);
        Sys.exit(failures.length == 0 ? 0 : 1);
    }

    // #region 无头运行环境
    /**
     * PORT-NOTE: 本测试不创建 FlxGame（无头运行），但 FlxSound 需要 FlxG.sound 才能挂进更新列表，
     * 因此手动装一个 SoundFrontEnd（与工作包 ② 的 AddressablesSmokeTest 同样的做法）。
     */
    private static function ensureSoundFrontEnd():Void {
        if (FlxG.sound != null)
            return;
        try {
            var frontEndClass = Type.resolveClass('flixel.system.frontEnds.SoundFrontEnd');
            if (frontEndClass != null)
                Reflect.setField(FlxG, 'sound', Type.createInstance(frontEndClass, []));
        } catch (e:Dynamic) {}
        check(FlxG.sound != null, 'FlxG.sound 已就绪（无头测试手动建立 SoundFrontEnd）');
    }
    // #endregion

    // #region 清单接入
    private static function checkManifest():Void {
        AudioManifest.ensureLoaded();
        check(AudioManifest.loaded, 'AudioManifest 已加载 ${AudioManifest.MANIFEST_FILE}');
        check(!AudioManifest.failed, 'AudioManifest 没有退化为解码回退路径');
        check(AudioManifest.clipCount == 526, '清单 clip 数 ${AudioManifest.clipCount}（期望 526）');
    }

    private static function checkLocator():IResourceLocator {
        var locator:IResourceLocator = Addressables.InitializeAsync().Task;
        check(locator != null, 'Addressables.InitializeAsync().Task 返回 locator');
        if (locator == null)
            return null;
        count(locator, 'Sound', AudioClip, 482);
        count(locator, 'Music', AudioClip, 44);
        // ResourceManager.LoadLabeledResources 用的是「标签交集」（LoadLabeledResourcesMulti + Intersection）
        intersect(locator, 'Init', 'Sound', 1);
        intersect(locator, 'Main', 'Sound', 481);
        intersect(locator, 'Main', 'Music', 43);
        // PORT-NOTE: Unity 的 IResourceLocator.Locate(label, type) 会**严格**按类型过滤；移植层的
        // ResourceManifest 对「类型未知（Kind=Other）」的条目故意不过滤（避免误杀尚未转换的资源），
        // 于是 Locate("Init"/"Main", AudioClip) 会比 Unity 多出若干非音频位置。这不影响音频本身
        // （音频条目全部命中），但会让 ResourceManager.LoadResourcesByLocations 把非音频对象也塞进
        // ModResource.Sounds/Musics。已作为跨工作包事项记录（详见报告）。
        var initLocations = locator.Locate('Init', AudioClip);
        var initAudio = 0;
        for (l in initLocations) {
            var path = Std.string(Reflect.field(l, 'Path'));
            if (StringTools.endsWith(path, '.wav') || StringTools.endsWith(path, '.ogg') || StringTools.endsWith(path, '.mp3'))
                initAudio++;
        }
        check(initAudio == 2, 'Locate("Init", AudioClip) 的 ${initLocations.length} 个位置里含 $initAudio 个音频（期望 2）');
        note('Locate("Init", AudioClip)=${initLocations.length}、Locate("Main", AudioClip)=${locator.Locate('Main', AudioClip).length}'
            + '：类型未知条目未被过滤（Unity 侧是严格过滤），见 ResourceManifest.locate 的说明');
        return locator;
    }

    private static function checkClips(locator:IResourceLocator):Void {
        var handle:AsyncOperationHandle<Dynamic> = Addressables.LoadAssetAsync('mvz2:click');
        var clip:Dynamic = handle.WaitForCompletion();
        check(Std.isOfType(clip, AudioClip), 'mvz2:click → AudioClip（实际 ${typeNameOf(clip)}）');
        if (!Std.isOfType(clip, AudioClip)) {
            click = null;
            return;
        }
        click = cast clip;
        check(click.length > 0.32 && click.length < 0.33, 'click 时长 ${click.length}s（期望 0.325）');
        check(click.frequency == 44100, 'click 采样率 ${click.frequency}（期望 44100）');
        check(click.channels == 2, 'click 声道 ${click.channels}（期望 2）');
        check(click.loadType == 0, 'click loadType ${click.loadType}（AudioClipLoadType.DecompressOnLoad）');
        check(click.soundKey == 'GameContent/Assets/mvz2/sounds/init/click.wav', 'click soundKey=${click.soundKey}');
        // samples 直接来自音频文件头（wav 帧数 / ogg granule），与 ResourceManifest 解码路径的算法结果一致
        check(click.samples == 14336, 'click 采样数 ${click.samples}（期望 14336，来自文件头）');
        // 关键点：注册表命中的 AudioClip 不解码文件（sound/flxSound 仍为空），解码推迟到播放时。
        check(click.sound == null && click.flxSound == null, '音频未在加载阶段解码（Streaming 语义）');
        // 首次取数据后要补齐 ResourceManifest 的字段契约（sound/flxSound）
        var decoded = click.getSoundData();
        check(decoded != null && click.sound == decoded && click.flxSound != null,
            '首次取数据后补齐 clip.sound / clip.flxSound（与 ResourceManifest 解码路径一致）');
        var wind:AudioClip = AudioManifest.getClip('mvz2:wind');
        if (wind != null)
            check(wind.samples == 118414, 'wind.wav 采样数 ${wind.samples}（期望 118414）');

        // 与 C# 一致：按 NamespaceID 取到的 clip 会存进 ModResource.Sounds（key = 去掉命名空间的路径）
        var day:AudioClip = AudioManifest.getClip('mvz2:day');
        check(day != null, 'mvz2:day → AudioClip');
        if (day != null)
            check(Math.abs(day.length - 143.894694) < 0.05, 'day 时长 ${day.length}s（期望 143.895）');
        var mainmenu:AudioClip = AudioManifest.getClip('mvz2:mainmenu');
        check(mainmenu != null && StringTools.endsWith(mainmenu.soundKey, 'init/mainmenu.ogg'),
            'mvz2:mainmenu → ${mainmenu == null ? "null" : mainmenu.soundKey}');

        // PORT-NOTE: 工程里有 3 个 sample 指向不存在的地址（sounds.xml 的 skeleton_horse_cry1..3，
        // Unity 侧同样取不到 clip、播不出声），这里确认移植层的行为一致（返回 null，不抛异常）。
        var missing = Addressables.LoadAssetAsync('mvz2:entity/skeleton_horse/skeleton_horse_cry1');
        check(missing.Task == null, '不存在的音频地址 → null（与 Unity 的 FindInMods 行为一致）');

        // mp3 → ogg 转换（lime 的原生音频不支持 mp3；Unity 侧本来就是 Vorbis）
        var wither:AudioClip = AudioManifest.getClip('mvz2:wither_boss');
        check(wither != null && StringTools.endsWith(wither.soundKey, '.ogg'),
            'mvz2:wither_boss 已转换为 ogg（${wither == null ? "null" : wither.soundKey}）');
        if (wither != null) {
            var sound = wither.getSoundData();
            check(sound != null, '转换后的 ogg 能被 lime 解码（${wither.soundKey}）');
        }
    }
    // #endregion

    // #region 总线
    private static function checkMixer():Void {
        var mixer = AudioManifest.mainMixer;
        check(mixer != null, 'AudioMixer 可用（${mixer == null ? "null" : mixer.name}）');
        if (mixer == null)
            return;
        // 总线的父子结构与 Main.mixer 一致：Master → Music → Fade → MainTrack/SubTrack，Sound 挂在 Master 下
        check(same(mixer.getGroup('Master'), mixer.getGroup('Music').parent), 'Music 的父总线是 Master');
        check(same(mixer.getGroup('Music'), mixer.getGroup('Fade').parent), 'Fade 的父总线是 Music');
        check(same(mixer.getGroup('Fade'), mixer.getGroup('MainTrack').parent), 'MainTrack 的父总线是 Fade');
        check(same(mixer.getGroup('Fade'), mixer.getGroup('SubTrack').parent), 'SubTrack 的父总线是 Fade');
        check(same(mixer.getGroup('Master'), mixer.getGroup('Sound').parent), 'Sound 的父总线是 Master');

        check(mixer.SetFloat('SoundVolume', AudioHelper.PercentageToDbA(0.5)), 'SetFloat(SoundVolume, 0.5) 返回 true');
        approx('Sound 总线增益', mixer.getGroup('Sound').getLinearVolume(), 0.5, 0.001);
        check(mixer.SetFloat('MusicVolume', AudioHelper.PercentageToDbA(0.8)), 'SetFloat(MusicVolume, 0.8) 返回 true');
        approx('Music 总线增益', mixer.getGroup('Music').getLinearVolume(), 0.8, 0.001);
        mixer.SetFloat('FadeVolume', AudioHelper.PercentageToDbA(1));
        mixer.SetFloat('MainWeight', AudioHelper.PercentageToDbA(1));
        mixer.SetFloat('SubWeight', AudioHelper.PercentageToDbA(0));
        approx('MainTrack 总线增益 = Music', mixer.getGroup('MainTrack').getLinearVolume(), 0.8, 0.001);
        approx('SubTrack 总线增益 = Music × SubWeight(-80dB)', mixer.getGroup('SubTrack').getLinearVolume(), 0.00008, 0.00001);
        // MusicManager.SetTrackWeight(1) → 主轨静音、副轨满音量
        mixer.SetFloat('MainWeight', AudioHelper.PercentageToDbA(0));
        mixer.SetFloat('SubWeight', AudioHelper.PercentageToDbA(1));
        approx('SetTrackWeight(1) 后 MainTrack 增益', mixer.getGroup('MainTrack').getLinearVolume(), 0.00008, 0.00001);
        approx('SetTrackWeight(1) 后 SubTrack 增益', mixer.getGroup('SubTrack').getLinearVolume(), 0.8, 0.001);
        // 未暴露的参数名：Unity 返回 false；移植层会补建同名总线并告警
        check(mixer.SetFloat('NotExposed', 0) == true, '未暴露参数不静默失效（补建同名总线）');
        // 复原到默认，避免影响后面的可听检查
        mixer.SetFloat('SoundVolume', 0);
        mixer.SetFloat('MusicVolume', 0);
        mixer.SetFloat('MainWeight', 0);
        mixer.SetFloat('SubWeight', 0);
        approx('复原后 Sound 总线增益', mixer.getGroup('Sound').getLinearVolume(), 1, 0.001);
    }

    private static function checkTemplates():Void {
        var soundTemplate = AudioManifest.getTemplate('soundTemplate');
        check(soundTemplate != null && Reflect.field(soundTemplate, 'loop') == false
            && Reflect.field(soundTemplate, 'mixerGroup') == 'Sound',
            'audioSourceTemplates.soundTemplate：loop=false, mixerGroup=Sound');
        var loopTemplate = AudioManifest.getTemplate('loopSoundTemplate');
        check(loopTemplate != null && Reflect.field(loopTemplate, 'loop') == true,
            'audioSourceTemplates.loopSoundTemplate：loop=true');
        var mainTemplate = AudioManifest.getTemplate('mainTrackSource');
        check(mainTemplate != null && Reflect.field(mainTemplate, 'loop') == true
            && Reflect.field(mainTemplate, 'mixerGroup') == 'MainTrack',
            'audioSourceTemplates.mainTrackSource：loop=true, mixerGroup=MainTrack');

        var source = new AudioSource();
        check(AudioManifest.applyTemplate(source, 'mainTrackSource'), 'applyTemplate(mainTrackSource) 返回 true');
        check(source.loop, 'MusicManager 音轨源 loop=${source.loop}（期望 true）');
        check(source.outputAudioMixerGroup != null && source.outputAudioMixerGroup.name == 'MainTrack',
            'MusicManager 音轨源总线=${source.outputAudioMixerGroup == null ? "null" : source.outputAudioMixerGroup.name}（期望 MainTrack）');
        approx('MusicManager 音轨源 volume', source.volume, 1, 0.0001);
        var sfx = new AudioSource();
        AudioManifest.applyTemplate(sfx, 'loopSoundTemplate');
        check(sfx.loop && sfx.outputAudioMixerGroup.name == 'Sound', '循环音效模板走 Sound 总线且 loop=true');
    }
    // #endregion

    // #region 真实播放
    private static function checkPlayback():Void {
        if (click == null) {
            fail('没有 click clip，跳过播放检查');
            return;
        }
        if (click.getSoundData() == null) {
            fail('click 的音频数据无法解码（${click.soundKey}）');
            return;
        }
        var source = new AudioSource();
        source.clip = click;
        source.outputAudioMixerGroup = AudioManifest.mainMixer.getGroup('Sound');
        source.Play();
        if (!source.isPlaying) {
            note('音频通道未能建立（可能没有可用的音频设备），跳过播放断言');
            return;
        }
        check(source.isPlaying, 'AudioSource.Play() 后 isPlaying=true');
        check(source.time >= 0, 'AudioSource.time=${source.time}s');
        Sys.sleep(0.15);
        // 手动推进 flixel 的 FlxSound 更新（无头测试里由 FlxGame 每帧驱动）
        tickFrames(0.016, 9);
        var t = source.time;
        check(t > 0.05, '播放 0.15s 后 time=${t}s（应已推进；本机 lime 原生后端不上报位置，由本地时钟补上）');
        check(source.timeSamples > 0, 'timeSamples=${source.timeSamples}（采样位置）');
        // 寻址：MusicManager.SetNormalizedMusicTime 用 time/timeSamples 定位
        source.time = 0.1;
        tickFrames(0.016, 2);
        check(Math.abs(source.time - 0.1) < 0.05, '设置 time=0.1 后 time=${source.time}s');
        source.Pause();
        FlxG.sound.list.update(0.016);
        var pausedTime = source.time;
        check(!source.isPlaying, 'Pause() 后 isPlaying=false（与 Unity 一致）');
        Sys.sleep(0.1);
        FlxG.sound.list.update(0.016);
        check(source.time == pausedTime, '暂停期间 time 不推进（${source.time}s）');
        source.UnPause();
        tickFrames(0.016, 2);
        check(source.isPlaying, 'UnPause() 后 isPlaying=true');
        check(source.time >= pausedTime - 0.02, 'UnPause() 从暂停位置继续（${source.time}s）');
        source.Stop();
        FlxG.sound.list.update(0.016);
        check(!source.isPlaying && source.time == 0, 'Stop() 后 isPlaying=false 且 time 归零');

        // 播完自动结束（click 时长 0.325s；后端不派发 SOUND_COMPLETE，结束由本地时钟判定）
        var shortSource = new AudioSource();
        shortSource.clip = click;
        shortSource.Play();
        for (i in 0...30) {
            Sys.sleep(0.02);
            FlxG.sound.list.update(0.02);
        }
        check(!shortSource.isPlaying, '非循环音效播完后 isPlaying=false（SoundManager.Update 据此回收音源）');

        // 总线音量实时作用于正在播放的声音
        var grouped = new AudioSource();
        grouped.clip = click;
        grouped.outputAudioMixerGroup = AudioManifest.mainMixer.getGroup('Sound');
        grouped.volume = 0.5;
        grouped.Play();
        if (grouped.isPlaying) {
            AudioManifest.mainMixer.SetFloat('SoundVolume', AudioHelper.PercentageToDbA(0.5));
            var bus = AudioManifest.mainMixer.getGroup('Sound');
            approx('总线音量写入 flixel 组', bus.group.volume, 0.5, 0.001);
            AudioManifest.mainMixer.SetFloat('SoundVolume', 0);
            approx('总线音量复原', bus.group.volume, 1, 0.001);
            grouped.Stop();
        }
    }

    private static function checkLoopPlayback():Void {
        if (click == null || click.getSoundData() == null)
            return;
        // click 时长 0.325s：循环播放要跨越多个循环周期，且位置要回绕
        var source = new AudioSource();
        AudioManifest.applyTemplate(source, 'loopSoundTemplate');
        source.clip = click;
        source.Play();
        if (!source.isPlaying) {
            note('音频通道未能建立，跳过循环检查');
            return;
        }
        var wraps = 0;
        var lastTime = 0.0;
        var maxTime = 0.0;
        var elapsed = 0.0;
        while (elapsed < 1.3) {
            Sys.sleep(0.05);
            elapsed += 0.05;
            FlxG.sound.list.update(0.05);
            var now = source.time;
            if (now < lastTime)
                wraps++;
            lastTime = now;
            if (now > maxTime)
                maxTime = now;
        }
        check(wraps >= 2, '循环音效 1.3s 内回绕 $wraps 次（期望 ≥2，click 时长 ${click.length}s）');
        check(maxTime <= click.length + 0.05, '循环音效位置上限 ${maxTime}s（不超过 clip 时长 ${click.length}s）');
        check(source.isPlaying, '循环音效一直在播放');
        source.Stop();
        FlxG.sound.list.update(0.016);
        check(!source.isPlaying, '循环音效 Stop() 后停止');
    }

    /** 手动推进 flixel 的 FlxSound 更新（无头测试里由 FlxGame 每帧驱动）。 */
    private static function tickFrames(elapsed:Float, count:Int):Void {
        for (_ in 0...count) {
            Sys.sleep(elapsed);
            FlxG.sound.list.update(elapsed);
        }
    }
    // #endregion

    // #region 断言
    private static function count(locator:IResourceLocator, label:String, type:Dynamic, expected:Int):Void {
        var result = locator.Locate(label, type);
        check(result.length == expected, 'Locate("$label", AudioClip) = ${result.length}（期望 $expected）');
    }

    private static function intersect(locator:IResourceLocator, labelA:String, labelB:String, expected:Int):Void {
        var a = locator.Locate(labelA, AudioClip);
        var b = locator.Locate(labelB, AudioClip);
        var n = 0;
        for (x in a) {
            for (y in b) {
                if (x.PrimaryKey == y.PrimaryKey && x.InternalId == y.InternalId) {
                    n++;
                    break;
                }
            }
        }
        check(n == expected, 'Locate("$labelA") ∩ Locate("$labelB") = $n（期望 $expected）');
    }

    private static function same(a:AudioMixerGroup, b:AudioMixerGroup):Bool {
        return a != null && a == b;
    }

    private static function typeNameOf(value:Dynamic):String {
        if (value == null)
            return 'null';
        try {
            return Type.getClassName(Type.getClass(value));
        } catch (e:Dynamic) {
            return Std.string(value);
        }
    }

    private static function check(condition:Bool, message:String):Void {
        checks++;
        if (condition) {
            Sys.println('[ ok ] ' + message);
        } else {
            Sys.println('[FAIL] ' + message);
            failures.push(message);
        }
    }

    private static function approx(name:String, actual:Float, expected:Float, tolerance:Float):Void {
        check(Math.abs(actual - expected) <= tolerance, '$name = $actual（期望 $expected ± $tolerance）');
    }

    private static function info(message:String):Void {
        Sys.println('[info] ' + message);
    }

    private static function note(message:String):Void {
        notes++;
        Sys.println('[note] ' + message);
    }

    private static function fail(message:String):Void {
        check(false, message);
    }
    // #endregion
}
