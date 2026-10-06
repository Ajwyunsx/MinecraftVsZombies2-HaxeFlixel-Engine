// Ported from: Assets/Scripts/Vanilla/GameContent/Pickups/Gems/MergePickup.cs
package mvz2.gamecontent.pickups;

import mvz2.gamecontent.detections.GemMergeDetector;
import mvz2.vanilla.detection.Detector.DetectionParams;
import mvz2.vanilla.entities.VanillaEntityBehaviourNames;
import mvz2.vanilla.pickups.VanillaPickupExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.NamespaceID;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
using mvz2.vanilla.pickups.VanillaPickupExt;

@:autoEntityBehaviourDefinition(VanillaEntityBehaviourNames.mergePickup)
class MergePickup extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        mergeDetector = new GemMergeDetector();
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        CheckMerge(entity);
    }
    public override function Update(pickup:Entity):Void
    {
        super.Update(pickup);
        var level = pickup.Level;
        if (!pickup.IsCollected() && pickup.IsSecondsInterval(1))
        {
            CheckMerge(pickup);
        }
    }
    private function CheckMerge(entity:Entity):Void
    {
        var mergeCount = GetMergeCount(entity);
        if (mergeCount <= 0)
            return;
        var mergeTarget = GetMergeTarget(entity);
        if (mergeTarget == null)
            return;
        var mergeDetectBuffer:Array<Entity> = [];
        mergeDetector.DetectEntities(DetectionParams.fromEntity(entity), mergeDetectBuffer);
        if (mergeDetectBuffer.length < mergeCount)
            return;

        var mergeBuffer:Array<Entity> = [];
        for (target in mergeDetectBuffer)
        {
            if (target.IsCollected())
                continue;
            mergeBuffer.push(target);
            if (mergeBuffer.length >= mergeCount)
            {
                var targetGem = mergeBuffer[0];
                // C#: entity.Level.Spawn(mergeTarget, targetGem.Position, null)?.Let(e => { e.Velocity = targetGem.Velocity; })
                var spawned = entity.Level.Spawn(mergeTarget, targetGem.Position, null);
                if (spawned != null)
                {
                    spawned.Velocity = targetGem.Velocity;
                }
                for (mergeGem in mergeBuffer)
                {
                    mergeGem.Remove();
                }
                mergeBuffer.resize(0);
            }
        }
    }
    public static function GetMergeCount(entity:Entity):Int return entity.GetProperty(PROP_MERGE_COUNT);
    public static function GetMergeRange(entity:Entity):Float return entity.GetProperty(PROP_MERGE_RANGE);
    public static function GetMergeTarget(entity:Entity):Null<NamespaceID> return entity.GetProperty(PROP_MERGE_TARGET);

    private var mergeDetector:GemMergeDetector;

    public static var PROP_MERGE_COUNT:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("merge_count");
    public static var PROP_MERGE_RANGE:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("merge_range");
    public static var PROP_MERGE_TARGET:VanillaEntityPropertyMeta<NamespaceID> = new VanillaEntityPropertyMeta<NamespaceID>("merge_target");
}
