// Ported from: UnityEngine.AddressableAssets.ResourceLocators.ContentCatalogData（IResourceLocator 的移植层实现）
package unity.addressableassets;

/**
 * `Addressables.InitializeAsync()` 返回的 IResourceLocator。
 *
 * C# 里它由 content catalog 生成，`Locate(key, type, out locations)` 支持地址与标签两种 key；
 * 移植层由 unity.addressableassets.ResourceManifest（resource_manifest.json）实现同样的查询。
 */
class ManifestResourceLocator implements IResourceLocator {
    // C#: string LocatorId { get; }
    public var LocatorId:String;
    // C#: IEnumerable<object> Keys { get; }（清单里的全部地址，构造时快照）
    public var Keys:Array<Dynamic>;
    public var manifest(default, null):ResourceManifest;

    public function new(manifest:ResourceManifest) {
        this.manifest = manifest;
        this.LocatorId = "HaxeResourceManifest";
        this.Keys = [];
        refreshKeys();
    }

    public function refreshKeys():Void {
        Keys = [];
        if (manifest != null)
            manifest.addKeysTo(Keys);
    }

    // C#: bool Locate(object key, Type type, out IList<IResourceLocation> locations)
    public function Locate(key:String, type:Dynamic):Array<IResourceLocation> {
        if (manifest == null)
            return [];
        return manifest.locate(key, type);
    }
}
