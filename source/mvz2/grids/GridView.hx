// Ported from: Assets/Scripts/View/Grids/GridView.cs
package mvz2.grids;

import flixel.util.FlxSignal.FlxTypedSignal;
// PORT-NOTE: 原 import 写作 mvz2.level.LevelPointerInteractionHandler；
// C# 源码位于 Assets/Scripts/View/Level/，移植后类实际在 mvz2.view.level。
import mvz2.view.level.LevelPointerInteractionHandler;
import mvz2.models.EntityModel;
import mvz2.models.IModelBuilder;
import mvz2.models.Model;
import mvz2logic.inputs.PointerInteraction;
import pvzengine.models.ModelInsertion;
import unity.Color;
import unity.PolygonCollider2D;
import unity.Sprite;
import unity.SpriteRenderer;
import unity.Transform;
import unity.UnityObject;
import unity.Vector2;
import unity.Vector3;
import unity.eventsystems.PointerEventData;
import unity.MonoBehaviour;

class GridView extends unity.MonoBehaviour
{
	// #region 生命周期
	function Awake():Void
	{
		holdStreakHandler.OnPointerInteraction.add((_, d, i) -> OnPointerInteraction.dispatch(this, d, i));
	}
	public function UpdateFixed():Void
	{
		holdStreakHandler.UpdateHoldAndStreak();
		if (UnityObject.exists(model))
		{
			model.UpdateFixed();
		}
	}
	public function UpdateFrame(deltaTime:Float):Void
	{
		if (UnityObject.exists(model))
		{
			model.UpdateFrame(deltaTime);
			model.UpdateAnimators(deltaTime);
		}
	}
	// #endregion

	// #region 模型
	public function BuildModel(builder:IModelBuilder):Void
	{
		if (UnityObject.exists(model))
		{
			UnityObject.destroy(model.gameObject);
		}
		model = builder.Build(modelRoot);
	}
	public function GetModel():Null<Model>
	{
		return model;
	}
	public function UpdateModelInsertions(modelInsertions:Array<ModelInsertion>):Void
	{
		if (UnityObject.exists(model))
			model.UpdateModelInsertions(modelInsertions);
	}
	// #endregion

	// #region 设置属性
	public function SetModelSortingLayerAndOrder(layer:String, order:Int):Void
	{
		if (UnityObject.exists(model) && Std.isOfType(model, EntityModel))
		{
			var entityModel:EntityModel = cast model;
			entityModel.SortingLayerName = layer;
			entityModel.SortingOrder = order;
		}
	}
	public function GetSortingLayerID():Int
	{
		// PORT-NOTE: unity.SpriteRenderer shim 没有 sortingLayerID（Renderer 才有），
		// 只有 sortingLayerName，故用 unity.SortingLayer.NameToID 换算出 ID（C# 直接读 sortingLayerID）。
		return unity.SortingLayer.NameToID(spriteRenderer.sortingLayerName);
	}
	public function GetSortingOrder():Int
	{
		return spriteRenderer.sortingOrder;
	}
	public function SetPosition(position:Vector3):Void
	{
		transform.localPosition = position;
	}
	public function SetSprite(sprite:Null<Sprite>):Void
	{
		spriteRenderer.sprite = sprite;
		UpdateSpriteEnabled();
	}
	public function SetColor(color:Color):Void
	{
		spriteRenderer.color = color;
		UpdateSpriteEnabled();
	}
	public function SetDisplaySection(start:Float, end:Float, size:Vector2, bevelHeight:Float):Void
	{
		var sprSize = spriteRenderer.size;
		sprSize.y = (end - start) * size.y + Math.abs(bevelHeight);
		spriteRenderer.size = sprSize;

		var pos = rendererTransform.localPosition;
		pos.y = (end - 1) * size.y;
		rendererTransform.localPosition = pos;
		UpdateSpriteEnabled();
	}
	public function SetColliderBevel(size:Vector2, height:Float):Void
	{
		var points = polygonCollider.points;
		if (points.length >= 4)
		{
			points[2].y = -size.y * 0.5 - height;
			points[3].y = size.y * 0.5 - height;
			polygonCollider.points = points;
		}
	}
	private function UpdateSpriteEnabled():Void
	{
		spriteRenderer.enabled = spriteRenderer.sprite != null && spriteRenderer.color.a > 0 && spriteRenderer.size.sqrMagnitude > 0;
	}
	// #endregion

	public var OnPointerInteraction:FlxTypedSignal<GridView->PointerEventData->PointerInteraction->Void> = new FlxTypedSignal();
	@:serializeField
	private var rendererTransform:Transform;
	@:serializeField
	private var spriteRenderer:SpriteRenderer;
	@:serializeField
	private var holdStreakHandler:LevelPointerInteractionHandler;
	@:serializeField
	private var polygonCollider:PolygonCollider2D;
	@:serializeField
	private var modelRoot:Transform;
	private var model:Null<Model> = null;
}
