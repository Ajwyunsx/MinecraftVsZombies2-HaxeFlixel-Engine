// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter1/StunStars.cs
package mvz2.gamecontent.effects;

import mvz2.vanilla.entities.VanillaEntityExt;
import pvzengine.entities.Entity;
import unity.Vector3;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.stunStars)
class StunStars extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
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
        entity.Position = GetPosition(parent);
    }
    public static function GetPosition(parent:Entity):Vector3
    {
        return parent.Position + Vector3.up * parent.GetScaledSize().y;
    }
    // #endregion
}
