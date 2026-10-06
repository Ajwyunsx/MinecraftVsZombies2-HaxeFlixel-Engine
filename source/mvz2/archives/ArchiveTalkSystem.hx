package mvz2.archives;

import mvz2.talk.MVZ2TalkSystem;
import mvz2.talk.TalkController;
import mvz2logic.archive.IArchiveInterface;
import mvz2logic.maps.IMapInterface;
import pvzengine.level.LevelEngine;

// Ported from: Assets/Scripts/MVZ2/Archive/ArchiveTalkSystem.cs
class ArchiveTalkSystem extends MVZ2TalkSystem {
    public function new(archive:IArchiveInterface, talk:TalkController) {
        super(talk);
        this.archive = archive;
    }

    override public function GetArchive():IArchiveInterface {
        return archive;
    }
    override public function GetMap():IMapInterface {
        return null;
    }
    override public function GetLevel():LevelEngine {
        return null;
    }
    private var archive:IArchiveInterface;
}
