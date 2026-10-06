// Ported from: Assets/Scripts/Engine/Level/Entities/EngineEntityExt.cs (enum FactionTarget)
// PORT-NOTE: C# 中本枚举定义在 EngineEntityExt.cs 内；Haxe 既有调用点以
// `import pvzengine.collisions.FactionTarget;` 引用（详见 pvzengine/collisions/FactionTarget.hx 别名），
// 故拆成独立模块以便两种 import 路径都能解析。
package pvzengine.entities;

enum abstract FactionTarget(Int)
{
	var Any = 0;
	var Friendly = 1;
	var Hostile = 2;
}
