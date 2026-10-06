// Ported from: Assets/Scripts/Logic/Entities/IEnemyAnimationBehaviour.cs
package mvz2logic.entities;

import pvzengine.entities.Entity;

interface IEnemyAnimationBehaviour
{
	function UpdateAnimationParameters(entity:Entity, state:Int):Void;
}
