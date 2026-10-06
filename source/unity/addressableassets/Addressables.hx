// Ported from: UnityEngine.AddressableAssets.Addressables (shim backed by the port's resource manifest)
package unity.addressableassets;

import unity.Debug;

/**
 * PORT-NOTE: Unity Addressables 不移植（PORTING.md §其他约定）。移植层用「进程内注册表 + 资源清单」实现：
 *   1. `RegisterAsset(key, asset)` 显式登记的对象优先级最高（供精灵/音频/模型等转换阶段注入语义对象）；
 *   2. 否则按 address / label 查询 HaxePort/assets/resource_manifest.json（见 ResourceManifest），
 *      取到文件后按类型解码（png→FlxGraphic、ogg/wav/mp3→AudioClip、xml/json/txt/bytes→TextAsset、其它→Bytes）；
 *   3. 资源缺失时返回结果为 null 的句柄并 Debug.LogWarning，不抛异常
 *      （C# 里 Locate 失败 / Result 取值失败都抛异常，ResourceManager 用 try/catch 兜住；
 *       移植层把异常换成 null + 警告，调用点已有的 null 判断保持有效）。
 *
 * 调用点写法与 C# 一致：`Addressables.LoadAssetAsync(key)`、`Addressables.InitializeAsync().Task`、
 * `locator.Locate(label, type)`。Haxe 没有方法重载，按 PORTING.md 的约定加 ByLocation / ByObject 后缀。
 */
class Addressables {
    /** 显式注册的资源表（key → 资源对象）。 */
    public static var assets:Map<String, Dynamic> = new Map();

    private static var _initializeHandle:AsyncOperationHandle<IResourceLocator> = null;
    private static var _locator:IResourceLocator = null;

    // C#: public static AsyncOperationHandle<IResourceLocator> InitializeAsync()
    // PORT-NOTE: 移植层的目录即清单文件，初始化在首次使用清单时惰性完成（见 ResourceManifest.get()）。
    // 与 C# 一样返回句柄，ModManager 取 `.Task` 得到 IResourceLocator（C# 侧是 `await ...Task`）。
    public static function InitializeAsync():AsyncOperationHandle<IResourceLocator> {
        if (_initializeHandle == null) {
            _locator = ResourceManifest.get().getLocator();
            _initializeHandle = new AsyncOperationHandle<IResourceLocator>("Addressables.InitializeAsync");
            _initializeHandle.completeWith(_locator);
        }
        return _initializeHandle;
    }

    // C#: public static void RegisterAsset(object key, object asset)（工程内自加的调试接口）
    public static function RegisterAsset(key:String, asset:Dynamic):Void {
        assets.set(key, asset);
        // 让 locator.Locate(key, type) 也能命中显式注册的地址。
        try {
            ResourceManifest.get().registerOverride(key);
        } catch (e:Dynamic) {
            Debug.LogWarning('RegisterAsset 时资源清单不可用：$e');
        }
    }

    // C#: public static AsyncOperationHandle<T> LoadAssetAsync<T>(object key)
    // PORT-NOTE: C# 会用 T 过滤定位符；Haxe 泛型在运行期被擦除，类型过滤由调用方传入的类型参数
    // 在 locator.Locate(key, type) 里完成（见 ResourceManager.GetLabeledResourceLocations）。
    public static function LoadAssetAsync<T>(key:String):AsyncOperationHandle<T> {
        var handle = new AsyncOperationHandle<T>(key);
        if (key == null || key == "") {
            Debug.LogWarning('Addressables.LoadAssetAsync：key 为空。');
            handle.completeWith(null, "key 为空");
            return handle;
        }
        var asset:Dynamic = null;
        var error:String = null;
        if (assets.exists(key)) {
            asset = assets.get(key);
        } else {
            var manifest = ResourceManifest.get();
            var locations = manifest.locate(key, null);
            var location:ResourceLocation = locations.length == 0 ? null : cast locations[0];
            if (location == null) {
                error = '未找到地址或标签「$key」';
                Debug.LogWarning('Addressables.LoadAssetAsync：$error。');
            } else {
                if (locations.length > 1)
                    Debug.LogWarning('Addressables.LoadAssetAsync：键「$key」命中 ${locations.length} 个位置'
                        + '（C# 的单资源接口此时会抛 InvalidKeyException，ResourceManager 用 locs.FirstOrDefault()），此处取第一个。');
                asset = manifest.load(location);
                if (asset == null)
                    error = '资源加载失败（${location.Path}）';
            }
        }
        handle.completeWith(cast asset, error);
        return handle;
    }

    // C#: public static AsyncOperationHandle<T> LoadAssetAsync<T>(IResourceLocation location)
    // PORT-NOTE: Haxe 无重载，按 PORTING.md 的改名约定加 ByLocation 后缀。
    // 与按 key 加载的关键差别：同一个 address 可能对应多个文件（如 mvz2:castle 同时是
    // areamodels/castle.prefab 与 mapmodels/castle.prefab，靠 label 区分），C# 的
    // `LoadAssetAsync<T>(loc)` 加载的是**这个定位符指向的文件**，所以这里必须按定位符加载，
    // 不能退回 `LoadAssetAsync(loc.PrimaryKey)`（那样两个位置会拿到同一个资源）。
    public static function LoadAssetAsyncByLocation<T>(location:IResourceLocation):AsyncOperationHandle<T> {
        var handle = new AsyncOperationHandle<T>(location == null ? null : location.PrimaryKey);
        if (location == null) {
            Debug.LogWarning('Addressables.LoadAssetAsync(location)：location 为 null。');
            handle.completeWith(null, 'location 为 null');
            return handle;
        }
        // 显式注册的资源（RegisterAsset）仍优先：对象已经装好了，与是哪个定位符无关。
        if (assets.exists(location.PrimaryKey)) {
            handle.completeWith(cast assets.get(location.PrimaryKey));
            return handle;
        }
        var manifest = ResourceManifest.get();
        var exact:ResourceLocation = null;
        if (Std.isOfType(location, ResourceLocation)) {
            exact = cast location;
        } else {
            // PORT-NOTE: 非移植层实现（理论上不存在）只能退回按地址解析第一条。
            exact = manifest.locateFirst(location.PrimaryKey, null);
        }
        if (exact == null) {
            var error = '未找到定位符「${location.PrimaryKey}」';
            Debug.LogWarning('Addressables.LoadAssetAsync(location)：$error。');
            handle.completeWith(null, error);
            return handle;
        }
        var asset:Dynamic = manifest.load(exact);
        handle.completeWith(cast asset, asset == null ? '资源加载失败（${exact.Path}）' : null);
        return handle;
    }

    // C#: public static AsyncOperationHandle<T> LoadAssetAsync<T>(object key)
    public static function LoadAssetAsyncByObject<T>(key:Dynamic):AsyncOperationHandle<T> {
        // PORT-NOTE: 移植层只有 ResourceLocation 一个 IResourceLocation 实现，
        // 先按具体类判断（hxcpp 下比接口判断可靠），再兜底按接口判断。
        if (Std.isOfType(key, ResourceLocation)) {
            return LoadAssetAsyncByLocation(cast key);
        }
        if (key != null && !Std.isOfType(key, String)
            && Reflect.hasField(key, "PrimaryKey") && Reflect.hasField(key, "InternalId")) {
            return LoadAssetAsyncByLocation(cast key);
        }
        return LoadAssetAsync(Std.string(key));
    }

    // C#: public static void Release(AsyncOperationHandle handle)
    // PORT-NOTE: 移植层的资源常驻内存（FlxGraphic 进 flixel 缓存、AudioClip 由 Map 持有），
    // 释放语义由 ResourceManager 自己的引用计数负责，这里保持空实现。
    public static function Release(handle:Dynamic):Void {}
}

// PORT-NOTE: 补全 Addressables.MergeMode（Unity 的嵌套枚举），供 ResourceManager 的标签合并参数使用。
enum abstract MergeMode(Int) {
    var None = 0;
    var UseFirst = 1;
    var Union = 2;
    var Intersection = 3;
}

// PORT-NOTE: 补全 UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationStatus。
enum abstract AsyncOperationStatus(Int) {
    var None = 0;
    var Succeeded = 1;
    var Failed = 2;
}

class AsyncOperationHandle<T> {
    public var Key(default, null):String;
    // C#: public Task<T> Task { get; }
    // PORT-NOTE: 移植层没有异步调度，Task 直接就是资源对象本身（C# 侧 `await handle.Task` 得到的也是它）。
    public var Task:T;

    // C#: public bool IsDone { get; }
    public var IsDone(get, never):Bool;
    function get_IsDone():Bool return _status != AsyncOperationStatus.None;

    // C#: public AsyncOperationStatus Status { get; }
    public var Status(get, never):AsyncOperationStatus;
    function get_Status():AsyncOperationStatus return _status;

    // C#: public Exception OperationException { get; }
    public var OperationException(default, null):String = null;

    // C#: public bool IsValid()
    public var IsValid(get, never):Bool;
    function get_IsValid():Bool return _status != AsyncOperationStatus.None;

    // C#: public float PercentComplete { get; }
    public var PercentComplete(get, never):Float;
    function get_PercentComplete():Float return _status == AsyncOperationStatus.None ? 0 : 1;

    // C#: public T Result { get; }
    // PORT-NOTE: C# 的 Result 在任务未完成或失败时会抛异常；移植层是同步加载，
    // 失败时返回 null（调用点已有 null 判断），不抛异常。
    public var Result(get, never):T;
    function get_Result():T return Task;

    public function new(key:String) {
        Key = key;
        _status = AsyncOperationStatus.None;
    }

    private var _status:AsyncOperationStatus = AsyncOperationStatus.None;

    public function WaitForCompletion():T {
        return Task;
    }

    /** 移植层：以同步结果完成句柄（C# 里由 ResourceManager 异步流程完成）。 */
    public function completeWith(result:T, ?error:String):Void {
        Task = result;
        OperationException = error;
        _status = error == null ? AsyncOperationStatus.Succeeded : AsyncOperationStatus.Failed;
        if (_completed != null)
            _completed.dispatch(this);
    }

    // C#: public event Action<AsyncOperationHandle<T>> Completed
    // PORT-NOTE: 移植层是同步加载，句柄创建时即已完成。C# 的 Completed 在句柄已完成时会立刻
    // 回调订阅者，FlxSignal 无法在 add 时触发，故改用显式 complete()/completeWith() 派发；同步取值的
    // 调用点（ResourceManager）用 WaitForCompletion() / Result，二者语义等价。
    public var Completed(get, never):flixel.util.FlxSignal.FlxTypedSignal<AsyncOperationHandle<T>->Void>;
    function get_Completed():flixel.util.FlxSignal.FlxTypedSignal<AsyncOperationHandle<T>->Void> {
        if (_completed == null) _completed = new flixel.util.FlxSignal.FlxTypedSignal();
        return _completed;
    }
    private var _completed:flixel.util.FlxSignal.FlxTypedSignal<AsyncOperationHandle<T>->Void>;

    public function complete():Void {
        if (_status == AsyncOperationStatus.None)
            completeWith(Task);
        else if (_completed != null)
            _completed.dispatch(this);
    }

    // C#: public void Release()
    public function Release():Void {}
}
