// Ported from: Assets/Scripts/Engine/Level/Models/IShaderInterface.cs
package pvzengine.models;

import unity.Color;
import unity.Vector4;

interface IShaderInterface
{
	public function SetShaderInt(name:String, value:Int):Void;
	public function SetShaderFloat(name:String, value:Float):Void;
	public function SetShaderColor(name:String, value:Color):Void;
	public function SetShaderVector(name:String, value:Vector4):Void;
	public function ApplyShaderProperties():Void;
}
