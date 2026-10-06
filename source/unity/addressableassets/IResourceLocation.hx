// Ported from: UnityEngine.AddressableAssets.ResourceLocators.IResourceLocation (minimal shim)
package unity.addressableassets;

// PORT-NOTE: Unity 的 IResourceLocation 描述一条可寻址资源。移植层不实现 Addressables 目录，
// 资源改由 unity.addressableassets.Addressables 的进程内注册表按 PrimaryKey 解析
// （见 mvz2.managers.ResourceManager）。本接口只保留调用点真正读取的成员，
// 字段名与 Unity 保持一致；ResourceManager 目前以 Dynamic 持有定位符，补齐本接口后可逐处收紧类型。
interface IResourceLocation {
    // C#: string PrimaryKey { get; }
    public var PrimaryKey:String;
    // C#: string InternalId { get; }
    public var InternalId:String;
    // C#: string ProviderId { get; }
    public var ProviderId:String;
    // C#: Type ResourceType { get; } —— Haxe 无运行期 Type 对象，改为类型全名（与 C# `GetType().FullName` 对应）。
    public var ResourceTypeName:String;
    // C#: Type ResourceType { get; } —— PORT-NOTE: ResourceManager 的定位符去重（addUniqueLocation /
    // containsLocation）读的是 `l.ResourceType`，为让接口类型也能直接读取，这里保留同名成员（值为类型全名）。
    public var ResourceType:Dynamic;
    // C#: object Data { get; }
    public var Data:Dynamic;
    // C#: IList<IResourceLocation> Dependencies { get; }
    public var Dependencies:Array<IResourceLocation>;
    // C#: bool HasDependencies { get; }
    public var HasDependencies:Bool;
}
