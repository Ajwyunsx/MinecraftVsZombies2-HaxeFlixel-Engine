// Ported from: UnityEngine.ResourceManagement.ResourceLocations.ResourceLocation (minimal shim)
package unity.addressableassets;

// PORT-NOTE: Unity 的 ResourceLocation 由 Addressables 目录（catalog）在运行期生成，字段不可变。
// 移植层没有 catalog：定位符由 HaxePort/assets/resource_manifest.json 的每条记录构造
// （见 unity.addressableassets.ResourceManifest），因此这里是一个纯数据载体。
//
// 字段与 Unity 的对应关系：
//   PrimaryKey       —— Addressables 的 address（mvz2:init/titlescreen / Assets/... / builtin）
//   InternalId       —— Unity 里是 provider 定位资源用的 id（本地文件路径或 bundle 内路径）；
//                       移植层直接给出资源在磁盘上的路径（相对 assets 根），ProviderId 标为 "HaxeFileProvider"。
//   ResourceTypeName —— C# 的 `ResourceType.FullName`（UnityEngine.Sprite / UnityEngine.AudioClip ...）。
//   ResourceType     —— C# 的 `Type ResourceType`；Haxe 无运行期 Type 对象，统一放字符串名字。
//                       ResourceManager 的去重比较（addUniqueLocation / containsLocation）读的是这个字段。
class ResourceLocation implements IResourceLocation {
    // C#: string PrimaryKey { get; }
    public var PrimaryKey:String;
    // C#: string InternalId { get; }
    public var InternalId:String;
    // C#: string ProviderId { get; }
    public var ProviderId:String;
    // C#: Type ResourceType { get; }（此处为类型全名）
    public var ResourceTypeName:String;
    // C#: object Data { get; }
    public var Data:Dynamic;
    // C#: IList<IResourceLocation> Dependencies { get; }
    public var Dependencies:Array<IResourceLocation>;
    // C#: bool HasDependencies { get; }
    public var HasDependencies:Bool;

    // PORT-NOTE: 以下为移植层补充字段，供 ResourceManager 的去重比较与 ResourceManifest 的加载使用。
    // ResourceManager.addUniqueLocation/containsLocation 以 `l.ResourceType`（Dynamic 访问）做比较，
    // 与 ResourceTypeName 同值。
    public var ResourceType:Dynamic;
    // 该条目的 Addressables 标签（Init/Main/Sprite/Sound/...）。
    public var Labels:Array<String>;
    // 条目所属的 Addressables 组（main/builtin/init/language_packs）。
    public var Group:String;
    // 源资源的 GUID。
    public var Guid:String;
    // 资源路径，相对 assets 根（即 resource_manifest.json 里的 path）。
    public var Path:String;
    // 清单里声明的资源类型（扩展名或 Unity 类型名，可能为 null）。
    public var Type:String;
    // 加载分派所用的类别：Image / Audio / Text / Model / Font / Other。
    public var Kind:String;
    // 该资源在镜像里是否真的存在（清单里的 exists / missing）。
    public var Exists:Bool = true;

    public function new(PrimaryKey:String, ?Path:String, ?Type:String, ?Kind:String, ?ResourceTypeName:String) {
        this.PrimaryKey = PrimaryKey;
        this.Path = Path;
        this.Type = Type;
        this.Kind = Kind;
        this.InternalId = Path;
        this.ProviderId = "HaxeFileProvider";
        this.ResourceTypeName = ResourceTypeName;
        this.ResourceType = ResourceTypeName;
        this.Data = null;
        this.Dependencies = [];
        this.HasDependencies = false;
        this.Labels = [];
    }

    // C#: ResourceLocation.ToString() → PrimaryKey
    public function toString():String {
        return PrimaryKey;
    }

    // PORT-NOTE: ResourceManager 把定位符按 Dynamic 持有并用 `l.PrimaryKey == loc.PrimaryKey &&
    // l.ResourceType == loc.ResourceType && l.InternalId == loc.InternalId` 去重，
    // 这三个字段在上面都可直接读取，无需额外实现。
}
