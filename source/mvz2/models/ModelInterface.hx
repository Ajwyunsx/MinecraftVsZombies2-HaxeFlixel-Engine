// Ported from: Assets/Scripts/View/Models/Interfaces/ModelInterface.cs
package mvz2.models;

import pvzengine.NamespaceID;
import pvzengine.models.IAnimatorInterface;
import pvzengine.models.IModelInterface;
import unity.Color;
import unity.UnityObject;
import unity.Vector4;
using pvzengine.models.HasModelExt;  // EXTUSING

// abstract
class ModelInterface implements IModelInterface
{
	public function new() { } // CTORFIX
	public function UpdateModel():Void
	{
		var targetModel = GetModel();
		if (!UnityObject.exists(targetModel))
			return;
		targetModel.UpdateFrame(0);
		targetModel.UpdateAnimators(0);
	}
	public function TriggerAnimation(name:String):Void
	{
		var targetModel = GetModel();
		if (!UnityObject.exists(targetModel))
			return;
		targetModel.TriggerAnimator(name);
	}
	public function SetAnimationBool(name:String, value:Bool):Void
	{
		var targetModel = GetModel();
		if (!UnityObject.exists(targetModel))
			return;
		targetModel.SetAnimatorBool(name, value);
	}
	public function SetAnimationInt(name:String, value:Int):Void
	{
		var targetModel = GetModel();
		if (!UnityObject.exists(targetModel))
			return;
		targetModel.SetAnimatorInt(name, value);
	}
	public function SetAnimationFloat(name:String, value:Float):Void
	{
		var targetModel = GetModel();
		if (!UnityObject.exists(targetModel))
			return;
		targetModel.SetAnimatorFloat(name, value);
	}
	public function GetAnimatorInterface(name:String):Null<IAnimatorInterface>
	{
		var targetModel = GetModel();
		if (!UnityObject.exists(targetModel))
			return null;
		return targetModel.GetAnimatorInterface(name);
	}
	public function SetModelProperty(name:String, value:Dynamic):Void
	{
		var model = GetModel();
		if (!UnityObject.exists(model))
			return;
		model.SetProperty(name, value);
	}
	public function TriggerModel(name:String):Void
	{
		var model = GetModel();
		if (!UnityObject.exists(model))
			return;
		model.TriggerModel(name);
	}
	public function SetShaderInt(name:String, value:Int):Void
	{
		var model = GetModel();
		if (!UnityObject.exists(model))
			return;
		model.SetShaderInt(name, value);
	}
	public function SetShaderFloat(name:String, value:Float):Void
	{
		var model = GetModel();
		if (!UnityObject.exists(model))
			return;
		model.SetShaderFloat(name, value);
	}
	public function SetShaderColor(name:String, value:Color):Void
	{
		var model = GetModel();
		if (!UnityObject.exists(model))
			return;
		model.SetShaderColor(name, value);
	}
	public function SetShaderVector(name:String, value:Vector4):Void
	{
		var model = GetModel();
		if (!UnityObject.exists(model))
			return;
		model.SetShaderVector(name, value);
	}
	public function ApplyShaderProperties():Void
	{
		var model = GetModel();
		if (!UnityObject.exists(model))
			return;
		model.ApplyShaderProperties();
	}
	public function CreateChildModel(anchorName:String, key:NamespaceID, modelID:NamespaceID):Null<IModelInterface>
	{
		var model = GetModel();
		if (!UnityObject.exists(model))
			return null;
		var child = model.CreateChildModel(anchorName, key, modelID);
		if (child == null)
			return null;
		return child.GetParentModelInterface();
	}
	public function RemoveChildModel(key:NamespaceID):Bool
	{
		var model = GetModel();
		if (!UnityObject.exists(model))
			return false;
		return model.RemoveChildModel(key);
	}
	public function GetChildModel(key:NamespaceID):Null<IModelInterface>
	{
		var model = GetModel();
		if (!UnityObject.exists(model))
			return null;
		var child = model.GetChildModel(key);
		if (!UnityObject.exists(child))
			return null;
		return child.GetParentModelInterface();
	}
	// abstract
	function GetModel():Null<Model>
	{
		throw "abstract";
	}
	public var SortingLayer(get, set):String;
	function get_SortingLayer():String
	{
		var model = GetModel();
		if (!UnityObject.exists(model) || !Std.isOfType(model, EntityModel))
			return "";
		return (cast model:EntityModel).SortingLayerName;
	}
	function set_SortingLayer(value:String):String
	{
		var model = GetModel();
		if (!UnityObject.exists(model) || !Std.isOfType(model, EntityModel))
			return value;
		(cast model:EntityModel).SortingLayerName = value;
		return value;
	}
	public var SortingOrder(get, set):Int;
	function get_SortingOrder():Int
	{
		var model = GetModel();
		if (!UnityObject.exists(model) || !Std.isOfType(model, EntityModel))
			return 0;
		return (cast model:EntityModel).SortingOrder;
	}
	function set_SortingOrder(value:Int):Int
	{
		var model = GetModel();
		if (!UnityObject.exists(model) || !Std.isOfType(model, EntityModel))
			return value;
		(cast model:EntityModel).SortingOrder = value;
		return value;
	}
}
