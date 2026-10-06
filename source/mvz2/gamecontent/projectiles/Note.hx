// Ported from: Assets/Scripts/Vanilla/GameContent/Projectiles/Chapter4/Note.cs
package mvz2.gamecontent.projectiles;

import mvz2.gamecontent.contraptions.NoteBlock;
import mvz2.gamecontent.contraptions.VanillaContraptionID;
import mvz2.vanilla.callbacks.VanillaCallbackPriorities;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PostProjectileHitParams;
import mvz2.vanilla.callbacks.VanillaLevelCallbacks.PreProjectileHitParams;
import mvz2.vanilla.entities.VanillaColliderExt;
import mvz2.vanilla.entities.VanillaEntityProps;
import mvz2.vanilla.properties.VanillaEntityPropertyMeta;
import mvz2logic.entities.LogicEntityProps;
import pvzengine.callbacks.CallbackResult;
import pvzengine.collisions.IEntityCollider;
import pvzengine.definitions.EntityBehaviourDefinition;
import pvzengine.entities.EngineEntityProps;
import pvzengine.entities.Entity;
import pvzengine.entities.EntityCollision;
import pvzengine.entities.EntityCollisionHelper;
import pvzengine.modifiers.FloatModifier;
import pvzengine.modifiers.NumberOperator;
import pvzengine.modifiers.Vector3Modifier;
import unity.Mathf;
import unity.Vector3;
using mvz2.vanilla.entities.VanillaColliderExt;
using mvz2.vanilla.entities.VanillaEntityExt;
using mvz2.vanilla.entities.VanillaEntityProps;
using mvz2.vanilla.projectiles.VanillaProjectileProps;

@:autoEntityBehaviourDefinition(VanillaProjectileNames.note)
class Note extends EntityBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new Vector3Modifier(EngineEntityProps.DISPLAY_SCALE, NumberOperator.Multiply, PROP_DISPLAY_SCALE_MULTIPLIER));
        AddModifier(new Vector3Modifier(LogicEntityProps.SHADOW_SCALE, NumberOperator.Multiply, PROP_DISPLAY_SCALE_MULTIPLIER));
        AddModifier(new FloatModifier(VanillaEntityProps.DAMAGE, NumberOperator.Multiply, PROP_DAMAGE_GROWTH));
        AddTrigger(VanillaLevelCallbacks.PRE_PROJECTILE_HIT, PreHitEntityCallback, VanillaCallbackPriorities.EARLY);
        AddTrigger(VanillaLevelCallbacks.POST_PROJECTILE_HIT, PostHitEntityCallback, VanillaCallbackPriorities.LATE);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        entity.CollisionMaskFriendly |= EntityCollisionHelper.MASK_PLANT;
        SetDamageGrowth(entity, MIN_GROWTH);
    }
    public override function Update(projectile:Entity):Void
    {
        super.Update(projectile);
        var dmg = projectile.GetDamage();
        var definitionDamage = VanillaEntityProps.GetDamageOfDefinition(projectile.Definition);
        projectile.SetProperty(PROP_DISPLAY_SCALE_MULTIPLIER, Vector3.one * Mathf.Min(5, Mathf.Pow(dmg / definitionDamage / 2, 0.5)));
        SetHitProtected(projectile, false);

        var growth = GetDamageGrowth(projectile);
        growth = Mathf.Clamp(Mathf.Lerp(growth, MAX_GROWTH, GROWTH_LERP_T), MIN_GROWTH, MAX_GROWTH);
        SetDamageGrowth(projectile, growth);
    }
    private function PreHitEntityCallback(param:PreProjectileHitParams, result:CallbackResult):Void
    {
        var hit = param.hit;
        var projectile = hit.Projectile;
        if (!projectile.Definition.HasBehaviour(this))
            return;
        var damage = param.damage;
        if (IsHitProtected(projectile))
        {
            result.SetFinalValue(false);
        }
    }
    private function PostHitEntityCallback(param:PostProjectileHitParams, result:CallbackResult):Void
    {
        var hitResult = param.hit;
        var projectile = hitResult.Projectile;
        if (!projectile.Definition.HasBehaviour(this))
            return;
        var damage = param.damage;
        Reflect(projectile, hitResult.Collider);

        SetHitProtected(projectile, true);
        SetNoteCharged(projectile, false);

        var dmg = projectile.GetDamage(true);
        dmg--;
        projectile.SetDamage(dmg);
        if (dmg <= 0)
        {
            projectile.Remove();
        }

        projectile.Timeout = 900;
    }
    public override function PostCollision(collision:EntityCollision, state:Int):Void
    {
        super.PostCollision(collision, state);
        if (state == EntityCollisionHelper.STATE_EXIT)
            return;
        var note = collision.Entity;
        var noteBlock = collision.Other;
        if (!noteBlock.IsEntityOf(VanillaContraptionID.noteBlock))
            return;
        if (IsNoteCharged(note))
            return;
        if (!collision.OtherCollider.IsMainCollider())
            return;
        if (note.Parent != noteBlock || !note.IsFriendly(noteBlock))
            return;
        note.SetDamage(noteBlock.GetDamage());
        SetDamageGrowth(note, MIN_GROWTH);
        note.Velocity = noteBlock.GetFacingDirection() * noteBlock.GetShotVelocity().magnitude;
        SetNoteCharged(note, true);
        SetHitProtected(note, false);
        note.ClearIgnoredProjectileColliders();

        NoteBlock.ResetNoteTimeout(noteBlock, note);

        noteBlock.TriggerAnimation("Shoot");
        NoteBlock.PlayHarpSound(noteBlock);
    }
    public static function Reflect(note:Entity, other:IEntityCollider):Void
    {
        var vel = note.Velocity;
        var magnitude = vel.magnitude;
        var otherPosition = other.GetBoundingBox().center;
        if (vel.x > 0)
        {
            // 正在向右飞，只要撞到左侧就会反弹
            var minX = note.GetBounds().min.x;
            if (minX <= otherPosition.x)
            {
                vel = Vector3.left * magnitude;
            }
        }
        else
        {
            // 正在向左飞，只要撞到右侧就会反弹
            var maxX = note.GetBounds().max.x;
            if (maxX >= otherPosition.x)
            {
                vel = Vector3.right * magnitude;
            }
        }
        note.Velocity = vel;
    }
    public static function SetHitProtected(note:Entity, value:Bool):Void note.SetBehaviourField(PROP_HIT_PROTECTED, value);
    public static function IsHitProtected(note:Entity):Bool return note.GetBehaviourField(PROP_HIT_PROTECTED);
    public static function SetNoteCharged(note:Entity, value:Bool):Void note.SetBehaviourField(PROP_NOTE_CHARGED, value);
    public static function IsNoteCharged(note:Entity):Bool return note.GetBehaviourField(PROP_NOTE_CHARGED);
    public static function SetDamageGrowth(note:Entity, value:Float):Void note.SetBehaviourField(PROP_DAMAGE_GROWTH, value);
    public static function GetDamageGrowth(note:Entity):Float return note.GetBehaviourField(PROP_DAMAGE_GROWTH);

    public static inline var MIN_GROWTH:Float = 0.1;
    public static inline var MAX_GROWTH:Float = 1;
    public static inline var GROWTH_LERP_T:Float = 0.25;

    private static var PROP_DISPLAY_SCALE_MULTIPLIER:VanillaEntityPropertyMeta<Vector3> = new VanillaEntityPropertyMeta<Vector3>("DisplayScaleMultiplier");
    private static var PROP_HIT_PROTECTED:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("HitProtected");
    private static var PROP_NOTE_CHARGED:VanillaEntityPropertyMeta<Bool> = new VanillaEntityPropertyMeta<Bool>("NoteCharged");
    private static var PROP_DAMAGE_GROWTH:VanillaEntityPropertyMeta<Float> = new VanillaEntityPropertyMeta<Float>("DamageGrowth");
}
