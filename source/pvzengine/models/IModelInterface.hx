// Ported from: Assets/Scripts/Engine/Level/Models/IModelInterface.cs
package pvzengine.models;

import pvzengine.NamespaceID;

interface IModelInterface extends IShaderInterface
{
	public function UpdateModel():Void;
	public function TriggerAnimation(name:String):Void;
	public function SetAnimationBool(name:String, value:Bool):Void;
	public function SetAnimationInt(name:String, value:Int):Void;
	public function SetAnimationFloat(name:String, value:Float):Void;
	public function GetAnimatorInterface(name:String):Null<IAnimatorInterface>;
	public function SetModelProperty(name:String, value:Dynamic):Void;
	public function TriggerModel(name:String):Void;
	public var SortingLayer(get, set):String;
	public var SortingOrder(get, set):Int;
	public function CreateChildModel(anchor:String, key:NamespaceID, modelID:NamespaceID):Null<IModelInterface>;
	public function RemoveChildModel(key:NamespaceID):Bool;
	public function GetChildModel(key:NamespaceID):Null<IModelInterface>;
}
