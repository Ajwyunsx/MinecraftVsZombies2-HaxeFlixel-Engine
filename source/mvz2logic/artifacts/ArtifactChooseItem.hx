// Ported from: Assets/Scripts/Logic/Artifacts/ArtifactChooseItem.cs
package mvz2logic.artifacts;

import pvzengine.NamespaceID;

class ArtifactChooseItem
{
	public function new(id:NamespaceID, innate:Bool = false)
	{
		this.id = id;
		this.innate = innate;
	}
	public var id:NamespaceID;
	public var innate:Bool;
}
