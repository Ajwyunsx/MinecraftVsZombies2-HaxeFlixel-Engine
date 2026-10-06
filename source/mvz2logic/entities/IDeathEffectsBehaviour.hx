// Ported from: Assets/Scripts/Logic/Entities/IDeathEffectsBehaviour.cs
package mvz2logic.entities;

import pvzengine.damages.DeathInfo;
import pvzengine.entities.Entity;

interface IDeathEffectsBehaviour
{
	function DeathEffects(entity:Entity, deathInfo:DeathInfo):Void;
}
