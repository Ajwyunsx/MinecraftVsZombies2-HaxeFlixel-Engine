// Ported from: Assets/Scripts/Vanilla/GameContent/Contraptions/Chapter4/NoteBlock.cs
package mvz2.gamecontent.contraptions;

import mvz2.gamecontent.bosses.TheGiant;
import mvz2.gamecontent.bosses.VanillaBossID;
import mvz2.gamecontent.buffs.contraptions.NoteBlockChargedBuff;
import mvz2.gamecontent.buffs.contraptions.NoteBlockLoudBuff;
import mvz2.gamecontent.damages.VanillaDamageEffects;
import mvz2.gamecontent.effects.VanillaEffectID;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.entities.VanillaEntityExt;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityExt;
import mvz2logic.level.LogicLevelExt;
import pvzengine.EntityID;
import pvzengine.buffs.BuffExt;
import pvzengine.damages.DamageEffectList;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityTypes;
import tools.FrameTimer;
import unity.Color;
import unity.Mathf;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2logic.entities.LogicEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;

@:autoEntityBehaviourDefinition(VanillaContraptionNames.noteBlock)
class NoteBlock extends DispenserFamily
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }

    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        InitShootTimer(entity);
    }
    override function UpdateAI(entity:Entity):Void
    {
        super.UpdateAI(entity);
        ShootTick(entity);
    }
    override function UpdateLogic(entity:Entity):Void
    {
        super.UpdateLogic(entity);
        entity.SetAnimationBool("Loud", entity.HasBuff(NoteBlockLoudBuff));
    }
    public override function OnShootTick(entity:Entity):Void
    {
        var children = GetNoteChildren(entity);
        if (children != null)
        {
            var expired = Lambda.filter(children, id -> !id.Exists(entity.Level));
            for (id in expired)
            {
                children.remove(id);
            }
            if (children.length >= MAX_NOTE_COUNT)
            {
                return;
            }
        }
        super.OnShootTick(entity);
    }
    public override function Shoot(entity:Entity):Null<Entity>
    {
        var projectile = super.Shoot(entity);
        if (projectile != null)
        {
            projectile.SetParent(entity);
            var h = projectile.RNG.NextFloat();
            var color = Color.HSVToRGB(h, 1, 1);
            projectile.SetTint(color);
            ResetNoteTimeout(entity, projectile);
            PlayHarpSound(entity);

            AddNoteChild(entity, projectile);
        }
        return projectile;
    }
    override function OnEvoke(entity:Entity):Void
    {
        super.OnEvoke(entity);
        entity.AddBuff(NoteBlockLoudBuff);
        entity.PlaySound(VanillaSoundID.ufo);
        entity.PlaySound(VanillaSoundID.growBig);

        if (entity.HasBuff(NoteBlockChargedBuff))
        {
            entity.Level.ShakeScreen(15, 0, 90);
            for (target in entity.Level.FindEntities(e -> e.IsHostile(entity) && e.IsVulnerableEntity()))
            {
                target.TakeDamage(EVOCATION_CHARGED_DAMAGE, new DamageEffectList([VanillaDamageEffects.MUTE]), entity);
                if (target.IsEntityOf(VanillaBossID.theGiant))
                {
                    TheGiant.Stun(target, 150);
                }
                else if (target.Type == EntityTypes.ENEMY)
                {
                    target.Stun(300);
                }
            }
            entity.Spawn(VanillaEffectID.amplifiedRoar, entity.GetCenter());
            entity.RemoveBuffs(NoteBlockChargedBuff);
            entity.PlaySound(VanillaSoundID.giantRoar, 2);
        }
    }
    public override function CanEvoke(entity:Entity):Bool
    {
        if (entity.HasBuff(NoteBlockLoudBuff))
        {
            return false;
        }
        return super.CanEvoke(entity);
    }
    override function GetTimerTime(entity:Entity):Int
    {
        return FIRE_INTERVAL;
    }
    public static function PlayHarpSound(entity:Entity):Void
    {
        var pitch = entity.RNG.NextFloat() + 0.5;
        var volume = entity.HasBuff(NoteBlockLoudBuff) ? 5 : 1;
        entity.PlaySound(VanillaSoundID.harp, pitch, volume);
    }
    public static function GetNoteChildren(entity:Entity):Null<Array<EntityID>>
    {
        return entity.GetBehaviourField(PROP_NOTE_CHILDREN);
    }
    public static function AddNoteChild(entity:Entity, child:Entity):Void
    {
        var children = GetNoteChildren(entity);
        if (children == null)
        {
            children = [];
            entity.SetBehaviourField(PROP_NOTE_CHILDREN, children);
        }
        children.push(new EntityID(child));
    }
    public static function ResetNoteTimeout(noteblock:Entity, note:Entity):Void
    {
        note.Timeout = Mathf.FloorToInt(noteblock.GetRange() / noteblock.GetShotVelocity().magnitude);
    }
    public static inline var EVOCATION_CHARGED_DAMAGE:Float = 600;
    public static inline var FIRE_INTERVAL:Int = 45;
    public static inline var MAX_NOTE_COUNT:Int = 10;
    static var PROP_NOTE_CHILDREN:VanillaEntityPropertyMeta<Array<EntityID>> = new VanillaEntityPropertyMeta<Array<EntityID>>("NoteChildren");
}
