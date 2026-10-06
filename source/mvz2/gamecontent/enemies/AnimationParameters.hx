// Ported from: Assets/Scripts/Vanilla/GameContent/Enemies/Animation/HumanoidAnimationBehaviour.cs
package mvz2.gamecontent.enemies;

// PORT-NOTE: C# 的嵌套 struct HumanoidAnimationBehaviour.AnimationParameters 提升为顶层类，便于跨文件引用。
class AnimationParameters
{
    public function new(dead:Bool = false, walkState:Int = 0, armState:Int = 0, specialState:Int = 0)
    {
        this.dead = dead;
        this.walkState = walkState;
        this.armState = armState;
        this.specialState = specialState;
    }
    public var dead:Bool;
    public var walkState:Int;
    public var armState:Int;
    public var specialState:Int;
}
