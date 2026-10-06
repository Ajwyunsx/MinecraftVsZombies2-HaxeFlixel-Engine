// Ported from: Assets/Scripts/View/Models/Light/LightController.cs
package mvz2.models;

import unity.Color;
import unity.Random;
import unity.SpriteRenderer;
import unity.Vector2;
import unity.Vector3;

class LightController extends unity.MonoBehaviour
{
	public function SetRange(scale:Vector2):Void
	{
		this.scale = scale;
		transform.localScale = new Vector3(scale.x, scale.y);
	}
	public function SetColor(color:Color):Void
	{
		this.color = color;
		// PORT-NOTE: `lightRenderer` 是 [SerializeField]，由模型 prefab（`Prefabs/Level/Light.prefab`
		// 等）注入。数据缺失时 C# 的 `lightRenderer.color = ...` 同样会空引用，但移植层 release
		// 无空指针检查会**直接段错误**，所以这里补一层兜底：优先从同一 GameObject 上取 SpriteRenderer。
		// TODO-PORT: 兜底只在 prefab 数据缺失时生效，`LightController` 的 lightRenderer 应改由
		// prefab 注入（模型 prefab 转换已覆盖 Light.prefab，见 scene_prefabs/Prefabs/Level/Light.json）。
		// prefab 里 lightRenderer 指向**子节点**上的 SpriteRenderer（`Light/Light`），所以向下找。
		if (lightRenderer == null && gameObject != null)
			lightRenderer = gameObject.GetComponentInChildren(SpriteRenderer, true);
		if (lightRenderer != null)
			lightRenderer.color = color;
	}
	function Update():Void
	{
		UpdateLight();
	}
	function UpdateLight():Void
	{
		var randomLightScale = 1 + Random.Range(-shakeRange, shakeRange);
		if (lightRenderer != null && lightRenderer.transform != null)
			lightRenderer.transform.localScale = new Vector3(randomLightScale, randomLightScale);
	}
	public function ToSerializable():SerializableLightController
	{
		var serializable = new SerializableLightController();
		serializable.scale = scale;
		serializable.color = color;
		return serializable;
	}
	public function LoadFromSerializable(serializable:SerializableLightController):Void
	{
		if (serializable == null)
			return;
		SetRange(serializable.scale);
		SetColor(serializable.color);
	}
	@:serializeField
	private var lightRenderer:SpriteRenderer;
	@:serializeField
	private var shakeRange:Float = 0.05;
	private var scale:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	private var color:Color = new Color(0, 0, 0, 0); // PORT-NOTE: C# Color 为 struct，default 为 (0,0,0,0) 透明黑；显式初始化避免 abstract-over-class 的 null 解引用
}
