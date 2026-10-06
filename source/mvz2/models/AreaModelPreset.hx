// Ported from: Assets/Scripts/View/Models/Area/AreaModelPreset.cs
package mvz2.models;

class AreaModelPreset extends unity.MonoBehaviour
{
	public function SetActive(visible:Bool):Void
	{
		gameObject.SetActive(visible);
	}
	public function GetName():String
	{
		return presetName;
	}
	@:serializeField
	private var presetName:String = "default";
}
