// Ported from: Assets/Scripts/Engine/Base/Interfaces/IGameContent.cs
package pvzengine;

import pvzengine.base.Definition;

// PORT-NOTE: C# 的
//   T? GetDefinition<T>(string type, NamespaceID? defRef) where T : Definition
//   T[] GetDefinitions<T>(string type) where T : Definition
//   Definition[] GetDefinitions()
// 在 Haxe 中无法用同名重载表达，且调用点书写了显式类型实参（`provider.GetDefinition(HeldItemDefinition, ...)`）。
// 按工程既有约定（同 unity.GameObject.GetComponent）改为传入类型对象：
//   * GetDefinition<T>(cl, type, defRef)
//   * GetDefinitions<T>(cl, type)
//   * 无参数的 GetDefinitions() 与上面的二元形式无法同名共存，改名为 GetDefinitionsAll()
//     （GlobalGame 已经实现了该方法，见 mvz2/globalgames/GlobalGame.hx）。
// PORT-NOTE: C# 中 ContentProviderHelper 的扩展方法（GetStageDefinition / GetBuffDefinition /
//   GetAllGridDefinitions ...）依赖 `using PVZEngine` 才能以实例形式调用；大量既有调用点写作
//   `level.Content.GetBuffDefinition(id)`、`game.GetAllStageDefinitions()`。这里按工程既有约定
//   （同 IHasModel、LevelEngine）在接口上标注 @:using，使实例调用形式与 C# 一致。
@:using(pvzengine.ContentProviderHelper)
interface IGameContent
{
    public function GetDefinition<T:Definition>(cl:Class<T>, type:String, defRef:Null<NamespaceID>):Null<T>;
    public function GetDefinitions<T:Definition>(cl:Class<T>, type:String):Array<T>;
    public function GetDefinitionsAll():Array<Definition>;
}
