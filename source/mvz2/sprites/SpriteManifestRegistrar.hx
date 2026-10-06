package mvz2.sprites;

import mvz2.modding.ModResource;

// PORT-NOTE: 移植层新增。原工程里精灵/图集是按 Addressables 标签分别加载进
// ModResource.Sprites / ModResource.SpriteSheets 的（见 ResourceManager_Sprites.cs）；
// 移植层由 SpriteManifestLoader 读预生成的 assets/sprites_manifest.json，
// 本类负责把它接进运行期资源表（与 ResourceManager 的 LoadSpriteManifest 结果一致）。
//
// 与 SpriteManifestLoader 分开的原因：Loader 只做数据（不依赖 mvz2.modding），
// 便于单独运行/测试；这里做集成。
class SpriteManifestRegistrar {
    private function new() {}

    /// 把清单里的全部精灵/图集写入 ModResource（等价于 C# LoadSpriteManifest +
    /// LoadSprites + LoadSpriteSheets 三者结果之和）。
    public static function populateModResource(modResource:ModResource):Void {
        if (modResource == null)
            return;
        if (!SpriteManifestLoader.isLoaded && !SpriteManifestLoader.load())
            return;
        for (s in SpriteManifestLoader.getSpriteDefinitions()) {
            if (s.namespace != modResource.Namespace)
                continue;
            var sprite = SpriteManifestLoader.createSprite(s);
            modResource.Sprites.set(s.path, sprite);
            // PORT-NOTE: 与 ResourceManager.LoadSpriteManifest 一致，同时登记
            // Sprite -> SpriteReference 的反查缓存由 ResourceManager 负责（此处无法访问其私有表）。
        }
        for (sheet in SpriteManifestLoader.getSpriteSheetDefinitions()) {
            if (sheet.namespace != modResource.Namespace)
                continue;
            modResource.SpriteSheets.set(sheet.path, SpriteManifestLoader.createSpriteSheet(sheet));
        }
    }

    /// 把精灵注册进 unity.addressableassets.Addressables 的进程内注册表，
    /// 使 ResourceManager 现有的 Addressables 取值路径可以命中（键为 mvz2:xxx）。
    public static function registerAddressables():Void {
        if (!SpriteManifestLoader.isLoaded && !SpriteManifestLoader.load())
            return;
        for (s in SpriteManifestLoader.getSpriteDefinitions()) {
            unity.addressableassets.Addressables.RegisterAsset(s.id, SpriteManifestLoader.createSprite(s));
        }
        for (sheet in SpriteManifestLoader.getSpriteSheetDefinitions()) {
            unity.addressableassets.Addressables.RegisterAsset(sheet.id, SpriteManifestLoader.createSpriteSheet(sheet));
        }
    }
}
