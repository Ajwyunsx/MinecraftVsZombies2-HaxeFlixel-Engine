package unity;

// Minimal UnityEngine.CompositeCollider2D shim.
// PORT-NOTE: 移植层新增（Unity 物理不参与模拟，这里只保留 prefab 里保存的数据）。
class CompositeCollider2D extends Collider2D {
	public var geometryType:Int = 0;
	public var generationType:Int = 0;

	public function new() {
		super();
	}
}
