// Ported from: Assets/Scripts/Logic/Spawns/LogicSpawnDefinition.cs
package mvz2logic.spawns;

import pvzengine.spawns.ISpawnEndlessBehaviour;
import pvzengine.spawns.ISpawnInLevelBehaviour;
import pvzengine.spawns.ISpawnPreviewBehaviour;
import pvzengine.spawns.SpawnDefinition;

class LogicSpawnDefinition extends SpawnDefinition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
	}
	public function SetBehaviours(inLevelBehaviour:ISpawnInLevelBehaviour, previewBehaviour:ISpawnPreviewBehaviour, endlessBehaviour:ISpawnEndlessBehaviour):Void
	{
		this.inLevelBehaviour = inLevelBehaviour;
		this.previewBehaviour = previewBehaviour;
		this.endlessBehaviour = endlessBehaviour;
	}
	// PORT-NOTE: C# 为 protected override，Haxe 无 protected。
	override function GetPreviewBehaviour():ISpawnPreviewBehaviour return previewBehaviour;
	override function GetInLevelBehaviour():ISpawnInLevelBehaviour return inLevelBehaviour;
	override function GetEndlessBehaviour():ISpawnEndlessBehaviour return endlessBehaviour;
	private var inLevelBehaviour:ISpawnInLevelBehaviour;
	private var previewBehaviour:ISpawnPreviewBehaviour;
	private var endlessBehaviour:ISpawnEndlessBehaviour;
}
