// Ported from: Assets/Scripts/View/Models/ModelUpdater.cs
package mvz2.models;

import mvz2.states.BootTrace;
import unity.Time;
import unity.UnityObject;

class ModelUpdater extends unity.MonoBehaviour
{
	function Awake():Void
	{
		if (UnityObject.exists(model))
		{
			BootTrace.step('ModelUpdater.InitModel 开始 @' + gameObject.name);
			model.InitModel();
			BootTrace.step('ModelUpdater.InitModel 完成 @' + gameObject.name);
		}
	}
	function Update():Void
	{
		if (UnityObject.exists(model))
		{
			var deltaTime = Time.deltaTime;
			model.UpdateFrame(deltaTime);
			model.UpdateAnimators(deltaTime);
		}
	}
	function FixedUpdate():Void
	{
		if (UnityObject.exists(model))
		{
			model.UpdateFixed();
		}
	}

	public var model:Null<Model>;
}
