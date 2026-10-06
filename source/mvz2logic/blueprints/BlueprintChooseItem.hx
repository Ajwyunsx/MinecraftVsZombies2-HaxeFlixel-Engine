// Ported from: Assets/Scripts/Logic/Blueprints/BlueprintChooseItem.cs
package mvz2logic.blueprints;

import mvz2logic.saves.BlueprintChooseSaveItem;
import pvzengine.NamespaceID;

class BlueprintChooseItem
{
	public function new(id:NamespaceID, isCommandBlock:Bool = false, innate:Bool = false)
	{
		this.id = id;
		this.isCommandBlock = isCommandBlock;
		this.innate = innate;
	}
	public function ToSaveItem():BlueprintChooseSaveItem
	{
		return new BlueprintChooseSaveItem(id, isCommandBlock);
	}
	public var id:NamespaceID;
	public var isCommandBlock:Bool;
	public var innate:Bool;
}
