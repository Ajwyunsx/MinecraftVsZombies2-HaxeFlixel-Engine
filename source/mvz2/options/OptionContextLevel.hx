// Ported from: Assets/Scripts/MVZ2/Options/Dialog/OptionContextLevel.cs
package mvz2.options;

import mvz2logic.options.IOptionContext.IOptionContextLevel;
import pvzengine.level.LevelEngine;

class OptionContextLevel extends OptionContext implements IOptionContextLevel {
    public function new(level:LevelEngine) {
        super();
        this.level = level;
    }
    public function GetLevel():LevelEngine {
        return level;
    }
    public var level:LevelEngine;
}
