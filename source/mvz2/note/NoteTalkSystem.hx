package mvz2.note;

import mvz2.talk.MVZ2TalkSystem;
import mvz2.talk.TalkController;
import mvz2logic.archive.IArchiveInterface;
import mvz2logic.maps.IMapInterface;
import pvzengine.level.LevelEngine;

// Ported from: Assets/Scripts/MVZ2/Note/NoteTalkSystem.cs
class NoteTalkSystem extends MVZ2TalkSystem {
    public function new(talk:TalkController) {
        super(talk);
    }

    override public function GetArchive():IArchiveInterface {
        return null;
    }
    override public function GetMap():IMapInterface {
        return null;
    }
    override public function GetLevel():LevelEngine {
        return null;
    }
}
