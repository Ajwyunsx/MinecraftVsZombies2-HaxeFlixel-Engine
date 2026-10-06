// Ported from: Assets/Scripts/Vanilla/Frameworks/ChapterTransitions/VanillaChapterTransitions.cs
package mvz2.vanilla.chaptertransitions;

import mvz2.vanilla.VanillaMod;
import mvz2logic.Global;
import pvzengine.NamespaceID;
import unity.Color;
import unity.Coroutine;
import unity.Coroutine.CoroutineContext;

class VanillaChapterTransitions
{
    // PORT-NOTE: C# 的 `yield return StartCoroutine(sub)` / `yield return sub` 语义是
    //   「挂起本协程直到 sub 结束」。原实现只是把 sub 交给一个**从未被步进**的静态
    //   CoroutineRunner，并且**没有挂起父协程** —— 于是父协程直接往下跑，过渡动画与
    //   场景切换完全失去先后关系（子协程永不推进）。
    //   unity.CoroutineContext.waitCoroutine 已提供该语义（且对已由别处启动的子协程
    //   不会重复步进，见 unity/Coroutine.hx 的 CoroutineRunner.tickWait），此处直接采用。
    private static function WaitCoroutine(co:CoroutineContext, routine:Coroutine):Void
    {
        co.waitCoroutine(routine);
    }
    public static var halloween:NamespaceID = Get("halloween");
    public static var dream:NamespaceID = Get("dream");
    public static var castle:NamespaceID = Get("castle");
    public static var mausoleum:NamespaceID = Get("mausoleum");
    public static var ship:NamespaceID = Get("ship");
    public static var palace:NamespaceID = Get("palace");
    private static function Get(name:String):NamespaceID
    {
        return new NamespaceID(VanillaMod.spaceName, name);
    }
    public static function TransitionToLevel(transition:NamespaceID, areaID:NamespaceID, stageID:NamespaceID):Coroutine
    {
        return Coroutine.create(function(co) {
            var music = Global.Music;
            var scene = Global.Scene;
            music.StartFade(0, 2);
            scene.SetScreenCoverColor(new Color(0, 0, 0, 0));
            scene.FadeScreenCoverColor(new Color(0, 0, 0, 1), 1);

            co.wait(2);

            return TransitionTalkToLevel(transition, areaID, stageID);
        });
    }
    public static function TransitionTalkToLevel(transition:NamespaceID, areaID:NamespaceID, stageID:NamespaceID):Coroutine
    {
        return Coroutine.create(function(co) {
            var music = Global.Music;
            var scene = Global.Scene;
            var level = Global.Level;
            music.Stop();
            scene.SetScreenCoverColor(new Color(0, 0, 0, 1));
            scene.FadeScreenCoverColor(new Color(0, 0, 0, 0), 0.5);
            WaitCoroutine(co, scene.GotoChapterTransitionCoroutine(transition, false));

            scene.SetScreenCoverColor(new Color(0, 0, 0, 1));
            WaitCoroutine(co, scene.GotoLevelCoroutine());

            co.wait(2);

            scene.FadeScreenCoverColor(new Color(0, 0, 0, 0), 1);
            music.SetVolume(1);
            level.InitLevel(areaID, stageID, 1);
            scene.HideChapterTransition();
        });
    }
    public static function TransitionToMap(transition:NamespaceID, mapID:NamespaceID, end:Bool):Coroutine
    {
        return Coroutine.create(function(co) {
            var music = Global.Music;
            var scene = Global.Scene;
            scene.SetScreenCoverColor(new Color(0, 0, 0, 1));
            scene.FadeScreenCoverColor(new Color(0, 0, 0, 0), 0.5);
            WaitCoroutine(co, scene.GotoChapterTransitionCoroutine(transition, end));

            music.StartFade(0, 1);
            co.wait(2);
            music.SetVolume(1);
            scene.SetScreenCoverColor(new Color(0, 0, 0, 1));
            scene.FadeScreenCoverColor(new Color(0, 0, 0, 0), 1);
            scene.HideChapterTransition();
            scene.GotoMap(mapID);
        });
    }
}
