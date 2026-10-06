// Ported from: Assets/Scripts/MVZ2/Talks/MVZ2TalkSystem.cs
package mvz2.talk;

import mvz2.managers.MainManager;
import mvz2logic.archive.IArchiveInterface;
import mvz2logic.maps.IMapInterface;
import mvz2logic.talk.ITalkSystem;
import pvzengine.NamespaceID;
import pvzengine.level.LevelEngine;
import system.threading.tasks.Task;
using mvz2logic.level.LogicLevelExt;  // EXTUSING

// abstract
class MVZ2TalkSystem implements ITalkSystem {
    public function new(talk:TalkController) {
        this.talk = talk;
    }
    public function StartSection(section:Int):Task {
        return talk.StartSection(section);
    }

    public function StartTalk(id:NamespaceID, section:Int, delay:Float = 1, ?onEnd:Void->Void):Void {
        talk.StartTalk(id, section, delay, onEnd);
    }

    public function WillSkipTalk(id:NamespaceID, section:Int):Bool {
        return talk.WillSkipTalk(id, section);
    }

    public function AutoSkipTalks(id:NamespaceID, section:Int, ?onSkipped:Void->Void):Void {
        talk.AutoSkipTalks(id, section, onSkipped);
    }
    // abstract
    public function GetArchive():IArchiveInterface {
        throw "abstract";
    }
    // abstract
    public function GetMap():IMapInterface {
        throw "abstract";
    }
    // abstract
    public function GetLevel():LevelEngine {
        throw "abstract";
    }

    public function ShowDialog(title:String, desc:String, options:Array<String>, onSelect:Int->Void):Void {
        Main.Scene.ShowDialog(title, desc, options, onSelect);
    }
    private var Main(get, never):MainManager;
    function get_Main():MainManager return MainManager.Instance;
    private var talk:TalkController;
}
