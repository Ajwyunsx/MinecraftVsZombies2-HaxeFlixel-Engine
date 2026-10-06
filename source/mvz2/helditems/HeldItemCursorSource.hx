package mvz2.helditems;

import mvz2.level.LevelController;
import mvz2logic.cursor.CursorSource;
import mvz2logic.cursor.CursorType;

// Ported from: Assets/Scripts/MVZ2/HeldItems/HeldItemCursorSource.cs
class HeldItemCursorSource extends CursorSource {
    public function new(level:LevelController) {
        levelController = level;
    }
    // PORT-NOTE: C# `public override CursorType CursorType => CursorType.Empty;`
    // 父类 CursorSource 已声明属性，Haxe 子类只能覆盖 getter，不能重新声明属性行。
    // 表达式位置的 `CursorType` 会被同名属性遮蔽，故枚举需写全限定名。
    override private function get_CursorType():CursorType return mvz2logic.cursor.CursorType.Empty;

    override private function get_Priority():Int return -100;

    override public function IsValid():Bool {
        return levelController != null;
    }
    private var levelController:LevelController;
}
