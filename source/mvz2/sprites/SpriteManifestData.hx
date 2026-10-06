package mvz2.sprites;

import unity.Rect;
import unity.Vector2;

// PORT-NOTE: 移植层新增的数据结构，对应原工程里 Unity SpriteManifest 资产中序列化的
// Sprite / Sprite[] 引用（C# 里是 UnityEngine.Sprite，带 rect/pivot/pixelsPerUnit/texture）。
// 这里的字段与 tools_build/convert_sprites.py 输出的 assets/sprites_manifest.json 一一对应，
// 由 SpriteManifestLoader 在运行期解析。
//
// 坐标系约定：rect 为贴图内的像素矩形，pivot 为 0..1 归一化值，二者都用 Unity 坐标系
// （原点在贴图左下角，y 轴向上）。转成 BitmapData/Flixel 的左上角坐标由 SpriteTextureCache 负责。

/// 一张贴图（Unity Texture2D + TextureImporter 设置）的导入结果。
class SpriteTextureDefinition {
    public var guid:String;
    /// 相对仓库根的路径，如 Assets/GameContent/Assets/mvz2/sprites/xxx.png。
    public var unityPath:String;
    /// 相对 HaxePort/assets/ 的路径，如 GameContent/Assets/mvz2/sprites/xxx.png。
    public var assetPath:String;
    public var width:Int = 0;
    public var height:Int = 0;
    /// Unity TextureImporter.spriteMode：1=Single，2=Multiple。
    public var spriteMode:Int = 1;
    public var pixelsPerUnit:Float = 100;
    /// Unity TextureImporter.alignment（0=Center … 8=BottomRight，9=Custom）。
    public var alignment:Int = 0;
    /// Unity 实际生效的 pivot（alignment != 9 时由 alignment 推导）。
    public var pivot:Vector2 = new Vector2(0.5, 0.5);
    /// .meta 中序列化的 spritePivot 原值。
    public var pivotRaw:Vector2 = new Vector2(0.5, 0.5);
    /// spriteMode=2 时贴图内所有切片（即 Unity 里同一个贴图的全部 Sprite 子资源）。
    public var slices:Array<SpriteSliceDefinition> = [];

    public function new() {}

    public function findSliceByInternalID(internalID:String):SpriteSliceDefinition {
        return Lambda.find(slices, s -> s.internalIDString == internalID);
    }
}

/// 多帧贴图（spriteMode=2）中的一个切片，等价于 Unity 的一个 Sprite 子资源。
class SpriteSliceDefinition {
    /// Unity 里 Sprite 的名字（如 eirin_0）。
    public var name:String;
    public var rect:Rect = new Rect();
    public var pivot:Vector2 = new Vector2(0.5, 0.5);
    public var pivotRaw:Vector2 = new Vector2(0.5, 0.5);
    public var alignment:Int = 0;
    public var pixelsPerUnit:Float = 100;
    /// Unity 的 spriteID（32 位十六进制 GUID 字符串）。
    public var spriteID:String;
    /// Unity 的 internalID（序列化引用里的 fileID）。可能超出 32 位，故用字符串保存。
    public var internalIDString:String;

    public function new() {}
}

/// 单帧精灵，等价于原工程 SpriteManifest.spriteEntries 的一项。
class SpriteDefinition {
    /// 完整 ID，如 mvz2:level/palace/palace。
    public var id:String;
    public var namespace:String;
    /// NamespaceID.Path，也是 ModResource.Sprites 的键。
    public var path:String;
    /// Unity 里 Sprite 资产的名字（单帧精灵为贴图文件名）。
    public var name:String;
    public var textureGuid:String;
    public var rect:Rect = new Rect();
    public var pivot:Vector2 = new Vector2(0.5, 0.5);
    public var pivotRaw:Vector2 = new Vector2(0.5, 0.5);
    public var alignment:Int = 0;
    public var pixelsPerUnit:Float = 100;
    /// Addressables 分组名（main / init / ...）。
    public var group:String;
    /// Addressables 标签（Sprite / Main / Init / ...）。
    public var labels:Array<String> = [];
    /// 所在的 SpriteManifest 资产地址（等价于 C# LoadLabeledResources<SpriteManifest> 的定位结果）。
    public var manifest:String;
    /// 所在 SpriteManifest 资产的标签，如 ["Init","SpriteManifest"]，用于按加载阶段过滤。
    public var manifestLabels:Array<String> = [];
    /// 所属 spriteatlasv2 图集名。
    public var atlases:Array<String> = [];
    /// 数据来源（addressable / manifest），仅用于追踪。
    public var sources:Array<String> = [];
    /// 解析后的贴图定义（load 时填充）。
    public var texture:SpriteTextureDefinition;
    /// 贴图在 HaxePort/assets/ 下的路径。优先取自工作包 ① 的 assets/resource_manifest.json
    /// （按本精灵的地址查询），取不到时回退为 texture.assetPath。
    public var assetPath:String;

    public function new() {}
}

/// 多帧精灵，等价于原工程 SpriteManifest.spritesheetEntries 的一项（Sprite[]）。
class SpriteSheetDefinition {
    public var id:String;
    public var namespace:String;
    public var path:String;
    public var name:String;
    public var textureGuid:String;
    public var group:String;
    public var labels:Array<String> = [];
    public var manifest:String;
    public var manifestLabels:Array<String> = [];
    public var atlases:Array<String> = [];
    public var sources:Array<String> = [];
    /// 整张贴图的 pivot（把贴图当单帧用时的兜底值）。
    public var texturePivot:Vector2 = new Vector2(0.5, 0.5);
    public var textureAlignment:Int = 0;
    /// "manifest"（帧顺序来自 SpriteManifest 的有序引用）或 "meta"（来自贴图 .meta）。
    public var sliceOrder:String = "meta";
    /// 帧列表，顺序与 C# 中 GetOrderedSpriteSheet 的结果一致。
    public var slices:Array<SpriteSliceDefinition> = [];
    public var texture:SpriteTextureDefinition;
    /// 贴图在 HaxePort/assets/ 下的路径（见 SpriteDefinition.assetPath）。
    public var assetPath:String;

    public function new() {}
}

/// spriteatlasv2 图集定义（packables 为打包文件夹）。
class SpriteAtlasDefinition {
    public var name:String;
    public var assetPath:String;
    public var packableFolders:Array<String> = [];
    public var sprites:Array<String> = [];
    public var spriteSheets:Array<String> = [];
    public var unresolvedPackables:Array<String> = [];

    public function new() {}
}

// Ported from: Assets/Scripts/MVZ2/Sprites/SpriteManifest.cs（数据等价物）
// PORT-NOTE: 原工程的 SpriteManifest 是 ScriptableObject 资产，由 Addressables 加载；
// 移植层把这些资产在构建期合并成一份 sprites_manifest.json，运行期解析成本类型。
class SpriteManifestData {
    public var formatVersion:Int = 1;
    public var generatedAt:String;
    public var sourceProject:String;
    public var assetRoot:String;
    public var namespace:String;
    public var textures:Map<String, SpriteTextureDefinition> = new Map();
    /// 键为不带命名空间的 path（与 ModResource.Sprites 一致）。
    public var sprites:Map<String, SpriteDefinition> = new Map();
    public var spriteSheets:Map<String, SpriteSheetDefinition> = new Map();
    public var atlases:Map<String, SpriteAtlasDefinition> = new Map();
    public var warnings:Array<String> = [];
    /// 是否成功接入了工作包 ① 的资产清单（assets/resource_manifest.json）。
    public var resourceManifestLoaded:Bool = false;
    /// 从 ① 的清单里解析到贴图路径的条目数。
    public var resourceManifestResolved:Int = 0;
    /// ① 的清单里没有对应地址、只能用本清单 assetPath 回退的条目数。
    public var resourceManifestFallbacks:Array<String> = [];
    /// ① 的清单与本清单路径不一致的地址（诊断用）。
    public var resourceManifestMismatches:Array<String> = [];

    public function new() {}
}
