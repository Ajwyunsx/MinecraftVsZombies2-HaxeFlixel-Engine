// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter2/NightmareGlass.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.buffs.entities.WhiteFlashBuff;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import pvzengine.NamespaceID;
import pvzengine.entities.Entity;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEffectNames.nightmareGlass)
class NightmareGlass extends EffectBehaviour
{
    // #region 公有方法
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    // #endregion
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetBreakTimeout(entity, 60);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        var breakTimeout = GetBreakTimeout(entity);
        if (breakTimeout > 0)
        {
            breakTimeout--;
            SetBreakTimeout(entity, breakTimeout);
            if (breakTimeout <= 0)
            {
                entity.TriggerModel("Break");
                entity.PlaySound(VanillaSoundID.glassBreakBig);
                entity.Level.ShakeScreen(10, 0, 15);
                WhiteFlashBuff.AddToEntity(entity, 2);
            }
        }
    }
    public static function GetBreakTimeout(entity:Entity):Int
    {
        return entity.GetBehaviourFieldNS(ID, PROP_BREAK_TIMEOUT);
    }
    public static function SetBreakTimeout(entity:Entity, value:Int):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_BREAK_TIMEOUT, value);
    }
    public static var PROP_BREAK_TIMEOUT:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("BreakTimeout");
    public static var ID:NamespaceID = VanillaEffectID.nightmareGlass;
}
