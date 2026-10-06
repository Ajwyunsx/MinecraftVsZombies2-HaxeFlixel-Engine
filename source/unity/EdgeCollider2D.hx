package unity;

// Minimal UnityEngine.EdgeCollider2D shim.
// PORT-NOTE: 移植层新增（Unity 物理不参与模拟，这里只保留 prefab 里保存的数据）。
class EdgeCollider2D extends Collider2D {
	public var points:Array<Vector2> = [];
	public var edgeRadius:Float = 0;

	public function new() {
		super();
	}
}
