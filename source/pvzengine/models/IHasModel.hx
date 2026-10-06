// Ported from: Assets/Scripts/Engine/Level/Models/IHasModel.cs
package pvzengine.models;

// PORT-NOTE: C# 扩展方法 HasModelExt 的各个方法既需要以静态形式调用，
//   也被既有调用点以实例形式调用（entity.SetModelProperty(...)、armor.TriggerModel(...)）；
//   这里通过 `@:using(pvzengine.models.HasModelExt)` 提供实例调用形式，
//   与 mvz2/gamecontent/armors/UmbrellaShield.hx 等既有写法一致。
@:using(pvzengine.models.HasModelExt)
interface IHasModel
{
	public function GetModelInterface():Null<IModelInterface>;
}
