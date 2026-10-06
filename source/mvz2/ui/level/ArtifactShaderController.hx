// Ported from: Assets/Scripts/View/Level/Artifact/ArtifactShaderController.cs
package mvz2.ui.level;

import unity.Material;
import unity.UnityObject;
import unity.ui.Graphic;
import unity.ui.IMaterialModifier;
import unity.ui.UIBehaviour;

// @:ExecuteAlways
// @:RequireComponent(RectTransform)
// @:DisallowMultipleComponent
class ArtifactShaderController extends UIBehaviour implements IMaterialModifier
{
	override public function OnDisable():Void
	{
		super.OnDisable();
		if (material != null)
		{
			// PORT-NOTE: Unity 的 DestroyImmediate 在移植层直接丢弃引用。
			material = null;
		}
	}
	private function Update():Void
	{
		if (!UnityObject.exists(material))
			return;
		material.SetFloat("_Grayscale", grayscale);
		material.SetFloat("_Brighten", brighten);
	}
	public function GetModifiedMaterial(baseMaterial:Material):Material
	{
		if (!IsActive() || !UnityObject.exists(graphic))
			return baseMaterial;

		if (!UnityObject.exists(material))
		{
			material = UnityObject.Instantiate(baseMaterial);
			material.SetFloat("_Grayscale", grayscale);
			material.SetFloat("_Brighten", brighten);
		}
		return material;
	}
	public var graphic:Null<Graphic>;
	// [Range(0, 1)]
	public var grayscale:Float;
	// [Range(0, 1)]
	public var brighten:Float;
	private var material:Null<Material>;
}
