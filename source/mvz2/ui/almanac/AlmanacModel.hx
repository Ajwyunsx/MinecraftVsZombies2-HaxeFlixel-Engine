// Ported from: Assets/Scripts/View/Almanac/AlmanacModel.cs
package mvz2.ui.almanac;

import mvz2.models.EntityModel;
import mvz2.models.IModelBuilder;
import mvz2.models.Model;
import mvz2.models.ModelUpdater;
import unity.Transform;
import unity.UnityObject;
import unity.MonoBehaviour;

class AlmanacModel extends unity.MonoBehaviour
{
	public function ChangeModel(builder:IModelBuilder):Void
	{
		if (UnityObject.exists(model))
		{
			UnityObject.destroy(model.gameObject);
			model = null;
			updater.model = null;
		}
		model = builder.Build(rootTransform);
		if (UnityObject.exists(model))
		{
			updater.model = model;
			if (Std.isOfType(model, EntityModel))
			{
				var spriteModel:EntityModel = cast model;
				spriteModel.CancelSortAtRoot();
			}
		}
	}
	@:serializeField
	private var rootTransform:Transform;
	@:serializeField
	private var updater:ModelUpdater;
	@:serializeField
	private var model:Null<Model>;
}
