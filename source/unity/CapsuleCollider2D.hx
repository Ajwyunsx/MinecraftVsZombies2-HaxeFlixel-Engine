package unity;

// Minimal UnityEngine.CapsuleCollider2D shim.
// PORT-NOTE: 移植层新增（模型 prefab 里会出现 CapsuleCollider2D，见 units/colliders/*.prefab）。
class CapsuleCollider2D extends Collider2D {
	public var size:Vector2 = new Vector2(1, 1);
	public var direction:Int = 0;

	public function new() {
		super();
	}
}
