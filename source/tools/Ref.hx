// Ported from: (Haxe shim) C# `ref` 参数等价物
package tools;

// PORT-NOTE: C# 的 `ref T` 参数在 Haxe 中没有直接对应语法（基本类型按值传递）。
// 使用该包装类在原位保持引用语义：调用方 `p.value` 读写，被调用方通过同一实例修改。
class Ref<T>
{
    public var value:T;

    public function new(value:T)
    {
        this.value = value;
    }
    public static function to<T>(value:T):Ref<T>
    {
        return new Ref<T>(value);
    }
}
