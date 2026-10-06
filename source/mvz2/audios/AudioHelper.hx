package mvz2.audios;

import unity.Mathf;

// Ported from: Assets/Scripts/MVZ2/Audios/AudioHelper.cs
class AudioHelper {
    private function new() {}

    public static function PercentageToDbA(p:Float):Float {
        if (p == 0)
            return -80;
        return 20 * Mathf.Log10(p);
    }
}
