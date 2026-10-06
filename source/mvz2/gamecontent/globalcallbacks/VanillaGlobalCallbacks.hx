// Ported from: Assets/Scripts/Vanilla/GameContent/GlobalCallbacks/VanillaGlobalCallbacks.cs
package mvz2.gamecontent.globalcallbacks;

import mvz2logic.modding.IGlobalCallbacks;
import mvz2logic.modding.Mod;

class VanillaGlobalCallbacks implements IGlobalCallbacks
{
    // PORT-NOTE: C# 抽象基类带隐式无参构造函数，ModLoader 用 `Activator.CreateInstance(type)`
    //   无参构造 `[ModGlobalCallbacks]` 标注的派生类（见 Assets/Scripts/MVZ2/Modding/ModLoader.cs）。
    //   Haxe 不会为缺少构造函数的类合成构造函数，此处显式声明以保证 17 个子类可无参实例化。
    public function new() {}
    public function Apply(mod:Mod):Void throw "abstract";
}
