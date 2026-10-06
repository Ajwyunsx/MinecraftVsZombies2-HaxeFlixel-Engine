package mvz2.map;

import mvz2.talk.MVZ2TalkSystem;
import mvz2.talk.TalkController;
import mvz2logic.archive.IArchiveInterface;
import mvz2logic.maps.IMapInterface;
import pvzengine.level.LevelEngine;

// Ported from: Assets/Scripts/MVZ2/Map/MapTalkSystem.cs
class MapTalkSystem extends MVZ2TalkSystem {
    public function new(map:IMapInterface, talk:TalkController) {
        super(talk);
        this.map = map;
    }

    override public function GetArchive():IArchiveInterface {
        return null;
    }
    override public function GetMap():IMapInterface {
        return map;
    }
    override public function GetLevel():LevelEngine {
        return null;
    }
    private var map:IMapInterface;
}
