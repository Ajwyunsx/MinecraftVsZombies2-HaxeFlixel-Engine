package mvz2.supporters;

// Ported from: Assets/Scripts/MVZ2/Sponsors/SponsorSaveItem.cs (static class SponsorPlans)
// PORT-NOTE: C# `static class SponsorPlans` with nested static classes (Furnace/Sensor); Haxe has
// no inner types, so the constants are flattened with their original names.
class SponsorPlans {
    private function new() {}

    public static inline var FURNACE_TYPE:Int = 1;
    public static inline var FURNACE_FURNACE:Int = 15;
    public static inline var FURNACE_GUNPOWDER_BARREL:Int = 30;
    public static inline var FURNACE_BLAST_FURNACE:Int = 50;

    public static inline var SENSOR_TYPE:Int = 2;
    public static inline var SENSOR_MOONLIGHT_SENSOR:Int = 10;

    // PORT-NOTE: C# `out (int type, int rank) plan` → mutable `{type, rank}` structure.
    public static function TryGetPlanByID(id:String, plan:{type:Int, rank:Int}):Bool {
        if (id == null || id.length == 0) {
            plan.type = 0;
            plan.rank = 0;
            return false;
        }
        if (!planMap.exists(id)) return false;
        var value = planMap.get(id);
        plan.type = value.type;
        plan.rank = value.rank;
        return true;
    }

    private static var planMap:Map<String, {type:Int, rank:Int}> = [
        "25afa204d56311ef9a3552540025c377" => {type: SENSOR_TYPE, rank: SENSOR_MOONLIGHT_SENSOR},
        "3d36f9e0d56311efa99a52540025c377" => {type: FURNACE_TYPE, rank: FURNACE_FURNACE},
        "6f26d290d56311efa5aa52540025c377" => {type: FURNACE_TYPE, rank: FURNACE_GUNPOWDER_BARREL},
        "b3a2d76cd56211efb2f852540025c377" => {type: FURNACE_TYPE, rank: FURNACE_BLAST_FURNACE},
    ];
}
