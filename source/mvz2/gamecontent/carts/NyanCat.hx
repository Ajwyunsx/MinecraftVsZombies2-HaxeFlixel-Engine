// Ported from: Assets/Scripts/Vanilla/GameContent/Carts/NyanCat.cs
package mvz2.gamecontent.carts;

import mvz2.gamecontent.areas.Dream;
import mvz2.gamecontent.carts.VanillaCartID.VanillaCartNames;
import mvz2.vanilla.audios.VanillaSoundID;
import mvz2.vanilla.carts.VanillaCartExt;
import mvz2.vanilla.carts.VanillaCartProps;
import pvzengine.entities.Entity;

@:autoEntityBehaviourDefinition(VanillaCartNames.nyanCat)
class NyanCat extends CartBehaviour
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    public override function Init(entity:Entity):Void
    {
        super.Init(entity);
        UpdateNyaightmareToLevel(entity);
    }
    public override function Update(entity:Entity):Void
    {
        super.Update(entity);
        entity.SetAnimationBool("Running", VanillaCartExt.IsCartTriggered(entity));
    }
    public static function SetNyaightmare(entity:Entity, value:Bool):Void
    {
        entity.SetModelProperty("Nyaightmare", value);
        VanillaCartProps.SetCartTriggerSound(entity, value ? VanillaSoundID.nyaightmareScream : VanillaSoundID.meow);
    }
    public static function UpdateNyaightmareToLevel(entity:Entity):Void
    {
        var isNightmare = Dream.IsNightmare(entity.Level);
        SetNyaightmare(entity, isNightmare);
    }
}
