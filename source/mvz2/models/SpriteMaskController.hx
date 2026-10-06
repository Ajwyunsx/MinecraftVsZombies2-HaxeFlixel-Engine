// Ported from: Assets/Scripts/View/Models/Elements/SpriteMaskController.cs
package mvz2.models;

import unity.Material;
import unity.SpriteMask;

class SpriteMaskController extends unity.MonoBehaviour
{
	function Awake():Void
	{
		spriteMask.materials = replacementMaterials;
	}
	@:serializeField
	private var spriteMask:SpriteMask;
	@:serializeField
	private var replacementMaterials:Array<Material>;
}
