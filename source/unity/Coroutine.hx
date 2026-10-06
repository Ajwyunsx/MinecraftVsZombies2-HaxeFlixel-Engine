package unity;

// Minimal coroutine stepper per PORTING.md §协程.
// C# IEnumerator/yield is translated to Coroutine.create(function(co:CoroutineContext) {...}).

// 挂起信号：Haxe 没有 C# 编译器生成的 IEnumerator 状态机，无法从函数体中间"恢复执行"，
// 也没有 continue/goto，因此用抛出对象的方式从函数体中间退出。用类实例做身份比较
// （而非异常类型或匿名结构），这样协程体里针对业务异常的 try/catch 不会误吞挂起信号。
private class SuspendSignal {
    public function new() {}
}

class Coroutine {
    // PORT-NOTE: 原为 (default, null)，但 CoroutineContext.yieldBreak() 需要写入，
    // 且 CoroutineRunner 也会置位；Haxe 的 default,null 无法跨类写入，故放开为普通字段（外部仍只读）。
    public var finished:Bool = false;
    private var steps:CoroutineContext->Void;

    // ===== 步进状态（重放模型）=====
    // PORT-NOTE: C# 的 IEnumerator 由编译器改写成状态机，可以真正"从 yield 处继续执行"。
    //   移植层只有一个 `CoroutineContext->Void` 函数体，无法在其内部保存指令指针
    //   （这正是本文件原先 TODO-PORT 说的「需要 CPS 变换」），因此采用**重放**：
    //   每次恢复都从函数体开头重新执行，函数体内的挂起点（wait / waitFrames /
    //   waitCoroutine）按遇到顺序编号；编号小于「已完成的挂起点数」的挂起点直接放行
    //   （视为历史），只有下一个未完成的挂起点才真正挂起（抛 SuspendSignal 退出函数体）。
    //   由此得到两条保证：
    //     1. 等待条件未满足时只递减等待条件、不重放函数体
    //        （waitFramesLeft / waitSeconds 不会被重复消耗）；
    //     2. **一次 update 只消耗一个挂起点**，所以 `while (...) co.waitFrames(1);`
    //        不会在同一帧里把整个循环跑完 —— 这是原占位实现完全做不到的。
    //   **固有取舍（重要）**：重放会重新初始化函数体的局部变量，并重新执行当前挂起点
    //   之前的语句（包括此前已完成的循环迭代）。因此只有「局部状态可重算 + 挂起点之前
    //   副作用幂等」的协程体才与 C# 等价。工程里的主流写法正好满足：
    //     `while (time < maxTime) { time = clamp(time + Time.deltaTime, 0, maxTime);
    //        camera.SetPosition(lerp(start, target, time / maxTime)); co.waitFrames(1); }`
    //   —— time 是局部量、每帧按 deltaTime 推进，SetPosition 为幂等写入；第 k 帧结束时
    //   time == k*deltaTime，与 C# 的观感一致，代价只是每帧重算前 k 次迭代（O(挂起点数²)）。
    //   两类写法**不**等价，需要改写调用点（两类都在本文件的注释里说明）：
    //     a) `var inner = SomeFactory(); while (!inner.finished) co.waitFrames(1);`
    //        —— 重放会重新调用工厂，得到一个全新的、无人驱动的子协程，循环永不退出。
    //        正确写法是 `co.waitCoroutine(SomeFactory())`（本文件已支持，且会自动驱动子协程）。
    //        **工程里原有的 9 处（LevelController 6 处 / LevelBlueprintChooseController 3 处）
    //        已全部改写为 waitCoroutine**；`VanillaChapterTransitions.WaitCoroutine` 也一并修正
    //        （原先只是把子协程丢给一个从未被步进的静态 runner，且没有挂起父协程）。
    //        回归护栏：`tools_build/check_level_chain.sh`（⑥ 钉住错误写法仍会挂住，⑤ 钉住正确写法会结束）。
    //        写法约定已写入 PORTING.md §协程。
    //     b) 循环体内含非幂等副作用（如 ResourceManager.ShotModelIcons 的 `yieldCounter++`
    //        与逐项 ShotIcon 调用）—— 之前已完成的迭代会被重放重复执行：进度条仍单调前进、
    //        最终也能跑完，但重复的截图工作会让这段加载变慢（O(挂起点数²) 的直接体现）。
    //        要消除重复工作，需把累计量提到字段，或改成 waitCoroutine 分帧。
    //   要彻底消除该取舍，需要把协程体做 CPS 变换（宏或改写调用点），超出本文件范围。
    private var context:CoroutineContext = null;
    // 已完成的挂起点数：重放时编号 < 它的挂起点直接放行。
    private var completedWaits:Int = 0;
    // 本次重放已经遇到的挂起点个数。
    private var visitIndex:Int = 0;
    // true 表示正处在等待中：下次 update 只需递减等待条件，不必重放函数体。
    private var waiting:Bool = false;
    // 是否已经被 resume 过。用于 CoroutineRunner 判断「这个子协程是否已有人驱动」，
    // 避免 waitCoroutine 对已被其它 runner 启动的子协程重复步进。
    private var started:Bool = false;

    public function new(steps:CoroutineContext->Void) {
        this.steps = steps;
    }

    public static function create(steps:CoroutineContext->Void):Coroutine {
        return new Coroutine(steps);
    }

    @:allow(unity.CoroutineContext)
    private static var suspendSignal:Dynamic = new SuspendSignal();

    @:allow(unity.CoroutineContext)
    @:allow(unity.CoroutineRunner)
    private function contextOf():CoroutineContext {
        if (context == null) context = new CoroutineContext(this);
        return context;
    }

    @:allow(unity.CoroutineRunner)
    private function isWaiting():Bool {
        return waiting;
    }

    @:allow(unity.CoroutineRunner)
    private function hasStarted():Bool {
        return started;
    }

    // 由 CoroutineContext 的挂起 API 调用：判断当前挂起点是否属于「已完成的历史」。
    // 返回 true 表示调用方应立即返回、继续执行该挂起点之后的语句。
    @:allow(unity.CoroutineContext)
    private function replayPastWait():Bool {
        var past = visitIndex < completedWaits;
        visitIndex++;
        return past;
    }

    // 在当前挂起点真正挂起：退出函数体，等待条件由 CoroutineRunner 逐帧递减。
    @:allow(unity.CoroutineContext)
    private function suspendNow():Void {
        waiting = true;
        throw suspendSignal;
    }

    // 执行/恢复函数体：从开头重放到「下一个未完成的挂起点」（或函数体结束）。
    // 由 CoroutineRunner.start（首段同步执行）与 update（等待结束后续跑）调用。
    @:allow(unity.CoroutineRunner)
    private function resume():Void {
        if (finished) return;
        if (waiting) {
            // 被调用时仍处于等待中，说明调用方已确认等待结束，该挂起点到此完成。
            waiting = false;
            completedWaits++;
        }
        started = true;
        visitIndex = 0;
        try {
            steps(contextOf());
        } catch (e:Dynamic) {
            if (e == suspendSignal) return; // 正常挂起。
            // PORT-NOTE: 非挂起异常不在这一层吞掉 —— 移植层由 MainGameScene.update 的
            //   逐组件 try/catch 承担「Unity 引擎边界」的职责（记录日志并停掉该组件的协程步进）。
            //   在这里吞掉会让真实错误只剩日志，且会掩盖调用点的 bug。
            throw e;
        }
        // 函数体正常返回。
        if (waiting) {
            // PORT-NOTE: 走到这里说明挂起信号被协程体内部的 `catch (e:Dynamic)` 吞掉了
            //   （C# 不允许 yield 出现在 try/catch 里，所以 1:1 移植的协程体不该出现这种写法；
            //   工程里 26 个协程体也确实没有 try/catch）。兜底：此时协程仍在等待，
            //   绝不能当成「函数体跑完」而置 finished —— 否则该协程会被静默丢弃、后续语句永不执行。
            //   保留 waiting，下一帧照常递减等待条件并恢复。
            return;
        }
        // 函数体跑完 → 协程结束。
        finished = true;
    }
}

// Executes a coroutine body; wait/waitFrames/yieldBreak pause execution.
class CoroutineContext {
    public var coroutine:Coroutine;

    public function new(coroutine:Coroutine) {
        this.coroutine = coroutine;
    }

    // 等待若干秒；由 CoroutineRunner.update 传入的帧间隔（elapsed）逐帧递减。
    public function wait(seconds:Float):Void {
        if (coroutine.replayPastWait()) return;
        waitSeconds = seconds;
        waitFramesLeft = 0;
        waitingCoroutine = null;
        coroutine.suspendNow();
    }
    public function waitFrames(frames:Int):Void {
        if (coroutine.replayPastWait()) return;
        waitFramesLeft = frames;
        waitSeconds = 0;
        waitingCoroutine = null;
        coroutine.suspendNow();
    }
    public function yieldBreak():Void {
        // C# 的 yield break：协程立即结束，其后的语句不再执行。
        coroutine.finished = true;
        coroutine.suspendNow();
    }
    // C#: `yield return StartCoroutine(sub)` / `yield return Sub();` —— 挂起当前协程直到子协程结束。
    public function waitCoroutine(routine:Coroutine):Void {
        if (coroutine.replayPastWait()) return;
        waitingCoroutine = routine;
        waitSeconds = 0;
        waitFramesLeft = 0;
        coroutine.suspendNow();
    }

    @:allow(unity.CoroutineRunner)
    private var waitSeconds:Float = 0;
    @:allow(unity.CoroutineRunner)
    private var waitFramesLeft:Int = 0;
    @:allow(unity.CoroutineRunner)
    private var waitingCoroutine:Coroutine = null;
}

class CoroutineRunner {
    private var running:Array<Coroutine> = [];

    public function new() {}

    public function start(routine:Coroutine):Coroutine {
        if (routine != null && !running.contains(routine)) {
            running.push(routine);
            // PORT-NOTE: Unity 的 StartCoroutine 会同步执行到第一个 yield，这里保持一致，
            //   否则协程体的第一段（如 Music.Play、UI 置位）会白白晚一帧才生效。
            //   但只对「尚未跑过」的协程做这一步：若它已经在等待中（例如被 stop 后重新 start，
            //   或被另一个 runner 启动过），再 resume 会把这个挂起点当成已完成而提前放行。
            if (!routine.hasStarted()) routine.resume();
            if (routine.finished) running.remove(routine);
        }
        return routine;
    }
    public function stop(routine:Coroutine):Void {
        running.remove(routine);
    }
    public function stopAll():Void {
        running = [];
    }

    /**
     * 是否没有任何在跑的协程。
     *
     * PORT-NOTE: 移植层新增（C# 无对应成员）。`BehaviourRegistry` 会登记**全部**
     * `AddComponent` 建出来的组件（关卡场景树 2100 个），其中绝大多数从不启动协程；
     * 帧循环用本属性把「空 runner」整批跳过，避免为每个组件做一次数组遍历/分配。
     */
    public var isEmpty(get, never):Bool;
    inline function get_isEmpty():Bool return running.length == 0;

    // Called by the owning behaviour's update loop.
    public function update(elapsed:Float):Void {
        // PORT-NOTE: 空跑早退。`BehaviourRegistry` 会把**全部** AddComponent 建出来的组件都纳入
        //   每帧步进（关卡场景树 2100 个组件里绝大多数是 Image/CanvasRenderer 这类从不启动协程的
        //   组件），若在这里无条件 `running.copy()`，每帧会白白分配上千个空数组。
        //   对空 runner 直接返回，行为完全不变（原本遍历空数组也不做任何事）。
        if (running.length == 0) return;
        // PORT-NOTE: 先取快照再步进 —— resume() 期间协程体可能启动/停止其它协程
        //   （waitCoroutine 驱动子协程、或协程体调用 StopAllCoroutines），
        //   直接按 running 的下标遍历会读到已被移除的槽位。快照也顺带保证
        //   「本帧新启动的协程下一帧才步进」。
        var frame = running.copy();
        for (routine in frame) {
            if (routine.finished || !running.contains(routine)) continue;
            if (!routine.isWaiting() || tickWait(routine, elapsed)) routine.resume();
        }
        // 统一清理本帧结束的协程。
        var i = running.length - 1;
        while (i >= 0) {
            if (running[i].finished) running.remove(running[i]);
            i--;
        }
    }

    // 递减一个协程的等待条件；返回 true 表示等待结束、本次 update 应继续执行其函数体。
    private function tickWait(routine:Coroutine, elapsed:Float):Bool {
        var co = routine.contextOf();
        if (co.waitingCoroutine != null) {
            var child = co.waitingCoroutine;
            if (!child.finished) {
                // PORT-NOTE: C# 的 `yield return Sub();` 由 Unity 引擎负责驱动子协程；
                //   移植层若子协程没有被显式 StartCoroutine，就必须在这里接手驱动，
                //   否则父协程会永远等下去。仅在子协程尚未被任何 runner resume 过时接手，
                //   以免与另一个 runner（如 VanillaChapterTransitions 的静态 runner）重复步进。
                if (!child.hasStarted() && !running.contains(child)) running.push(child);
                return false;
            }
            co.waitingCoroutine = null;
            return true;
        }
        if (co.waitFramesLeft > 0) {
            co.waitFramesLeft--;
            return co.waitFramesLeft <= 0;
        }
        if (co.waitSeconds > 0) {
            // PORT-NOTE: elapsed 为 0（如 FlxG.elapsed 尚未产生首帧时长）时若按 0 递减，
            //   wait(seconds) 会永远等待、把游戏卡死。这里用标称帧时长兜底，
            //   保证最坏情况下只是计时偏快一帧，而不是挂死。
            var dt = elapsed > 0 ? elapsed : 1.0 / 60.0;
            co.waitSeconds -= dt;
            return co.waitSeconds <= 0;
        }
        // wait(0) / waitFrames(0)：只让出一个 update，等价 C# 的 `yield return null`。
        return true;
    }
}
