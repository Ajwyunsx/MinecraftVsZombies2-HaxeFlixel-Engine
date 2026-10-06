// Ported from: Assets/Scripts/MVZ2/Talks/DefaultTalkSystem.cs
package mvz2.talk;

import mvz2logic.archive.IArchiveInterface;
import mvz2logic.maps.IMapInterface;
import pvzengine.level.LevelEngine;

class DefaultTalkSystem extends MVZ2TalkSystem {
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
