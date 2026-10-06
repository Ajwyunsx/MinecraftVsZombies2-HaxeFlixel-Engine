// Ported from: Assets/Scripts/Vanilla/GameContent/Effects/EffectBehaviour.cs
package mvz2.gamecontent.effects;

import pvzengine.definitions.EntityBehaviourDefinition;

// abstract
class EffectBehaviour extends EntityBehaviourDefinition
{
    // PORT-NOTE: C# 的 protected 构造函数在 Haxe 的包外子类中不可用，此处保持 public。
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
}
