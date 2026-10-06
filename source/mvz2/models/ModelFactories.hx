// Ported from: Assets/Scripts/View/Models/ModelFactories.cs
package mvz2.models;

import pvzengine.NamespaceID;
import unity.Camera;
import unity.Transform;

class ModelFactories
{
	public static function Create(id:Null<NamespaceID>, camera:Camera, parentTransform:Transform, ?seed:Int = 0):Null<Model>
	{
		if (factory == null)
		{
			return null;
		}
		return factory.CreateModel(id, camera, parentTransform, seed);
	}
	public static function SetFactory(value:IModelFactory):Void
	{
		factory = value;
	}
	private static var factory:Null<IModelFactory>;
}

interface IModelFactory
{
	function CreateModel(id:Null<NamespaceID>, camera:Camera, parentTransform:Transform, ?seed:Int = 0):Null<Model>;
}
