// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Chapter4/ShikaisenZombie.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.entities.AIEntityBehaviour;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import pvzengine.entities.Entity;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;

@:autoEntityBehaviourDefinition(VanillaEnemyNames.shikaisenZombie)
class ShikaisenZombie extends AIEntityBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        SetStaff(entity, true);
    }
    override function UpdateAI(enemy:Entity):Void
    {
        super.UpdateAI(enemy);
        if (HasStaff(enemy) && enemy.Health <= enemy.GetMaxHealth() * 0.5 && enemy.IsOnGround)
        {
            SpawnStaff(enemy);
            SetStaff(enemy, false);
        }
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetModelProperty("NoStaff", !HasStaff(entity));
    }
    public static function SpawnStaff(entity:Entity):Null<Entity>
    {
        var pos = entity.Position + entity.GetFacingDirection() * 30;
        var param = entity.GetSpawnParams();
        // C#: entity.Spawn(...)?.Let(e => { e.PlaySound(VanillaSoundID.wood); })
        var e = entity.Spawn(VanillaEnemyID.shikaisenStaff, pos, param);
        if (e != null)
        {
            e.PlaySound(VanillaSoundID.wood);
        }
        return e;
    }
    public static function HasStaff(enemy:Entity):Bool return enemy.GetBehaviourField(PROP_HAS_STAFF);
    public static function SetStaff(enemy:Entity, value:Bool):Void enemy.SetBehaviourField(PROP_HAS_STAFF, value);
    public static var PROP_HAS_STAFF:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("HasStaff");
}
