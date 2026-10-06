// Ported from: Assets/Scripts/Logic/Blueprints/LogicBlueprintID.cs
package mvz2logic.blueprints;

import pvzengine.NamespaceID;

class LogicBlueprintID
{
	public static function FromEntity(entityID:NamespaceID):NamespaceID
	{
		return entityID;
	}

	private function new() {}
}
