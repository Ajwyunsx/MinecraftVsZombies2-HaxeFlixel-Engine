// Ported from: Assets/Scripts/Engine/Level/Models/HasModelExt.cs
// PORT-NOTE: 原 C# 文件没有 namespace（位于全局命名空间）。Haxe 无法在包内直接以简单名引用
//   全局命名空间的类型，且既有调用点从不 import 本类（只通过 @:using 使用其扩展方法），
//   故放在 pvzengine.models 包下（与 IHasModel / IModelInterface 同包）。
package pvzengine.models;

import pvzengine.NamespaceID;
import unity.Color32;

// PORT-NOTE: C# 扩展方法 -> Haxe 静态工具类；实例写法（entity.SetModelProperty(...)、
//   armor.TriggerModel(...)）通过在 IHasModel 上标注 `@:using(pvzengine.models.HasModelExt)` 保留。
class HasModelExt
{
	public static function SetModelProperty(self:IHasModel, name:String, value:Dynamic):Void
	{
		var modelInterface = self.GetModelInterface();
		if (modelInterface != null)
			modelInterface.SetModelProperty(name, value);
	}
	public static function TriggerModel(self:IHasModel, name:String):Void
	{
		var modelInterface = self.GetModelInterface();
		if (modelInterface != null)
			modelInterface.TriggerModel(name);
	}
	public static function SetShaderInt(self:IHasModel, name:String, value:Int):Void
	{
		var modelInterface = self.GetModelInterface();
		if (modelInterface != null)
			modelInterface.SetShaderInt(name, value);
	}
	public static function SetShaderFloat(self:IHasModel, name:String, value:Float):Void
	{
		var modelInterface = self.GetModelInterface();
		if (modelInterface != null)
			modelInterface.SetShaderFloat(name, value);
	}
	public static function SetShaderColor(self:IHasModel, name:String, value:Color32):Void
	{
		var modelInterface = self.GetModelInterface();
		// PORT-NOTE: C# 依赖 Color32 → Color 的隐式转换；Haxe 的 unity.Color32 shim 提供 toColor()，
		//   这里显式调用（@:to 元数据在 Haxe 的 class 上不生效）。
		if (modelInterface != null)
			modelInterface.SetShaderColor(name, value.toColor());
	}
	public static function ApplyShaderProperties(self:IHasModel):Void
	{
		var modelInterface = self.GetModelInterface();
		if (modelInterface != null)
			modelInterface.ApplyShaderProperties();
	}
	public static function CreateChildModel(self:IHasModel, anchorName:String, key:NamespaceID, modelID:NamespaceID):Null<IModelInterface>
	{
		var modelInterface = self.GetModelInterface();
		return modelInterface != null ? modelInterface.CreateChildModel(anchorName, key, modelID) : null;
	}
	public static function RemoveChildModel(self:IHasModel, key:NamespaceID):Bool
	{
		var modelInterface = self.GetModelInterface();
		return modelInterface != null ? modelInterface.RemoveChildModel(key) : false;
	}
	public static function GetChildModel(self:IHasModel, key:NamespaceID):Null<IModelInterface>
	{
		var modelInterface = self.GetModelInterface();
		return modelInterface != null ? modelInterface.GetChildModel(key) : null;
	}
	public static function UpdateModel(self:IHasModel):Void
	{
		var modelInterface = self.GetModelInterface();
		if (modelInterface != null)
			modelInterface.UpdateModel();
	}
	public static function TriggerAnimation(self:IHasModel, name:String):Void
	{
		var modelInterface = self.GetModelInterface();
		if (modelInterface != null)
			modelInterface.TriggerAnimation(name);
	}
	public static function SetAnimationBool(self:IHasModel, name:String, value:Bool):Void
	{
		var modelInterface = self.GetModelInterface();
		if (modelInterface != null)
			modelInterface.SetAnimationBool(name, value);
	}
	public static function SetAnimationInt(self:IHasModel, name:String, value:Int):Void
	{
		var modelInterface = self.GetModelInterface();
		if (modelInterface != null)
			modelInterface.SetAnimationInt(name, value);
	}
	public static function SetAnimationFloat(self:IHasModel, name:String, value:Float):Void
	{
		var modelInterface = self.GetModelInterface();
		if (modelInterface != null)
			modelInterface.SetAnimationFloat(name, value);
	}
	public static function GetAnimatorInterface(self:IHasModel, name:String):Null<IAnimatorInterface>
	{
		var modelInterface = self.GetModelInterface();
		return modelInterface != null ? modelInterface.GetAnimatorInterface(name) : null;
	}
}
