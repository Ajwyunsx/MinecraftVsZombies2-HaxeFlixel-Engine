// 集成验证探针：复现 ResourceManager.LoadModModels 的崩溃机制。
//
// 疑点：ResourceManager.hx:1355 `LoadLabeledResources(GameObject, nsp, "Model", progress)`
// 里的 GameObject 只是**类型参数**；ResourceManifest.doLoad 对 KIND_MODEL 走 default 分支
// 返回 haxe.io.Bytes（见 unity/addressableassets/ResourceManifest.hx:485~490），
// 于是 ResourceManager.hx:1359 `pair.resource.GetComponent(Model)` 在 cpp 上把 Bytes 当
// GameObject 解引用 → 空引用/访问违例。
//
// 运行：haxe -cp source -cp tools_build/verify_integration -lib ... -main ModelLoadProbe --interp
import unity.GameObject;
import unity.addressableassets.ResourceManifest;

class ModelLoadProbe {
	static function main() {
		var manifest = ResourceManifest.get();
		trace('manifest=' + (manifest != null));
		var locs = manifest.locate("Model", GameObject);
		trace('locate("Model", GameObject) -> ${locs.length} 条定位符');
		var shown = 0;
		for (loc in locs) {
			var rl:unity.addressableassets.ResourceLocation = cast loc;
			var asset = manifest.load(rl);
			trace('  loc=${rl.PrimaryKey} kind=${rl.Kind} asset=${asset == null ? "null" : Type.getClassName(Type.getClass(asset))}'
				+ ' isGameObject=${Std.isOfType(asset, GameObject)}');
			shown++;
			if (shown >= 5)
				break;
		}
	}
}
