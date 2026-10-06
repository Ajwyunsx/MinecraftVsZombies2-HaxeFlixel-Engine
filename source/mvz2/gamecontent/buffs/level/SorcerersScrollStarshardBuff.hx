// Ported from: Assets/Scripts/Vanilla/GameContent/Buffs/Level/Chapter5/SorcerersScrollStarshardBuff.cs
package mvz2.gamecontent.buffs.level;

import mvz2.gamecontent.buffs.VanillaBuffNames;
import mvz2.gamecontent.helditems.VanillaHeldTypes;
import mvz2.gamecontent.sprites.VanillaSprites;
import mvz2logic.level.LogicAreaProps;
import mvz2logic.level.LogicLevelProps;
import mvz2logic.modifiers.SpriteReferenceModifier;
import pvzengine.definitions.BuffDefinition;
import pvzengine.modifiers.NamespaceIDModifier;
import pvzengine.modifiers.SetOperator;

@:autoBuffDefinition(VanillaBuffNames.Level_sorcerersScrollStarshard)
class SorcerersScrollStarshardBuff extends BuffDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
        AddModifier(new SpriteReferenceModifier(LogicAreaProps.STARSHARD_ICON, SetOperator.Set, VanillaSprites.combat));
        AddModifier(new NamespaceIDModifier(LogicLevelProps.STARSHARD_HELD_TYPE, SetOperator.Set, VanillaHeldTypes.combat));
    }
}
