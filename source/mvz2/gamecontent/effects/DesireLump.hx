// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter4/DesireLump.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.contraptions.DesirePot;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.entities.Entity;
import tools.mathematics.MathTool;
import unity.Mathf;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaEffectNames.desireLump)
class DesireLump extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetStartPosition(entity, entity.Position);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var parent = entity.Parent;
        if (!parent.ExistsAndAlive())
        {
            entity.Remove();
            return;
        }
        var startPosition = GetStartPosition(entity);
        var t = 1 - entity.Timeout / entity.GetMaxTimeout();
        var targetPosition = parent.GetCenter();
        var pos = Vector3.Lerp(startPosition, targetPosition, t);
        var maxY = Mathf.Max(targetPosition.y, 200);
        pos.y = MathTool.LerpParabolla(startPosition.y, targetPosition.y, maxY, t);
        entity.Position = pos;

        if (entity.Timeout <= 0)
        {
            DesirePot.DuplicateStarshard(parent);
        }
    }
    public static function GetStartPosition(entity:Entity):Vector3 return entity.GetBehaviourField(PROP_START_POSITION);
    public static function SetStartPosition(entity:Entity, value:Vector3):Void entity.SetBehaviourField(PROP_START_POSITION, value);
    private static var PROP_START_POSITION:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("StartPosition");
}
