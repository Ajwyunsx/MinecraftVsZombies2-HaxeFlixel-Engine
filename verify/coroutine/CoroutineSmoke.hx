// PORT-NOTE: 验证用（不参与游戏构建）。unity.Coroutine 协程步进器的运行探针。
//
// 背景：source/unity/Coroutine.hx 原先的 CoroutineRunner.update 只清理 finished 的协程，
//   从不执行 steps，waitFrames/waitSeconds/waitingCoroutine 也无人消费 —— 任何带挂起的
//   协程（关卡开始/结束过渡、相机移动、资源加载分帧）都会在第一段之后永久卡住。
//   本探针逐条断言步进器的可观察行为，作为该修复的回归护栏。
//
// 关于「进度」的度量：步进器用重放（replay）实现恢复，函数体每次恢复都从头重跑，
//   因此**非幂等副作用**（`counter++`）会被重复执行、不能用来度量真实进度。
//   探针里的进度一律用工程协程体的真实写法度量：局部累计量 + 幂等写入
//   （`t = t + step; progress = t;`，对应 LevelController.MoveCameraLawn）。
//   重放自身的取舍由 ⑬ 单独钉住。
//
// 运行：bash HaxePort/tools_build/check_coroutine.sh          # neko（快）
//       bash HaxePort/tools_build/check_coroutine.sh --cpp    # 与游戏同一目标

package coroutine;

import unity.Coroutine;
import unity.Coroutine.CoroutineContext;
import unity.Coroutine.CoroutineRunner;

class CoroutineSmoke {
    static var failures:Array<String> = [];
    static var checks:Int = 0;

    static function check(label:String, cond:Bool, detail:String = ""):Void {
        checks++;
        if (cond) {
            Sys.println('  [ok]   $label');
        } else {
            failures.push(label + (detail == "" ? "" : ' ($detail)'));
            Sys.println('  [FAIL] $label${detail == "" ? "" : " (" + detail + ")"}');
        }
    }

    static function eq(label:String, actual:Dynamic, expected:Dynamic):Void {
        check(label, actual == expected, 'actual=${Std.string(actual)} expected=${Std.string(expected)}');
    }

    // 一帧的标称时长（探针里固定，便于精确断言帧数）。
    static inline var DT:Float = 1 / 60;
    // 二进制精确的步长/时长，用于边界断言（避免浮点误差）。
    static inline var STEP:Float = 1 / 64;
    static inline var WAIT_EXACT:Float = 0.25;

    static function main():Void {
        Sys.println('[CoroutineSmoke] unity.Coroutine 步进器探针');

        testRunsToFirstYieldOnStart();
        testWaitFrames();
        testWaitSeconds();
        testSequentialWaitsOrder();
        testWaitCoroutine();
        testWaitCoroutineDrivesUnstartedChild();
        testYieldBreak();
        testPollingLoopAdvancesOneStepPerUpdate();
        testStopAndStopAll();
        testWaitZeroYieldsOneFrame();
        testExceptionPropagates();
        testFinishedCoroutineLeavesRunning();
        testReplayLimitations();
        testRestartDoesNotSkipWait();

        Sys.println('');
        if (failures.length == 0) {
            Sys.println('[CoroutineSmoke] 全部通过（$checks 项断言）');
            Sys.exit(0);
        } else {
            Sys.println('[CoroutineSmoke] 失败 ${failures.length} 项 / 共 $checks 项：');
            for (f in failures) Sys.println('  - $f');
            Sys.exit(1);
        }
    }

    // ① start() 同步执行到第一个挂起点（Unity StartCoroutine 语义）。
    static function testRunsToFirstYieldOnStart():Void {
        Sys.println('');
        Sys.println('① start() 同步执行到第一个挂起点');
        var before = false;
        var after = false;
        var runner = new CoroutineRunner();
        var c = Coroutine.create(function(co:CoroutineContext) {
            before = true;
            co.waitFrames(1);
            after = true;
        });
        runner.start(c);
        check("start 后已执行挂起点之前的语句", before);
        check("start 后未执行挂起点之后的语句", !after);
        check("start 后协程未结束", !c.finished);

        runner.update(DT);
        check("一次 update 后越过 waitFrames(1)", after);
        check("函数体跑完后 finished=true", c.finished);
    }

    // ② waitFrames(n)：恰好 n 次 update 之后恢复。
    static function testWaitFrames():Void {
        Sys.println('');
        Sys.println('② waitFrames(n) 按帧数恢复');
        var observed = 0;
        var runner = new CoroutineRunner();
        var c = Coroutine.create(function(co:CoroutineContext) {
            co.waitFrames(3);
            observed = 1;
        });
        runner.start(c);
        eq("起始未恢复", observed, 0);

        runner.update(DT);
        eq("第 1 帧未恢复", observed, 0);
        runner.update(DT);
        eq("第 2 帧未恢复", observed, 0);
        runner.update(DT);
        eq("第 3 帧恢复", observed, 1);
        check("恢复后协程结束", c.finished);

        // 多段挂起：每段各按自己的帧数计。
        var phase = "";
        var r2 = new CoroutineRunner();
        var c2 = Coroutine.create(function(co:CoroutineContext) {
            co.waitFrames(2);
            phase = "p1";
            co.waitFrames(1);
            phase = "p2";
        });
        r2.start(c2);
        eq("首个挂起点前无输出", phase, "");
        r2.update(DT);
        eq("第 1 帧仍在第一个等待中", phase, "");
        r2.update(DT);
        eq("第 2 帧越过第一个等待", phase, "p1");
        r2.update(DT);
        eq("第 3 帧越过第二个等待", phase, "p2");
        check("多段挂起后结束", c2.finished);
    }

    // ③ wait(seconds)：按 elapsed 累加恢复。
    static function testWaitSeconds():Void {
        Sys.println('');
        Sys.println('③ wait(seconds) 按 elapsed 恢复');
        var observed = 0;
        var runner = new CoroutineRunner();
        var c = Coroutine.create(function(co:CoroutineContext) {
            co.wait(WAIT_EXACT);
            observed = 1;
        });
        runner.start(c);
        eq("起始未恢复", observed, 0);

        // WAIT_EXACT / STEP = 0.25 / (1/64) = 恰好 16 帧（二进制精确，无浮点边界问题）。
        var frames = 0;
        var premature = false;
        while (!c.finished && frames < 100) {
            runner.update(STEP);
            frames++;
            if (frames < 16 && observed != 0) premature = true;
        }
        check("等待期间未提前恢复", !premature);
        eq("0.25 秒 / (1/64) 步长 = 16 帧", frames, 16);
        eq("第 16 帧恢复", observed, 1);

        // 不同大小的 elapsed：0.1 秒在 0.03 步长下需要 4 帧（累计 0.12 秒）。
        var done = false;
        var r2 = new CoroutineRunner();
        r2.start(Coroutine.create(function(co:CoroutineContext) {
            co.wait(0.1);
            done = true;
        }));
        var steps = 0;
        while (!done && steps < 1000) {
            r2.update(0.03);
            steps++;
        }
        check("大步长 elapsed 也能结束", done);
        eq("0.1 秒 / 0.03 步长 = 4 帧", steps, 4);

        // elapsed 为 0 时不能永久卡死（标称帧时长兜底）。
        var zeroDone = false;
        var r3 = new CoroutineRunner();
        r3.start(Coroutine.create(function(co:CoroutineContext) {
            co.wait(0.05);
            zeroDone = true;
        }));
        for (_ in 0...100) r3.update(0);
        check("elapsed=0 时 wait(seconds) 不会永久卡死", zeroDone);
    }

    // ④ 顺序挂起：`co.wait(a); DoX(); co.wait(b); DoY();` 的执行顺序与 C# 一致。
    //    用「阶段号赋值」度量（幂等），而不是数组 push —— push 是非幂等副作用，
    //    在重放模型下会累积（这正是 ⑬ 钉住的取舍）。
    static function testSequentialWaitsOrder():Void {
        Sys.println('');
        Sys.println('④ 顺序挂起的执行顺序');
        var phase = 0;
        var runner = new CoroutineRunner();
        var c = Coroutine.create(function(co:CoroutineContext) {
            co.waitFrames(2);
            phase = 1;
            co.waitFrames(1);
            phase = 2;
            co.wait(0);
            phase = 3;
        });
        runner.start(c);
        eq("start 时仍在第 1 个挂起点", phase, 0);

        runner.update(DT);
        eq("第 1 帧仍在 waitFrames(2) 中", phase, 0);
        runner.update(DT);
        eq("第 2 帧越过 waitFrames(2)", phase, 1);
        runner.update(DT);
        eq("第 3 帧越过 waitFrames(1)", phase, 2);
        runner.update(DT);
        eq("第 4 帧越过 wait(0)", phase, 3);
        check("顺序挂起后结束", c.finished);

        // 阶段号必须单调不减（不会跳回去重跑更早的段落）。
        var last = 0;
        var monotonic = true;
        var r2 = new CoroutineRunner();
        var p2 = 0;
        var c2 = Coroutine.create(function(co:CoroutineContext) {
            co.waitFrames(1);
            p2 = 1;
            co.waitFrames(1);
            p2 = 2;
            co.waitFrames(1);
            p2 = 3;
        });
        r2.start(c2);
        for (_ in 0...5) {
            r2.update(DT);
            if (p2 < last) monotonic = false;
            last = p2;
        }
        check("阶段号单调不减", monotonic, 'last=$last');
        eq("多段挂起最终到达最后阶段", p2, 3);
        check("多段挂起最终结束", c2.finished);
    }

    // ⑤ waitCoroutine：挂起直到子协程结束（子协程由调用方显式 StartCoroutine）。
    static function testWaitCoroutine():Void {
        Sys.println('');
        Sys.println('⑤ waitCoroutine(child) 挂起至子协程结束');
        var runner = new CoroutineRunner();
        var childStep = 0;
        var parentDone = false;

        var child = Coroutine.create(function(co:CoroutineContext) {
            var i = 0;
            while (i < 3) {
                i++;
                childStep = i;
                co.waitFrames(1);
            }
        });
        var parent = Coroutine.create(function(co:CoroutineContext) {
            co.waitCoroutine(child);
            parentDone = true;
        });

        runner.start(child);
        runner.start(parent);
        eq("父协程在子协程结束时才继续", parentDone, false);

        var frames = 0;
        while (!parentDone && frames < 100) {
            runner.update(DT);
            frames++;
        }
        check("子协程结束后父协程恢复", parentDone);
        check("父协程已结束", parent.finished);
        check("子协程已结束", child.finished);
        eq("子协程循环体推进到 3", childStep, 3);
    }

    // ⑥ waitCoroutine 的 child 未被 StartCoroutine 时，runner 应接手驱动（否则父协程永久卡死）。
    static function testWaitCoroutineDrivesUnstartedChild():Void {
        Sys.println('');
        Sys.println('⑥ waitCoroutine 自动驱动未启动的子协程');
        var runner = new CoroutineRunner();
        var childStep = 0;
        var parentDone = false;

        var child = Coroutine.create(function(co:CoroutineContext) {
            var i = 0;
            while (i < 2) {
                i++;
                childStep = i;
                co.waitFrames(1);
            }
        });
        var parent = Coroutine.create(function(co:CoroutineContext) {
            co.waitCoroutine(child);
            parentDone = true;
        });

        runner.start(parent);
        var frames = 0;
        while (!parentDone && frames < 100) {
            runner.update(DT);
            frames++;
        }
        check("未显式启动的子协程也被驱动到结束", parentDone, 'childStep=$childStep');
        check("父协程已结束", parent.finished);
        eq("子协程循环体推进到 2", childStep, 2);
    }

    // ⑦ yieldBreak：立即结束，且其后的语句不再执行。
    static function testYieldBreak():Void {
        Sys.println('');
        Sys.println('⑦ yieldBreak() 立即结束并跳过后续语句');
        var reached = false;
        var runner = new CoroutineRunner();
        var c = Coroutine.create(function(co:CoroutineContext) {
            co.yieldBreak();
            reached = true;
        });
        runner.start(c);
        check("yieldBreak 后协程立即 finished", c.finished);
        check("yieldBreak 之后的语句未执行", !reached);

        // 在挂起之后 yieldBreak，同样应跳过后续。
        var reached2 = false;
        var r2 = new CoroutineRunner();
        var c2 = Coroutine.create(function(co:CoroutineContext) {
            co.waitFrames(1);
            co.yieldBreak();
            reached2 = true;
        });
        r2.start(c2);
        check("首个挂起前未结束", !c2.finished);
        r2.update(DT);
        check("挂起后 yieldBreak 生效", c2.finished);
        check("挂起后 yieldBreak 的后续语句未执行", !reached2);
    }

    // ⑧ 轮询循环（工程里最常见的写法）每帧只推进一「步」，不会在同一帧跑完整个循环。
    //    进度用「局部累计量 + 幂等写入」度量（= MoveCameraLawn 的真实形状）：
    //    step 取 1/64，重复累加在 IEEE double 下精确，断言无浮点噪声。
    static function testPollingLoopAdvancesOneStepPerUpdate():Void {
        Sys.println('');
        Sys.println('⑧ 轮询循环每帧推进 1 步（不在一帧内跑飞）');
        var runner = new CoroutineRunner();
        var flag = false;
        var progress = 0.0;
        var tailDone = false;

        var c = Coroutine.create(function(co:CoroutineContext) {
            var t = 0.0;
            while (!flag) {
                t = t + STEP;
                progress = t;
                co.waitFrames(1);
            }
            tailDone = true;
        });
        runner.start(c);
        eq("start 后进度 = 1 步", progress, STEP);

        runner.update(DT);
        eq("update 1 次 → 进度 +1 步", progress, 2 * STEP);
        runner.update(DT);
        eq("update 2 次 → 进度 +1 步", progress, 3 * STEP);
        check("条件未满足时循环未退出", !tailDone);

        flag = true;
        runner.update(DT);
        check("条件满足后循环退出", tailDone);
        check("协程结束", c.finished);

        // 一帧只消耗一个挂起点：10 次迭代的循环不会在第 1 帧就结束。
        var i2 = 0;
        var progress2 = 0.0;
        var r2 = new CoroutineRunner();
        var c2 = Coroutine.create(function(co:CoroutineContext) {
            var t = 0.0;
            while (t < 10 * STEP) {
                t = t + STEP;
                progress2 = t;
                co.waitFrames(1);
            }
        });
        r2.start(c2);
        r2.update(DT);
        eq("一帧只推进 1 步（而非跑满 10 次）", progress2, 2 * STEP);
        check("10 步的循环未在第 1 帧结束", !c2.finished);
    }

    // ⑨ stop / stopAll：被停止的协程不再被步进。
    static function testStopAndStopAll():Void {
        Sys.println('');
        Sys.println('⑨ stop / stopAll');
        var runner = new CoroutineRunner();
        var progress = 0.0;
        var c = Coroutine.create(function(co:CoroutineContext) {
            var t = 0.0;
            while (true) {
                t = t + STEP;
                progress = t;
                co.waitFrames(1);
            }
        });
        runner.start(c);
        eq("start 后进度 = 1 步", progress, STEP);
        runner.update(DT);
        eq("update 后进度 = 2 步", progress, 2 * STEP);

        runner.stop(c);
        runner.update(DT);
        eq("stop 后不再推进", progress, 2 * STEP);

        var pa = 0.0;
        var pb = 0.0;
        var r2 = new CoroutineRunner();
        var ca = Coroutine.create(function(co:CoroutineContext) {
            var t = 0.0;
            while (true) {
                t = t + STEP;
                pa = t;
                co.waitFrames(1);
            }
        });
        var cb = Coroutine.create(function(co:CoroutineContext) {
            var t = 0.0;
            while (true) {
                t = t + STEP;
                pb = t;
                co.waitFrames(1);
            }
        });
        r2.start(ca);
        r2.start(cb);
        r2.stopAll();
        r2.update(DT);
        eq("stopAll 后 ca 不再推进", pa, STEP);
        eq("stopAll 后 cb 不再推进", pb, STEP);
    }

    // ⑩ wait(0) / waitFrames(0)：只让出一帧（等价 C# 的 `yield return null`）。
    static function testWaitZeroYieldsOneFrame():Void {
        Sys.println('');
        Sys.println('⑩ wait(0) / waitFrames(0) 让出一帧');

        var doneSec = false;
        var r1 = new CoroutineRunner();
        var c1 = Coroutine.create(function(co:CoroutineContext) {
            co.wait(0);
            doneSec = true;
        });
        r1.start(c1);
        check("wait(0) 在 start 时未立即结束", !doneSec);
        r1.update(DT);
        check("wait(0) 一帧后恢复", doneSec);
        check("wait(0) 恢复后结束", c1.finished);

        var doneFrames = false;
        var r2 = new CoroutineRunner();
        var c2 = Coroutine.create(function(co:CoroutineContext) {
            co.waitFrames(0);
            doneFrames = true;
        });
        r2.start(c2);
        check("waitFrames(0) 在 start 时未立即结束", !doneFrames);
        r2.update(DT);
        check("waitFrames(0) 一帧后恢复", doneFrames);
        check("waitFrames(0) 恢复后结束", c2.finished);
    }

    // ⑪ 业务异常向上传播（交由 MainGameScene.update 的逐组件边界处理），不被步进器吞掉。
    static function testExceptionPropagates():Void {
        Sys.println('');
        Sys.println('⑪ 业务异常向上传播');
        var runner = new CoroutineRunner();
        var c = Coroutine.create(function(co:CoroutineContext) {
            co.waitFrames(1);
            throw "boom";
        });
        runner.start(c);
        var caught:Dynamic = null;
        try {
            runner.update(DT);
        } catch (e:Dynamic) {
            caught = e;
        }
        eq("update 期间的异常原样抛出", caught, "boom");

        // start 期间的异常同样向上抛（Unity 的 StartCoroutine 首段也是同步执行）。
        var caught2:Dynamic = null;
        var r2 = new CoroutineRunner();
        try {
            r2.start(Coroutine.create(function(co:CoroutineContext) {
                throw "boom-on-start";
            }));
        } catch (e:Dynamic) {
            caught2 = e;
        }
        eq("start 期间的异常原样抛出", caught2, "boom-on-start");

        // 协程体内部 `catch (e:Dynamic)` 会吞掉挂起信号（C# 不允许 yield 出现在
        // try/catch 里，所以 1:1 移植的协程体不该有这种写法；工程里 26 个协程体都没有）。
        // 兜底要求：即使被吞掉，协程也**不能**被误判为「函数体跑完」而静默丢弃，
        // 必须仍在 running 里、并能在后续帧正常恢复结束。
        var afterTry = false;
        var r3 = new CoroutineRunner();
        var c3 = Coroutine.create(function(co:CoroutineContext) {
            try {
                co.waitFrames(1);
            } catch (e:Dynamic) {
                // 挂起信号被这里吞掉（病态写法）。
            }
            afterTry = true;
        });
        r3.start(c3);
        check("挂起信号被协程体 catch 吞掉时不会把协程误判为已结束", !c3.finished);
        r3.update(DT);
        check("该协程仍能在下一帧恢复并结束", c3.finished);
        check("被吞掉的挂起点之后仍在下一帧执行", afterTry);
    }

    // ⑫ 结束的协程被移出 running，不会被反复步进。
    static function testFinishedCoroutineLeavesRunning():Void {
        Sys.println('');
        Sys.println('⑫ 结束的协程被移出 running');
        var tailRuns = 0;
        var runner = new CoroutineRunner();
        var c = Coroutine.create(function(co:CoroutineContext) {
            co.waitFrames(1);
            tailRuns++;
        });
        runner.start(c);
        eq("挂起期间 tail 未执行", tailRuns, 0);
        runner.update(DT);
        check("结束时 finished", c.finished);
        eq("恢复时 tail 执行一次", tailRuns, 1);

        // 再跑很多帧：若没被移出 running，函数体会被继续重放。
        for (_ in 0...5) runner.update(DT);
        eq("结束后不再被步进（函数体不再执行）", tailRuns, 1);

        // 无挂起的协程在 start 时即结束，且只执行一次。
        var once = 0;
        var r2 = new CoroutineRunner();
        var immediate = Coroutine.create(function(co:CoroutineContext) {
            once++;
        });
        r2.start(immediate);
        check("无挂起的协程在 start 时即结束", immediate.finished);
        for (_ in 0...5) r2.update(DT);
        eq("立即结束的协程函数体只执行一次", once, 1);
    }

    // ⑬ 重放模型的已知取舍（显式钉住，避免被误当 bug 或误当正确行为）。
    //    Haxe 无法从函数体中间恢复执行，只能在每次恢复时从函数体开头重放到下一个
    //    未完成的挂起点，因此挂起点之前的语句（含已完成的循环迭代）会被重复执行。
    static function testReplayLimitations():Void {
        Sys.println('');
        Sys.println('⑬ 重放模型的已知取舍');

        // 幂等写入（赋值）不随重放累积 —— 工程里协程体的写法。
        var observed = 0.0;
        var runner = new CoroutineRunner();
        var c = Coroutine.create(function(co:CoroutineContext) {
            var t = 0.0;
            while (t < 3 * STEP) {
                t = t + STEP;
                observed = t;
                co.waitFrames(1);
            }
        });
        runner.start(c);
        eq("幂等写入：start 后为 1 步", observed, STEP);
        runner.update(DT);
        eq("幂等写入：第 1 帧后为 2 步", observed, 2 * STEP);
        runner.update(DT);
        eq("幂等写入：第 2 帧后为 3 步", observed, 3 * STEP);
        runner.update(DT);
        check("幂等写入：第 3 帧结束", c.finished);

        // 非幂等副作用（自增）会被重放累积 —— 移植时必须避免这种写法。
        var counter = 0;
        var r2 = new CoroutineRunner();
        r2.start(Coroutine.create(function(co:CoroutineContext) {
            co.waitFrames(1);
            counter++;
            co.waitFrames(1);
            counter++;
        }));
        eq("重放前 counter=0", counter, 0);
        r2.update(DT);
        eq("第 1 次恢复：counter 自增 1 次", counter, 1);
        r2.update(DT);
        eq("第 2 次恢复：第 1 个挂起点前的语句被重放，counter 共 +2", counter, 3);

        // 在循环里新建子协程再轮询其 .finished（LevelController 现有写法）：
        // 重放会重新调用工厂，拿到一个全新的、无人驱动的子协程，循环永不退出。
        // 正确写法是 co.waitCoroutine(Factory())（见 ⑥，能正常结束）。
        var factoryCalls = 0;
        var r3 = new CoroutineRunner();
        var factoryPollDone = false;
        var parent = Coroutine.create(function(co:CoroutineContext) {
            var inner = makeChild(function() factoryCalls++);
            while (inner != null && !inner.finished) {
                co.waitFrames(1);
            }
            factoryPollDone = true;
        });
        r3.start(parent);
        for (_ in 0...200) r3.update(DT);
        check("工厂轮询写法在重放模型下**不**会结束（已知限制，调用点需改用 waitCoroutine）",
            !factoryPollDone, 'factoryCalls=$factoryCalls');
        check("工厂被反复调用（证明子协程每次重放都被重建）", factoryCalls > 50, 'factoryCalls=$factoryCalls');

        // 循环体内含非幂等副作用（ResourceManager.ShotModelIcons 的形状：
        // `yieldCounter++` + 每项工作）：已完成的迭代会被重放重复执行。
        // 观感要求：进度单调前进、最终跑完（重复的只是工作次数）。
        var count = 20;
        var maxPerFrame = 4;
        var work = 0;
        var progress = -1;
        var r4 = new CoroutineRunner();
        var c4 = Coroutine.create(function(co:CoroutineContext) {
            var yieldCounter = 0;
            for (i in 0...count) {
                work++;
                progress = i;
                yieldCounter++;
                if (yieldCounter >= maxPerFrame) {
                    yieldCounter = 0;
                    co.waitFrames(1);
                }
            }
            progress = 999;
        });
        r4.start(c4);
        var monotonic = true;
        var lastProgress = progress;
        for (_ in 0...10) {
            r4.update(DT);
            if (progress < lastProgress) monotonic = false;
            lastProgress = progress;
        }
        check("分帧加载形状：进度单调不减", monotonic, 'progress=$progress');
        eq("分帧加载形状：最终跑完", progress, 999);
        check("分帧加载形状：协程结束", c4.finished);
        check("分帧加载形状：已完成迭代被重放（work 次数 > count）", work > count, 'work=$work count=$count');
    }

    // ⑭ 重复 start 不应提前消耗已有挂起点（stop 后重新 start 的场景）。
    static function testRestartDoesNotSkipWait():Void {
        Sys.println('');
        Sys.println('⑭ stop 后重新 start 不提前消耗挂起点');
        var runner = new CoroutineRunner();
        var phase = 0;
        var c = Coroutine.create(function(co:CoroutineContext) {
            co.waitFrames(3);
            phase = 1;
        });
        runner.start(c);
        runner.update(DT);
        eq("第 1 帧仍在等待中（剩 2 帧）", phase, 0);

        // stop 后再 start：协程已经在等待中，重新 start 不能把它当成「尚未跑过」
        // 而再 resume 一次（那会把当前挂起点当成已完成，等待被缩短）。
        runner.stop(c);
        runner.start(c);
        eq("重新 start 后仍未恢复", phase, 0);
        runner.update(DT);
        eq("重新 start 不缩短剩余等待（仍剩 1 帧）", phase, 0);
        runner.update(DT);
        eq("剩余等待耗尽后恢复", phase, 1);
        check("协程结束", c.finished);
    }

    static function makeChild(count:Void->Void):Coroutine {
        count();
        return Coroutine.create(function(co:CoroutineContext) {
            var i = 0;
            while (i < 2) {
                i++;
                co.waitFrames(1);
            }
        });
    }
}
