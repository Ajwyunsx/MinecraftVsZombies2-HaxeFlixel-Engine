// Ported from: Assets/Scripts/Engine/Level/Models/IAnimatorInterface.cs
package pvzengine.models;

interface IAnimatorInterface
{
	public function SetTrigger(name:String):Void;
	public function SetBool(name:String, value:Bool):Void;
	public function SetInt(name:String, value:Int):Void;
	public function SetFloat(name:String, value:Float):Void;
	public function GetLayerWeight(name:String):Float;
	public function SetLayerWeight(name:String, value:Float):Void;
}
