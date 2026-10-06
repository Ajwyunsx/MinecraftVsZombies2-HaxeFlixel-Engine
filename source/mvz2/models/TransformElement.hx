// Ported from: Assets/Scripts/View/Models/Elements/TransformElement.cs
package mvz2.models;

class TransformElement extends unity.MonoBehaviour
{
	public var LockToGround(get, never):Bool;
	function get_LockToGround():Bool return lockToGround;
	@:serializeField
	private var lockToGround:Bool;
}
