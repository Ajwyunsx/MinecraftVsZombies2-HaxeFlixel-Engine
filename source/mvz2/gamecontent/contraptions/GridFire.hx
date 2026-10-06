// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter5/GridFire.cs
// PORT-NOTE: 原文件位于 Effects/Chapter5 下，但 C# 命名空间是 MVZ2.GameContent.Contraptions，
// 按 PORTING.md 的「命名空间 → 包名」规则放在 mvz2.gamecontent.contraptions 包。
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.detections.HellfireIgniteDetector;
import mvz2.gamecontent.effects.VanillaEffectID;
// PORT-NOTE: VanillaEffectNames 与 VanillaEffectID 被放在同一个模块 VanillaEffectID.hx 中（同模块子类型），
// 跨包引用需要写完整的模块路径。
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
import mvz2.gamecontent.stages.VanillaStageID;
import mvz2.vanilla.detection.Detector;
import mvz2.vanilla.entities.IBeBlownBehaviour;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.level.VanillaLevelProps;
import mvz2.vanilla.localization.VanillaStrings;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.localization.LogicStrings;
import pvzengine.collisions.FactionTarget;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.entities.SpawnParams;
import pvzengine.grids.LawnGrid;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.level.VanillaLevelProps;

@:autoEntityBehaviourDefinition(VanillaEffectNames.gridFire)
class GridFire extends EntityBehaviourDefinition implements IBeBlownBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        detector = new HellfireIgniteDetector(0);
        detector.factionTarget = FactionTarget.Any;
        detector.mask = EntityCollisionHelper.MASK_PROJECTILE;
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var level = entity.Level;
        if (level.StageID == VanillaStageID.ship11 && !level.IsRerun && !level.IsGridFireAdviced())
        {
            level.SetGridFireAdviced(true);
            level.ShowAdvice(LogicStrings.CONTEXT_ADVICE, VanillaStrings.ADVICE_CLICK_TO_EXTINGUISH_FIRE, 100, 120, []);
        }
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        UpdateIgnite(entity);
    }
    private function UpdateIgnite(hellfire:Entity):Void
    {
        igniteBuffer.resize(0);
        detector.DetectEntities(DetectionParams.fromEntity(hellfire), igniteBuffer);
        for (target in igniteBuffer)
        {
            target.HellfireIgnite(hellfire, false);
        }
    }
    public function BeBlown(entity:Entity, source:Entity):Void
    {
        entity.Timeout = Mathf.MinInt(entity.Timeout, 15);
    }
    public static function Spawn(grid:LawnGrid, source:Entity, spawnParam:SpawnParams):Null<Entity>
    {
        if (!grid.IsLand())
            return null;
        var level = source.Level;
        if (level.EntityExists(function(e) return e.IsEntityOf(VanillaEffectID.gridFire) && e.GetGrid() == grid))
            return null;
        var position = grid.GetEntityPosition();

        return source.Spawn(VanillaEffectID.gridFire, position, spawnParam);
    }
    private var detector:Detector;
    private var igniteBuffer:Array<Entity> = [];

}
