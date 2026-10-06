// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/Chapter2/NightmareaperTimer.cs
package mvz2.gamecontent.effects;

import mvz2.gamecontent.bosses.Nightmareaper;
import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.bosses.NightmareaperEnragedBuff;
import mvz2.gamecontent.difficulties.VanillaDifficultyLevelProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.level.LogicLevelExt;
import mvz2logic.level.LogicLevelProps;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import unity.Color;
import mvz2.gamecontent.effects.VanillaEffectID.VanillaEffectNames;

@:autoEntityBehaviourDefinition(VanillaEffectNames.nightmareaperTimer)
class NightmareaperTimer extends EffectBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        var timeout = VanillaDifficultyLevelProps.GetNightmareaperTimeout(entity.Level);
        SetTimeout(entity, timeout);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        UpdateTimer(entity);
    }
    private function UpdateTimer(entity:Entity):Void
    {
        var timeout = GetTimeout(entity);
        if (timeout > 0)
        {
            timeout--;
            if (timeout <= 0)
            {
                EnrageReapers(entity);
            }
            SetTimeout(entity, timeout);
        }
        var tint = Color.Lerp(Color.red, Color.white, timeout / 900.0);
        entity.SetModelProperty("Color", tint);
        entity.SetModelProperty("Timeout", timeout);
    }
    private function EnrageReapers(entity:Entity):Void
    {
        var level = entity.Level;
        if (LogicLevelProps.IsGodMode(level))
        {
            for (nightmareaper in level.FindEntities(VanillaBossID.nightmareaper))
            {
                nightmareaper.Die();
            }
        }
        else
        {
            level.StopMusic();
            for (nightmareaper in level.FindEntities(VanillaBossID.nightmareaper))
            {
                Nightmareaper.Enrage(nightmareaper);
                nightmareaper.AddBuff(NightmareaperEnragedBuff);
            }
        }
    }
    public static function GetTimeout(entity:Entity):Int
    {
        return entity.GetBehaviourFieldNS(ID, PROP_TIMEOUT);
    }
    public static function SetTimeout(entity:Entity, value:Int):Void
    {
        entity.SetBehaviourFieldNS(ID, PROP_TIMEOUT, value);
    }
    public static var PROP_TIMEOUT:VanillaEntityPropertyMeta<Int> = new VanillaEntityPropertyMeta<Int>("Timeout");
    public static var ID:NamespaceID = VanillaEffectID.nightmareaperTimer;
}
