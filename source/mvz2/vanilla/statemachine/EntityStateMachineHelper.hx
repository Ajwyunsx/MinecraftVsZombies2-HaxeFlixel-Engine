// Ported from: Assets/Scripts/Vanilla/Frameworks/StateMachine/EntityStateMachineHelper.cs
package mvz2.vanilla.statemachine;

class EntityStateMachineHelper
{
    public static function FindNextStateIndex(states:Array<Int>, currentIndex:Int, predicate:Int->Bool):Int
    {
        var length = states.length;
        if (length <= 0)
            return -1;
        if (currentIndex < 0)
        {
            currentIndex = 0;
        }
        for (i in 0...length)
        {
            var index = (currentIndex + i) % length;
            var state = states[index];
            if (!predicate(state))
                continue;
            return index;
        }
        return -1;
    }
}
