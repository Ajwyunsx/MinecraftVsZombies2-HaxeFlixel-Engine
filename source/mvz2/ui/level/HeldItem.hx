// Ported from: Assets/Scripts/View/Level/HeldItem.cs
package mvz2.ui.level;

import mvz2.models.IModelBuilder;
import mvz2.models.Model;
import unity.GameObject;
import unity.Transform;
import unity.UnityObject;
import unity.MonoBehaviour;

class HeldItem extends unity.MonoBehaviour
{
	public function UpdateModelFixed():Void
	{
		if (UnityObject.exists(model))
		{
			model.UpdateFixed();
		}
	}
	public function UpdateModelFrame(deltaTime:Float):Void
	{
		if (UnityObject.exists(model))
		{
			model.UpdateFrame(deltaTime);
		}
	}
	public function SetModelSimulationSpeed(speed:Float):Void
	{
		if (UnityObject.exists(model))
		{
			model.SetSimulationSpeed(speed);
		}
	}
	public function SetModel(viewData:IModelBuilder):Void
	{
		if (UnityObject.exists(model))
		{
			UnityObject.destroy(model.gameObject);
			model = null;
		}
		model = viewData.Build(modelRoot);
	}
	public function GetModel():Null<Model>
	{
		return model;
	}
	public function SetTrigger(visible:Bool, trigger:Bool):Void
	{
		triggerObj.SetActive(visible && trigger);
		notTriggerObj.SetActive(visible && !trigger);
	}
	public function SetImbued(value:Bool):Void
	{
		imbuedObj.SetActive(value);
	}
	@:serializeField
	private var modelRoot:Transform;
	@:serializeField
	private var triggerObj:GameObject;
	@:serializeField
	private var notTriggerObj:GameObject;
	@:serializeField
	private var imbuedObj:GameObject;
	private var model:Null<Model>;
}
