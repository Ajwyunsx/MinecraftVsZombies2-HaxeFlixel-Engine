// Ported from: Assets/Scripts/View/Models/Interfaces/ModelParentInterface.cs
package mvz2.models;

class ModelParentInterface extends ModelInterface
{
	public function new(model:Model)
	{
		super();
		this.model = model;
	}
	override function GetModel():Null<Model>
	{
		return model;
	}
	private var model:Model;
}
