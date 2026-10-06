// Ported from: (新增文件) 把 prefab 里保存的组件字段写回移植层组件
package mvz2.models;

import unity.AnimationCurve;
import unity.Animator;
import unity.Component;
import mvz2.models.ModelPrefabData;
import unity.ParticleSystem;
import unity.ParticleSystem.Burst;
import unity.ParticleSystem.EmissionModule;
import unity.ParticleSystem.MainModule;
import unity.ParticleSystem.MinMaxCurve;
import unity.ParticleSystem.MinMaxGradient;
import unity.ParticleSystem.ShapeModule;
import unity.ParticleSystem.TextureSheetAnimationModule;
import unity.ParticleSystemCullingMode;
import unity.ParticleSystemCurveMode;
import unity.ParticleSystemGradientMode;
import unity.ParticleSystemRenderMode;
import unity.ParticleSystemScalingMode;
import unity.ParticleSystemShapeType;
import unity.ParticleSystemSimulationSpace;
import unity.Color;
import unity.SpriteRenderer;

// PORT-NOTE: 本文件是移植层新增的「prefab 字段写回」实现，没有 C# 对应源码。
//
// C# 侧这些值由 Unity 的序列化系统自动填充（[SerializeField]/public 字段）；
// 移植层只能逐字段写。这里分两类：
//   1. unity.* shim 组件（SpriteRenderer / Animator / ParticleSystem）：显式按 shim 的
//      字段名写入。shim 里没有的字段（渲染细节，如 m_DrawMode、m_CullMode、particle 的
//      SizeOverLifetime 等）记入 missingFields 统计后跳过，不猜。
//   2. MonoBehaviour（游戏脚本）：字段名与 C# 一致（移植规范），按名字反射写入已存在的字段，
//      值需要按 ModelPrefabContext.decode 解码（结构体/引用/资产）。
//
// 其中「模型组」的几个关键字段（modelAnchors/animators/renderers/particles/transforms/
// subSortingGroups 以及 EntityModel 的 group/bone/modelCollider/sortingGroup）在 C# 里都是
// private/protected 的 [SerializeField]，是运行期直接读取的数据（模型动画、锚点、着色器
// 属性遍历都依赖它们），因此这几个类用 @:access 走**类型化赋值**，不依赖反射对私有字段的行为。
@:access(mvz2.models.GraphicElement)
@:access(mvz2.models.ModelGroup)
@:access(mvz2.models.ModelGroupRenderer)
@:access(mvz2.models.ModelGroupEntity)
@:access(mvz2.models.EntityModel)
@:access(mvz2.models.ModelBone)
@:access(mvz2.models.TransformElement)
@:access(mvz2.models.ParticlePlayer)
class ModelPrefabFieldApplier {
	/** 按组件类型写字段。 */
	public static function Apply(comp:Component, rec:ModelPrefabComponent, ctx:ModelPrefabContext):Void {
		var fields:Dynamic = rec.fields;
		if (fields == null)
			return;
		var label = rec.script != null ? rec.script : rec.type;
		if (Std.isOfType(comp, SpriteRenderer)) {
			applySpriteRenderer(cast comp, fields, ctx, label);
		} else if (Std.isOfType(comp, Animator)) {
			applyAnimator(cast comp, fields, ctx, label);
		} else if (Std.isOfType(comp, ParticleSystem)) {
			applyParticleSystem(cast comp, fields, ctx, label);
		} else if (Std.isOfType(comp, EntityModel)) {
			applyEntityModel(cast comp, fields, ctx, label);
		} else if (Std.isOfType(comp, ModelGroupEntity)) {
			applyModelGroupEntity(cast comp, fields, ctx, label);
		} else if (Std.isOfType(comp, ModelGroupRenderer)) {
			applyModelGroupRenderer(cast comp, fields, ctx, label);
		} else if (Std.isOfType(comp, ModelGroup)) {
			applyModelGroup(cast comp, fields, ctx, label);
		} else if (Std.isOfType(comp, GraphicElement)) {
			var element:GraphicElement = cast comp;
			if (Reflect.hasField(fields, "excludedInGroup"))
				element.excludedInGroup = toBool(Reflect.field(fields, "excludedInGroup"));
			if (Reflect.hasField(fields, "enabled"))
				element.enabled = toBool(Reflect.field(fields, "enabled"));
		} else if (Std.isOfType(comp, ModelBone)) {
			var bone:ModelBone = cast comp;
			if (Reflect.hasField(fields, "lightController"))
				bone.lightController = cast ctx.decode(Reflect.field(fields, "lightController"), bone.lightController);
		} else if (Std.isOfType(comp, TransformElement)) {
			var element:TransformElement = cast comp;
			if (Reflect.hasField(fields, "lockToGround"))
				element.lockToGround = toBool(Reflect.field(fields, "lockToGround"));
		} else if (Std.isOfType(comp, ParticlePlayer)) {
			var player:ParticlePlayer = cast comp;
			if (Reflect.hasField(fields, "minAmount"))
				player.minAmount = toFloat(Reflect.field(fields, "minAmount"));
		} else {
			applyGeneric(comp, fields, ctx, label);
		}
	}

	// #region 模型组（prefab 里保存的元素列表，运行期直接使用）
	static function applyModelGroupFields(group:ModelGroup, fields:Dynamic, ctx:ModelPrefabContext, label:String):Void {
		if (Reflect.hasField(fields, "testMode"))
			group.testMode = toBool(Reflect.field(fields, "testMode"));
		if (Reflect.hasField(fields, "modelAnchors"))
			group.modelAnchors = cast ctx.decode(Reflect.field(fields, "modelAnchors"), group.modelAnchors);
		if (Reflect.hasField(fields, "animators"))
			group.animators = cast ctx.decode(Reflect.field(fields, "animators"), group.animators);
		if (Reflect.hasField(fields, "transforms"))
			group.transforms = cast ctx.decode(Reflect.field(fields, "transforms"), group.transforms);
	}

	static function applyModelGroup(group:ModelGroup, fields:Dynamic, ctx:ModelPrefabContext, label:String):Void {
		applyModelGroupFields(group, fields, ctx, label);
	}

	static function applyModelGroupRenderer(group:ModelGroupRenderer, fields:Dynamic, ctx:ModelPrefabContext, label:String):Void {
		applyModelGroupFields(group, fields, ctx, label);
		if (Reflect.hasField(fields, "renderers"))
			group.renderers = cast ctx.decode(Reflect.field(fields, "renderers"), group.renderers);
		if (Reflect.hasField(fields, "particles"))
			group.particles = cast ctx.decode(Reflect.field(fields, "particles"), group.particles);
	}

	static function applyModelGroupEntity(group:ModelGroupEntity, fields:Dynamic, ctx:ModelPrefabContext, label:String):Void {
		applyModelGroupRenderer(group, fields, ctx, label);
		if (Reflect.hasField(fields, "subSortingGroups"))
			group.subSortingGroups = cast ctx.decode(Reflect.field(fields, "subSortingGroups"), group.subSortingGroups);
	}

	static function applyEntityModel(model:EntityModel, fields:Dynamic, ctx:ModelPrefabContext, label:String):Void {
		if (Reflect.hasField(fields, "sortingGroup"))
			model.sortingGroup = cast ctx.decode(Reflect.field(fields, "sortingGroup"), model.sortingGroup);
		if (Reflect.hasField(fields, "modelCollider"))
			model.modelCollider = cast ctx.decode(Reflect.field(fields, "modelCollider"), model.modelCollider);
		if (Reflect.hasField(fields, "group"))
			model.group = cast ctx.decode(Reflect.field(fields, "group"), model.group);
		if (Reflect.hasField(fields, "bone"))
			model.bone = cast ctx.decode(Reflect.field(fields, "bone"), model.bone);
		if (Reflect.hasField(fields, "enabled"))
			model.enabled = toBool(Reflect.field(fields, "enabled"));
	}
	// #endregion

	// #region SpriteRenderer
	static function applySpriteRenderer(sr:SpriteRenderer, fields:Dynamic, ctx:ModelPrefabContext, label:String):Void {
		for (name in Reflect.fields(fields)) {
			var raw = Reflect.field(fields, name);
			switch (name) {
				case "sprite":
					ModelPrefabAssets.ApplyRendererSprite(sr, cast raw);
				case "enabled":
					sr.enabled = toBool(raw);
				case "sortingOrder":
					sr.sortingOrder = toInt(raw);
				case "sortingLayerID":
					// unity.SpriteRenderer 没有 sortingLayerID（只有 sortingLayerName，见 Renderer shim 的差异），
					// 这里只记录。TODO-PORT: 若要还原排序层 ID，需要在 unity.Renderer/SpriteRenderer shim 上补字段。
					missing(label, name);
				case "sortingLayerName":
					sr.sortingLayerName = toStringValue(raw);
				case "color":
					sr.color = cast ctx.decode(raw, sr.color);
				case "flipX":
					sr.flipX = toBool(raw);
				case "flipY":
					sr.flipY = toBool(raw);
				case "size":
					sr.size = cast ctx.decode(raw, sr.size);
				case "materials":
					// unity.SpriteRenderer 没有 materials 字段（材质由渲染层决定），跳过。
					missing(label, name);
				default:
					missing(label, name);
			}
		}
	}
	// #endregion

	// #region Animator
	static function applyAnimator(animator:Animator, fields:Dynamic, ctx:ModelPrefabContext, label:String):Void {
		for (name in Reflect.fields(fields)) {
			var raw = Reflect.field(fields, name);
			switch (name) {
				case "enabled":
					animator.enabled = toBool(raw);
				case "applyRootMotion":
					animator.applyRootMotion = toBool(raw);
				case "speed":
					animator.speed = toFloat(raw);
				case "runtimeAnimatorController":
					animator.runtimeAnimatorController = ctx.decode(raw, animator.runtimeAnimatorController);
				default:
					// avatar / cullingMode / updateMode / linearVelocityBlending：shim 未提供，跳过。
					missing(label, name);
			}
		}
	}
	// #endregion

	// #region ParticleSystem
	static function applyParticleSystem(ps:ParticleSystem, fields:Dynamic, ctx:ModelPrefabContext, label:String):Void {
		for (name in Reflect.fields(fields)) {
			var raw = Reflect.field(fields, name);
			switch (name) {
				case "loop":
					ps.loop = toBool(raw);
				case "playOnAwake":
					ps.playOnAwake = toBool(raw);
				case "duration":
					ps.duration = toFloat(raw);
				case "randomSeed":
					ps.randomSeed = toInt(raw);
				case "useAutoRandomSeed":
					ps.useAutoRandomSeed = toBool(raw);
				case "enabled":
					// unity.ParticleSystem 继承 Component（没有 enabled 字段），这里只记录。
					missing(label, name);
				case "prewarm":
					ps.main.prewarm = toBool(raw);
				case "scalingMode":
					ps.main.scalingMode = cast toInt(raw);
				case "simulationSpace":
					ps.main.simulationSpace = cast toInt(raw);
				case "cullingMode":
					ps.main.cullingMode = cast toInt(raw);
				case "initial":
					applyMainModule(ps.main, raw, ctx, label);
				case "emission":
					applyEmissionModule(ps.emission, raw, ctx, label);
				case "shape":
					applyShapeModule(ps.shape, raw, ctx, label);
				case "textureSheetAnimation":
					applyTextureSheetAnimation(ps.textureSheetAnimation, raw, ctx, label);
				case "systemRenderer":
					// 同 GameObject 上的 ParticleSystemRenderer 组件（见 ModelPrefabLoader 的绑定）。
					if (ps.renderer != null)
						applyGeneric(ps.renderer, raw, ctx, label);
				default:
					// stopAction / moveWithTransform / partial 等：shim 无对应字段，跳过。
					missing(label, name);
			}
		}
	}

	static function applyMainModule(main:MainModule, fields:Dynamic, ctx:ModelPrefabContext, label:String):Void {
		for (name in Reflect.fields(fields)) {
			var raw = Reflect.field(fields, name);
			switch (name) {
				case "startDelay":
					main.startDelay = toFloat(raw);
				case "startLifetime":
					main.startLifetime = toMinMaxCurve(raw, main.startLifetime);
				case "startSpeed":
					main.startSpeed = toMinMaxCurve(raw, main.startSpeed);
				case "startSize":
					main.startSize = toMinMaxCurve(raw, main.startSize);
				case "startRotation":
					main.startRotation = toMinMaxCurve(raw, main.startRotation);
				case "gravityModifier":
					main.gravityModifier = toMinMaxCurve(raw, main.gravityModifier);
				case "startColor":
					main.startColor = toMinMaxGradient(raw, main.startColor);
				case "simulationSpeed":
					main.simulationSpeed = toFloat(raw);
				case "maxParticles":
					main.maxParticles = toInt(raw);
				default:
					missing(label, "main." + name);
			}
		}
	}

	static function applyEmissionModule(emission:EmissionModule, fields:Dynamic, ctx:ModelPrefabContext, label:String):Void {
		for (name in Reflect.fields(fields)) {
			var raw = Reflect.field(fields, name);
			switch (name) {
				case "enabled":
					emission.enabled = toBool(raw);
				case "rateOverTime":
					emission.rateOverTime = toMinMaxCurve(raw, emission.rateOverTime);
				case "rateOverDistance":
					emission.rateOverDistance = toMinMaxCurve(raw, emission.rateOverDistance);
				case "bursts":
					emission.SetBurstsArray(toBursts(raw));
				default:
					missing(label, "emission." + name);
			}
		}
	}

	static function applyShapeModule(shape:ShapeModule, fields:Dynamic, ctx:ModelPrefabContext, label:String):Void {
		for (name in Reflect.fields(fields)) {
			var raw = Reflect.field(fields, name);
			switch (name) {
				case "enabled":
					shape.enabled = toBool(raw);
				case "shapeType":
					shape.shapeType = cast toInt(raw);
				case "radius":
					shape.radius = toFloat(raw);
				case "angle":
					shape.angle = toFloat(raw);
				case "arc":
					shape.arc = toFloat(raw);
				case "position":
					shape.position = cast ctx.decode(raw, shape.position);
				case "rotation":
					shape.rotation = cast ctx.decode(raw, shape.rotation);
				case "scale":
					shape.scale = cast ctx.decode(raw, shape.scale);
				default:
					missing(label, "shape." + name);
			}
		}
	}

	static function applyTextureSheetAnimation(module:TextureSheetAnimationModule, fields:Dynamic, ctx:ModelPrefabContext, label:String):Void {
		for (name in Reflect.fields(fields)) {
			var raw = Reflect.field(fields, name);
			switch (name) {
				case "enabled":
					module.enabled = toBool(raw);
				case "mode":
					module.mode = toInt(raw);
				case "numTilesX":
					module.numTilesX = toInt(raw);
				case "tilesY":
					module.numTilesY = toInt(raw);
				case "sprites":
					var list:Array<Dynamic> = cast raw;
					if (list != null) {
						for (i in 0...list.length) {
							var entry:Dynamic = list[i];
							var spriteRef:Dynamic = entry == null ? null : Reflect.field(entry, "sprite");
							var sprite:Dynamic = ctx.decode(spriteRef, null);
							module.SetSprite(i, sprite);
						}
					}
				default:
					missing(label, "textureSheetAnimation." + name);
			}
		}
	}
	// #endregion

	// #region 通用（MonoBehaviour 与 unity shim 的其余组件）
	/**
	 * 按名字写入字段。
	 *
	 * PORT-NOTE: 字段是否存在用 Type.getInstanceFields 判断，**不用 Reflect.hasField**：
	 * 实测（hxcpp 原生构建）Reflect.hasField 对类实例一律返回 false，会让所有 MonoBehaviour
	 * 的序列化字段（ModelAnchor.key、AnimatorElement.elementName、LightController.* 等）都写不进去。
	 * 字段集合按类名缓存；匿名对象（JSON 解析结果）仍用 Reflect.hasField。
	 * 子字典（如 ParticleSystem 的模块）递归写入现有子对象，而不是替换它。
	 */
	static function applyGeneric(target:Dynamic, fields:Dynamic, ctx:ModelPrefabContext, label:String):Void {
		for (name in Reflect.fields(fields)) {
			if (!hasField(target, name)) {
				missing(label, name);
				continue;
			}
			var raw:Dynamic = Reflect.field(fields, name);
			var current:Dynamic = Reflect.field(target, name);
			if (isPlainDict(raw) && isNestedObject(current)) {
				applyGeneric(current, raw, ctx, label + "." + name);
				continue;
			}
			Reflect.setField(target, name, ctx.decode(raw, current));
		}
	}

	/** 类实例的字段集合（缓存）；匿名对象走 Reflect。 */
	static function hasField(target:Dynamic, name:String):Bool {
		var cls = Type.getClass(target);
		if (cls == null)
			return Reflect.hasField(target, name);
		var key = Type.getClassName(cls);
		if (key == null)
			return Reflect.hasField(target, name);
		var set = fieldSetCache.get(key);
		if (set == null) {
			set = new Map();
			for (field in Type.getInstanceFields(cls))
				set.set(field, true);
			fieldSetCache.set(key, set);
		}
		return set.exists(name);
	}
	private static var fieldSetCache:Map<String, Map<String, Bool>> = new Map();

	/** 现有字段值是「可递归写入的对象」（shim 的模块对象或结构体），字符串/数组不算。 */
	static function isNestedObject(value:Dynamic):Bool {
		if (value == null)
			return false;
		return switch (Type.typeof(value)) {
			case TObject: true;
			case TClass(c): c != String && c != Array;
			default: false;
		}
	}

	/** 普通字典（不是引用/结构体）时返回 true。 */
	static function isPlainDict(value:Dynamic):Bool {
		// PORT-NOTE: 必须用 Type.typeof 判断匿名对象——hxcpp 上 Reflect.isObject("字符串") 也为 true。
		if (value == null || Type.typeof(value) != TObject)
			return false;
		return !Reflect.hasField(value, "n") && !Reflect.hasField(value, "asset") && !Reflect.hasField(value, "t");
	}
	// #endregion

	// #region 值转换
	static function toBool(value:Dynamic):Bool {
		if (value == null)
			return false;
		if (Std.isOfType(value, Bool))
			return cast value;
		return (value:Float) != 0;
	}
	static function toInt(value:Dynamic):Int {
		if (value == null)
			return 0;
		if (Std.isOfType(value, Int))
			return cast value;
		return Std.int(value);
	}
	static function toFloat(value:Dynamic):Float {
		if (value == null)
			return 0;
		return value;
	}
	static function toStringValue(value:Dynamic):String {
		return value == null ? null : Std.string(value);
	}

	/** {mode, constant, constantMin, constantMax, curveMin, curveMax:[{time,value}]} -> MinMaxCurve。 */
	static function toMinMaxCurve(raw:Dynamic, ?target:MinMaxCurve):MinMaxCurve {
		var out = target != null ? target : new MinMaxCurve();
		if (raw == null || Type.typeof(raw) != TObject)
			return out;
		out.mode = cast toInt(Reflect.field(raw, "mode"));
		out.constant = toFloat(Reflect.field(raw, "constant"));
		out.constantMin = toFloat(Reflect.field(raw, "constantMin"));
		out.constantMax = toFloat(Reflect.field(raw, "constantMax"));
		out.curveMin = toAnimationCurve(Reflect.field(raw, "curveMin"), out.curveMin);
		out.curveMax = toAnimationCurve(Reflect.field(raw, "curveMax"), out.curveMax);
		return out;
	}

	static function toAnimationCurve(raw:Dynamic, ?target:AnimationCurve):AnimationCurve {
		if (raw == null)
			return target;
		var keys:Array<Dynamic> = cast raw;
		var curve = target != null ? target : new AnimationCurve();
		curve.keys.resize(0);
		for (key in keys) {
			if (key == null)
				continue;
			curve.AddKey(toFloat(Reflect.field(key, "time")), toFloat(Reflect.field(key, "value")));
		}
		return curve;
	}

	/** {mode, color, colorMin, colorMax} -> MinMaxGradient。 */
	static function toMinMaxGradient(raw:Dynamic, ?target:MinMaxGradient):MinMaxGradient {
		var out = target != null ? target : new MinMaxGradient();
		if (raw == null || Type.typeof(raw) != TObject)
			return out;
		out.mode = cast toInt(Reflect.field(raw, "mode"));
		var color:Dynamic = Reflect.field(raw, "color");
		if (color != null)
			out.color = cast toColor(color);
		var min:Dynamic = Reflect.field(raw, "colorMin");
		if (min != null)
			out.colorMin = cast toColor(min);
		var max:Dynamic = Reflect.field(raw, "colorMax");
		if (max != null)
			out.colorMax = cast toColor(max);
		return out;
	}

	static function toColor(values:Array<Float>):Color {
		if (values == null || values.length < 3)
			return new Color(1, 1, 1, 1);
		return new Color(values[0], values[1], values[2], values.length > 3 ? values[3] : 1);
	}

	static function toBursts(raw:Dynamic):Array<Burst> {
		var out:Array<Burst> = [];
		var list:Array<Dynamic> = cast raw;
		if (list == null)
			return out;
		for (entry in list) {
			if (entry == null)
				continue;
			var burst = new Burst(toFloat(Reflect.field(entry, "time")), 0);
			burst.count = toMinMaxCurve(Reflect.field(entry, "count"), burst.count);
			burst.cycleCount = toInt(Reflect.field(entry, "cycleCount"));
			burst.repeatInterval = toFloat(Reflect.field(entry, "repeatInterval"));
			burst.probability = toFloat(Reflect.field(entry, "probability"));
			out.push(burst);
		}
		return out;
	}

	static function missing(label:String, field:String):Void {
		var key = label + "." + field;
		if (ModelPrefabLoader.missingFields.exists(key))
			return;
		ModelPrefabLoader.missingFields.set(key, 1);
	}
	// #endregion
}
