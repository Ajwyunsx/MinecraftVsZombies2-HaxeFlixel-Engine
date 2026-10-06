// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter3/Anubisand.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.buffs.enemies.FlyBuff;
import mvz2.gamecontent.buffs.enemies.SoulsandSummonedBuff;
import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import pvzengine.NamespaceID;
import pvzengine.buffs.BuffExt;
import pvzengine.entities.Entity;
import tools.FrameTimer;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.anubisand)
class Anubisand extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetSummonTimer(entity, new FrameTimer(SUMMON_INTERVAL));
        var buff = entity.AddBuff(FlyBuff);
        buff.SetProperty(FlyBuff.PROP_TARGET_HEIGHT, 80);
    }
    override function UpdateAI(enemy:Entity):Void
    {
        super.UpdateAI(enemy);
        if (enemy.IsDead)
            return;
        var timer = GetSummonTimer(enemy);
        if (timer.RunToExpiredAndNotNull(enemy.GetAttackSpeed()))
        {
            timer.Reset();
            var offset = SUMMON_OFFSET;
            offset.x *= enemy.GetFacingX();
            // C#: enemy.SpawnWithParams(...)?.Let(e => { e.AddBuff<SoulsandSummonedBuff>(); })
            var e = enemy.SpawnWithParams(VanillaEnemyID.soulsand, enemy.Position + offset);
            if (e != null)
            {
                e.AddBuff(SoulsandSummonedBuff);
            }
            enemy.PlaySound(VanillaSoundID.cave);
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        var timer = GetSummonTimer(entity);
        var blend = GetBlackholeBlend(entity);
        if (timer != null && timer.Frame <= SUMMON_INTERVAL / 2)
        {
            blend = 1 - timer.Frame / (SUMMON_INTERVAL * 0.5);
        }
        else
        {
            blend -= 1 / 15;
        }
        SetBlackholeBlend(entity, blend);
        entity.SetAnimationFloat("BlackholeBlend", blend);
    }
    public static function GetSummonTimer(enemy:Entity):Null<FrameTimer> return enemy.GetBehaviourFieldNS(ID, FIELD_SUMMON_TIMER);
    public static function SetSummonTimer(enemy:Entity, value:FrameTimer):Void enemy.SetBehaviourFieldNS(ID, FIELD_SUMMON_TIMER, value);

    public static function GetBlackholeBlend(enemy:Entity):Float return enemy.GetBehaviourFieldNS(ID, FIELD_BLACKHOLE_BLEND);
    public static function SetBlackholeBlend(enemy:Entity, value:Float):Void enemy.SetBehaviourFieldNS(ID, FIELD_BLACKHOLE_BLEND, value);

    public static var FIELD_SUMMON_TIMER:VanillaEntityPropertyMeta<FrameTimer> = new VanillaEntityPropertyMeta<FrameTimer>("SummonTimer");
    public static var FIELD_BLACKHOLE_BLEND:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("BlackholeBlend");
    public static inline var SUMMON_INTERVAL:Int = 180;
    public static var SUMMON_OFFSET:Vector3 = new Vector3(30, 80, 0);
    public static var ID:NamespaceID = VanillaEnemyID.anubisand;
}
