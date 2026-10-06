// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/EnemyBehaviour.cs
package mvz2.gamecontent.enemies;

import mvz2.gamecontent.entities.AIEntityBehaviour;

// abstract
class EnemyBehaviour extends AIEntityBehaviour
{
    // PORT-NOTE: C# 的 protected 构造函数在 Haxe 的包外子类中不可用，此处保持 public。
    public function new(nsp:String, name:String)
    {
        super(nsp, name);
    }
}
