// Ported from: Assets/Scripts/View/Models/IModelComponent.cs
package mvz2.models;
import mvz2.models.Model.SerializableModelData;  // IMPORTAUTO

interface IModelComponent
{
	function Init():Void;
	function SaveToSerializable(serializable:SerializableModelData):Void;
	function LoadFromSerializable(serializable:SerializableModelData):Void;
	function SetModel(model:Model):Void;
	function UpdateLogic():Void;
	function UpdateFrame(deltaTime:Float):Void;
	function OnPropertySet(name:String, value:Dynamic):Void;
	function OnTrigger(name:String):Void;
	function IsEnabled():Bool;
}
