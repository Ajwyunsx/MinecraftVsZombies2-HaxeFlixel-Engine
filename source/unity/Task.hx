package unity;

// PORT-NOTE: 这里原本是第二份 System.Threading.Tasks.Task shim（与 system.threading.tasks.Task 重复），
// 两份互不兼容会让同时使用它们的文件（如 mvz2.scenes.MainSceneController）无法通过类型检查。
// 现统一到 system.threading.tasks.Task，本模块仅保留 `unity.Task` 这个名字别名，
// 使其对外行为与旧调用点（`new Task()` / `Task.completedTask()` / `.awaitResult()`）完全一致。
typedef Task = system.threading.tasks.Task;
