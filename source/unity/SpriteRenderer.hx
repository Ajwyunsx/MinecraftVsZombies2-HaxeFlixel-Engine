package unity;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import mvz2.sprites.SpriteFrameFactory;

// Minimal UnityEngine.SpriteRenderer shim, backed by flixel.FlxSprite.
// PORT-NOTE: 移植层同时存在两种 Sprite 表示：
//   * `sprite`  —— 逻辑层写进去的**资源对象**。C# 里是 UnityEngine.Sprite；
//                  移植层为了兼容既有的 `ModelPrefabAssets`（它直接写 flixel.FlxSprite），
//                  类型放宽成 Dynamic，两种都可以放。
//   * `renderSprite` —— 真正进 Flixel 显示列表的渲染对象（由精灵工作包的
//                  `SpriteFrameFactory` 按 `sprite` 生成，见 mvz2/sprites/SpriteFrameFactory.hx）。
// `sprite` 被赋值时会触发 `spriteApplier`（钩子，由 SpriteFrameFactory.install() 安装），
// 把 unity.Sprite 转成带正确帧的 FlxSprite；不装钩子时保持纯逻辑行为（不渲染）。
class SpriteRenderer extends Component {
	public var enabled:Bool = true;
	public var sortingOrder:Int = 0;
	public var sortingLayerName:String = "Default";
	// PORT-NOTE: Unity 的 SpriteRenderer 同时有 sortingLayerName 与 sortingLayerID（层哈希）。
	// prefab 的导出数据里只有 `sortingLayerID`（Unity 序列化的就是它），原先 shim 缺该字段，
	// `ScenePrefabFieldApplier` 会把它判成"类型不符"跳过（见 missingFields），
	// 导致渲染层拿不到排序层信息（Mainmenu 的 WindowView 排序层 -10 会被当成 0）。
	// 这里补上，供渲染层排序使用；sortingLayerName 仍是名称侧的唯一来源。
	public var sortingLayerID:Int = 0;

	public var color(get, set):Color;
	// C# 的 SpriteRenderer.size（DrawMode.Tiled/Sliced 下的绘制尺寸）。
	public var size:Vector2 = new Vector2(1, 1);
	public var flipX(get, set):Bool;
	public var flipY(get, set):Bool;
	public var alpha(get, set):Float;
	public var visible(get, set):Bool;

	// PORT-NOTE: 精灵赋值钩子（签名见 SpriteRenderer.SpriteApplier）。
	// shim 只声明钩子字段，具体实现由 mvz2.sprites.SpriteFrameFactory 提供并安装。
	public static var spriteApplier:SpriteApplier = null;

	// PORT-NOTE: 移植层扩展。渲染对象（FlxSprite）。未接线时可能为 null。
	public var renderSprite:FlxSprite = null;

	// C#: public Sprite sprite { get; set; }
	public var sprite(get, set):Dynamic;
	private var _sprite:Dynamic = null;
	function get_sprite():Dynamic return _sprite;
	function set_sprite(value:Dynamic):Dynamic {
		_sprite = value;
		if (spriteApplier != null)
			spriteApplier(this);
		return value;
	}

	public function new(?sprite:Dynamic) {
		super();
		// PORT-NOTE: 传入 flixel.FlxSprite 时它就是渲染对象（兼容既有构造点），
		// 传入 unity.Sprite（或 null）时渲染对象在钩子里惰性创建。
		if (Std.isOfType(sprite, FlxSprite))
			renderSprite = cast sprite;
		// 直接写字段，避免走 setter 触发钩子（构造期组件还没挂到 GameObject 上）。
		_sprite = sprite;
		// PORT-NOTE: 显式引用 SpriteFrameFactory 有双重作用：
		//   1. 构造渲染器时自动安装精灵钩子（幂等），调用点不必额外初始化；
		//   2. 让 unity 包对 mvz2.sprites 形成静态引用，避免 DCE 把精灵接线整包删掉
		//      （Project.xml 不允许加 --macro keep，见 PORTING.md）。
		SpriteFrameFactory.install();
	}

	// C#: public void GetPropertyBlock(MaterialPropertyBlock properties)
	// PORT-NOTE: Unity 的 MaterialPropertyBlock 是每个渲染器上的一份覆盖参数；
	// 移植层把这份数据直接挂在 SpriteRenderer 上，Get 时拷出、Set 时拷入，语义与原调用点一致。
	public function GetPropertyBlock(properties:MaterialPropertyBlock):Void {
		if (properties != null) properties.CopyFrom(_propertyBlock);
	}
	// C#: public void SetPropertyBlock(MaterialPropertyBlock properties)
	public function SetPropertyBlock(properties:MaterialPropertyBlock):Void {
		if (properties != null) _propertyBlock.CopyFrom(properties);
	}
	private var _propertyBlock:MaterialPropertyBlock = new MaterialPropertyBlock();

	// PORT-NOTE: 渲染侧访问器统一走 renderSprite；`sprite` 仍是未转换的 unity.Sprite 时返回 null。
	function currentSprite():FlxSprite {
		if (renderSprite != null)
			return renderSprite;
		return Std.isOfType(_sprite, FlxSprite) ? cast _sprite : null;
	}

	inline function get_flipX():Bool {
		var s = currentSprite();
		return s != null ? s.flipX : false;
	}
	inline function set_flipX(v:Bool):Bool {
		var s = currentSprite();
		if (s != null) s.flipX = v;
		return v;
	}
	inline function get_flipY():Bool {
		var s = currentSprite();
		return s != null ? s.flipY : false;
	}
	inline function set_flipY(v:Bool):Bool {
		var s = currentSprite();
		if (s != null) s.flipY = v;
		return v;
	}
	inline function get_alpha():Float {
		var s = currentSprite();
		return s != null ? s.alpha : 1;
	}
	inline function set_alpha(v:Float):Float {
		var s = currentSprite();
		if (s != null) s.alpha = v;
		return v;
	}
	inline function get_visible():Bool {
		var s = currentSprite();
		return s != null ? s.visible : false;
	}
	inline function set_visible(v:Bool):Bool {
		var s = currentSprite();
		if (s != null) s.visible = v;
		return v;
	}

	function get_color():Color {
		var s = currentSprite();
		if (s == null)
			return new Color(1, 1, 1, 1);
		var argb:Int = s.color;
		return new Color(((argb >> 16) & 0xFF) / 255, ((argb >> 8) & 0xFF) / 255, (argb & 0xFF) / 255, ((argb >> 24) & 0xFF) / 255);
	}
	function set_color(v:Color):Color {
		var s = currentSprite();
		if (s != null)
			s.color = FlxColor.fromRGBFloat(v.r, v.g, v.b, v.a);
		return v;
	}
}

// PORT-NOTE: 渲染钩子签名。放在模块底部（Haxe 允许一个模块多类型），
// 避免 unity 包引入对 mvz2 包的依赖。
typedef SpriteApplier = SpriteRenderer->Bool;
