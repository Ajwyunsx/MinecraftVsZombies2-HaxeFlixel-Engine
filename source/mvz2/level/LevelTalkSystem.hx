// Ported from: Assets/Scripts/MVZ2/Level/LevelTalkSystem.cs
package mvz2.level;

import mvz2.talk.MVZ2TalkSystem;
import mvz2.talk.TalkController;
import mvz2logic.archive.IArchiveInterface;
import mvz2logic.maps.IMapInterface;
import pvzengine.level.LevelEngine;

class LevelTalkSystem extends MVZ2TalkSystem
{
	public function new(level:LevelEngine, talk:TalkController)
	{
		super(talk);
		this.level = level;
	}
	override public function GetArchive():IArchiveInterface
	{
		return null;
	}
	override public function GetMap():IMapInterface
	{
		return null;
	}
	override public function GetLevel():LevelEngine
	{
		return level;
	}
	private var level:LevelEngine;
}
