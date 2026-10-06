// Ported from: UnityEngine.AddressableAssets.ResourceLocators.IResourceLocator (minimal shim)
package unity.addressableassets;

// PORT-NOTE: Unity 的 IResourceLocator 是 Addressables 目录查询接口。移植层的 MOD 资源定位符
// 暂以 Dynamic 持有（见 mvz2.modding.ModInfo.ResourceLocator），但调用点统一使用
// `locator.Locate(key, type)` 形式；这里给出该形态的接口定义。
interface IResourceLocator {
    // C#: string LocatorId { get; }
    public var LocatorId:String;
    // C#: IEnumerable<object> Keys { get; }
    public var Keys:Array<Dynamic>;
    // C#: bool Locate(object key, Type type, out IList<IResourceLocation> locations)
    // PORT-NOTE: Haxe 无 out 参数，改为返回定位结果列表（null 表示未命中），
    // 与 ResourceManager 现有 `var locs = locator.Locate(key, null);` 的用法一致。
    public function Locate(key:String, type:Dynamic):Array<IResourceLocation>;
}
