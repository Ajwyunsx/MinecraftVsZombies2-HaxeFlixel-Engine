package mvz2.grids;

// PORT-NOTE: FlxTypedSignal 是 flixel.util.FlxSignal 模块内的次类型，需从所属模块导入。
import flixel.util.FlxSignal.FlxTypedSignal;
import mvz2.ui.ElementList;
// PORT-NOTE: GridInitData 是 GridController 模块内的次类型，Haxe 需显式从所属模块导入。
import mvz2.grids.GridController.GridInitData;
import mvz2logic.inputs.PointerInteraction;
// PORT-NOTE: Haxe 无法解析含大写字母的包段，unity shim 目录实为 unity/eventsystems。
import unity.eventsystems.PointerEventData;
import unity.MonoBehaviour;

// Ported from: Assets/Scripts/MVZ2/Grids/LaneController.cs
class LaneController extends MonoBehaviour {
    public function InitGrids(initDatas:Array<GridInitData>):Void {
        grids.updateList(initDatas.length, function(i, obj) {
            var grid = obj.GetComponent(GridController);
            grid.Lane = Lane;
            grid.Column = i;
            // PORT-NOTE: `GridController.size` 是 [SerializeField]，由 `Prefabs/Level/Grid.prefab`
            // 注入（0.8,0.8）；克隆模板时若数据链路没接上就是 (0,0) → `slope = BevelHeight / size.x`
            // 除零、格子拾取全错。这里在 Init 之前补一次（优先取 prefab 数据，取不到用常量兜底）。
            GridController.ensureSize(grid);
            grid.Init(initDatas[i]);
        }, function(obj) {
            var grid = obj.GetComponent(GridController);
            grid.OnPointerInteraction.add(OnGridPointerInteractionCallback);
        }, function(obj) {
            var grid = obj.GetComponent(GridController);
            grid.OnPointerInteraction.remove(OnGridPointerInteractionCallback);
        });
    }
    public function SetLane(lane:Int):Void {
        Lane = lane;
        for (i in 0...grids.Count) {
            var grid = GetGrid(i);
            if (grid != null)
                grid.Lane = lane;
        }
    }
    public function GetGrid(column:Int):GridController {
        return grids.getElementAs(column, GridController);
    }
    public function GetGrids():Array<GridController> {
        return grids.getElementsAs(GridController);
    }
    private function OnGridPointerInteractionCallback(grid:GridController, data:PointerEventData, interaction:PointerInteraction):Void {
        var index = grids.indexOf(grid.gameObject);
        OnPointerInteraction.dispatch(this, index, data, interaction);
    }
    public var OnPointerInteraction:FlxTypedSignal<LaneController->Int->PointerEventData->PointerInteraction->Void> = new FlxTypedSignal();
    public var Lane(default, null):Int;
    @:serializeField
    private var grids:ElementList = null;
}
