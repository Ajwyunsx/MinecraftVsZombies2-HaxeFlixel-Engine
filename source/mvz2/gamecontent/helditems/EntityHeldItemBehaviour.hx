// Ported from: Assets/Scripts/Vanilla/GameContent/HeldItems/Behaviours/Entity/EntityHeldItemBehaviour.cs
package mvz2.gamecontent.helditems;

import mvz2logic.helditems.HeldItemBehaviourDefinition;
import mvz2logic.helditems.IHeldItemData;
import mvz2logic.helditems.IHeldItemTarget;
import mvz2logic.level.LogicHeldItemProps;
import pvzengine.entities.Entity;
import pvzengine.level.LevelEngine;

// abstract
class EntityHeldItemBehaviour extends HeldItemBehaviourDefinition
{
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
    // TODO-PORT: C# 重载 GetEntity(LevelEngine, IHeldItemData) 与 GetEntity(IHeldItemTarget, IHeldItemData)，
    // Haxe 不支持重载，目标版本的重载重命名为 GetEntityOfTarget。
    public function GetEntity(level:LevelEngine, data:IHeldItemData):Null<Entity>
    {
        var entityId = LogicHeldItemProps.GetEntityID(data);
        return level.FindEntityByID(entityId);
    }
    public function GetEntityOfTarget(target:IHeldItemTarget, data:IHeldItemData):Null<Entity>
    {
        return GetEntity(target.GetLevel(), data);
    }
}
