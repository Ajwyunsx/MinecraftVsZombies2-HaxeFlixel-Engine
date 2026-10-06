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

// Ported from: Assets/Scripts/MVZ2/Grids/GridLayoutController.cs
class GridLayoutController extends MonoBehaviour {
    public function InitGridViews(initDatas:Array<Array<GridInitData>>):Void {
        var gridList:Array<GridController> = [];
        lanes.updateList(initDatas.length, function(i, obj) {
            var lane = obj.GetComponent(LaneController);
            lane.SetLane(i);
            lane.InitGrids(initDatas[i]);
            for (g in lane.GetGrids()) gridList.push(g);
        }, function(obj) {
            var lane = obj.GetComponent(LaneController);
            lane.OnPointerInteraction.add(OnGridPointerEnterCallback);
        }, function(obj) {
            var lane = obj.GetComponent(LaneController);
            lane.OnPointerInteraction.remove(OnGridPointerEnterCallback);
        });
        grids = Lambda.array(gridList);
    }
    public function GetGrid(lane:Int, column:Int):GridController {
        var laneController = GetLane(lane);
        return laneController != null ? laneController.GetGrid(column) : null;
    }
    public function GetGrids():Array<GridController> {
        return grids;
    }
    public function GetLane(lane:Int):LaneController {
        return lanes.getElementAs(lane, LaneController);
    }
    public function GetLanes():Array<LaneController> {
        return lanes.getElementsAs(LaneController);
    }
    private function OnGridPointerEnterCallback(lane:LaneController, column:Int, data:PointerEventData, interaction:PointerInteraction):Void {
        var index = lanes.indexOf(lane.gameObject);
        OnPointerInteraction.dispatch(index, column, data, interaction);
    }
    public var OnPointerInteraction:FlxTypedSignal<Int->Int->PointerEventData->PointerInteraction->Void> = new FlxTypedSignal();
    @:serializeField
    private var lanes:ElementList = null;
    private var grids:Array<GridController>;
}
