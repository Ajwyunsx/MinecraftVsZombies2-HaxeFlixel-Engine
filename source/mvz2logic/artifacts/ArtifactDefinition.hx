// Ported from: Assets/Scripts/Logic/Artifacts/ArtifactDefinition.cs
package mvz2logic.artifacts;

import mvz2logic.definitions.LogicDefinitionTypes;
import pvzengine.auras.AuraEffectDefinition;
import pvzengine.base.Definition;

// abstract
class ArtifactDefinition extends Definition
{
	public function new(nsp:String, name:String)
	{
		super(nsp, name);
		SetProperty(LogicArtifactProps.NUMBER, -1);
	}
	public function GetAuras():Array<AuraEffectDefinition>
	{
		return auraDefinitions.copy();
	}
	public function PostUpdate(artifact:Artifact):Void {}
	public function PostAdd(artifact:Artifact):Void {}
	public function PostRemove(artifact:Artifact):Void {}
	// PORT-NOTE: C# protected -> Haxe 无 protected，改为 public。
	public function AddAura(aura:AuraEffectDefinition):Void
	{
		auraDefinitions.push(aura);
	}
	public override function GetDefinitionType():String
	{
		return LogicDefinitionTypes.ARTIFACT;
	}
	private var auraDefinitions:Array<AuraEffectDefinition> = [];
}
