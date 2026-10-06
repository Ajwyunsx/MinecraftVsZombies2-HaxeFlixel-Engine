package mvz2.store;

import mvz2.managers.MainManager;
import mvz2.metas.StorePresetMeta;
import mvz2.scenes.MainScenePage;
import mvz2.talk.DefaultTalkSystem;
import mvz2.talk.TalkController;
import mvz2.talk.TalkCharacterController;
import mvz2.ui.store.StoreUI;
import mvz2logic.Global;
import mvz2logic.audios.LogicSoundID;
import mvz2logic.callbacks.LogicCallbacks;
import mvz2logic.localization.LogicStrings;
import mvz2logic.talk.ITalkSystem;
import pvzengine.NamespaceID;
import system.Guid;
import tools.RandomGenerator;
import unity.Mathf;
import unity.Time;
import unity.Transform;
import unity.Vector2;
import unity.Vector3;
import mvz2.localization.LanguageManager;
import Main;
import mvz2.audios.MusicManager;
import mvz2.managers.ResourceManager;
import mvz2.saves.SaveManager;
import mvz2.cameras.ShakeManager;
import mvz2.audios.SoundManager;
import unity.ui.Text;
import mvz2.gamecontent.commands.Unlock;
import mvz2.talk.TalkCharacterController.CharacterSide;
import mvz2logic.callbacks.LogicCallbacks.TalkActionParams;
import flixel.system.debug.stats.Stats;
import unity.scenemanagement.SceneInstance.Scene;

// PORT-NOTE: C# 中 MeetsXMLConditions / GetMoney / AddMoney / SimpleStartTalkAsync 均为扩展方法，
// Haxe 侧用 `using` 还原为调用点方法形式。
using mvz2.saves.MVZ2SaveExt;
using mvz2logic.saves.LogicSaveExt;
using mvz2.talk.TalkHelper;

// Ported from: Assets/Scripts/MVZ2/Store/StoreController.cs
class StoreController extends MainScenePage {
    override public function Display():Void {
        super.Display();
        page = 0;
        chatFadeTimeout = 0;
        UpdateProducts();
        UpdatePage();
        ResetChatTimeout();
        UpdateMoney();
        ui.Display();
        character.SetSpeaking(true);
        character.ResetMotion();


        var presets = Main.ResourceManager.GetAllStorePresets();
        var filteredPresets = Lambda.filter(presets, p -> p.Conditions == null || Main.SaveManager.MeetsXMLConditions(p.Conditions));
        var sorted = Lambda.array(filteredPresets);
        sorted.sort((a, b) -> b.Priority - a.Priority);
        var preset = sorted.length > 0 ? sorted[0] : null;
        SetPreset(preset);
    }
    override public function Hide():Void {
        super.Hide();
        character.RemovePortrait();
    }
    // PORT-NOTE: C# `async void CheckStartTalks()` → Void; the talk sequence is started without
    // blocking and resumes through the talk controller's callbacks.
    public function CheckStartTalks():Void {
        var loreTalks = Main.ResourceManager.GetCurrentStoreLoreTalks();
        if (loreTalks == null)
            return;
        // 对话
        var queue:Array<NamespaceID> = [];
        for (lore in loreTalks) {
            if (!queue.contains(lore))
                queue.push(lore);
        }

        CheckStartTalksAsync(queue);
    }
    private function CheckStartTalksAsync(queue:Array<NamespaceID>):Void {
        while (queue.length > 0) {
            var talk = queue.shift();
            if (!Main.ResourceManager.CanStartTalk(talk, 0))
                continue;
            ui.SetStoreUIVisible(false);
            // TODO-PORT: `await talkController.SimpleStartTalkAsync(talk, 0, 1)` requires
            // restructuring this loop into a coroutine.
            talkController.SimpleStartTalkAsync(talk, 0, 1);

            // 如果对话去了其他页面，那就不触发之后的对话。
            if (!gameObject.activeInHierarchy)
                break;
        }
        ui.SetStoreUIVisible(true);
    }
    public function SetPreset(preset:StorePresetMeta):Void {
        // PORT-NOTE: C# 重载 GetFinalSprite(SpriteReference?) 在移植层名为 GetFinalSpriteFromRef。
        var backgroundSprite = Main.GetFinalSpriteFromRef(preset.Background);
        ui.SetBackground(backgroundSprite);

        var characterID = preset.Character;
        if (characterID != null) {
            characterId = characterID;

            var faceRight = false;
            var characterMeta = Main.ResourceManager.GetCharacterMeta(characterID);
            if (characterMeta != null) {
                faceRight = characterMeta.faceRight;
            }

            character.SetVariant(characterID, null);
            character.SetSide(CharacterSide.Left, faceRight);
        }

        if (preset.Music != null && !Main.MusicManager.IsPlaying(preset.Music))
            Main.MusicManager.Play(preset.Music);
    }

    // #region 生命周期
    private function Awake():Void {
        ui.OnReturnClick.add(OnReturnClickCallback);
        ui.OnPageButtonClick.add(OnPageButtonClickCallback);
        ui.OnProductPointerEnter.add(OnProductPointerEnterCallback);
        ui.OnProductPointerExit.add(OnProductPointerExitCallback);
        ui.OnProductClick.add(OnProductClickCallback);

        // PORT-NOTE: C# `new Guid().GetHashCode()`。Haxe 的 String 无 hashCode，
        // 这里用与 mvz2.models.ModelAnchor.hashCodeOf 一致的简易字符串哈希替代 C# string.GetHashCode。
        chatRNG = new RandomGenerator(hashCodeOf(new Guid().ToString()));
        talkSystem = new DefaultTalkSystem(talkController);

        talkController.OnTalkAction.add(OnTalkActionCallback);
    }
    private function Update():Void {
        if (!pointingProduct && !talkController.IsTalking) {
            chatTimeout -= Time.deltaTime;
            if (chatTimeout <= 0) {
                ShowChat();
                ResetChatTimeout();
                chatFadeTimeout = MAX_CHAT_FADE_TIMEOUT;
            }
            chatFadeTimeout -= Time.deltaTime;
            if (chatFadeTimeout <= 0) {
                ui.HideTalk();
            }
        }
        cameraShakeRoot.localPosition = Main.ShakeManager.GetShake2D();
    }
    // #endregion

    // #region UI 事件回调
    private function OnReturnClickCallback():Void {
        Return();
    }
    private function OnPageButtonClickCallback(next:Bool):Void {
        var offset = next ? 1 : -1;
        page += offset;
        var totalPages = GetTotalPages();
        if (page < 0) {
            page = totalPages - 1;
        } else if (page >= totalPages) {
            page = 0;
        }
        UpdatePage();
    }
    private function OnProductPointerEnterCallback(index:Int):Void {
        var product = GetCurrentProduct(index);
        if (!NamespaceID.IsValid(product))
            return;
        var productMeta = Main.ResourceManager.GetProductMeta(product);
        if (productMeta == null)
            return;
        var textKey = productMeta.GetMessage(characterId);
        var message = GetTranslatedString(LogicStrings.CONTEXT_STORE_TALK, textKey, []);
        pointingProduct = true;
        ui.ShowTalk(message);
    }
    private function OnProductPointerExitCallback(index:Int):Void {
        pointingProduct = false;
        ui.HideTalk();
    }
    private function OnProductClickCallback(index:Int):Void {
        var product = GetCurrentProduct(index);
        if (!NamespaceID.IsValid(product))
            return;
        var productMeta = Main.ResourceManager.GetProductMeta(product);
        if (productMeta == null)
            return;
        var stage = Main.StoreManager.GetCurrentProductStage(productMeta);
        if (Main.StoreManager.IsSoldout(stage))
            return;
        var price = stage.Price;
        var money = Main.SaveManager.GetMoney();
        if (money >= price) {
            var title = Main.LanguageManager._(PURCHASE);
            var desc = Main.LanguageManager._n(PURCHASE_DESCRIPTION, price, [price]);
            Main.Scene.ShowDialogSelect(title, desc, function(purchase:Bool) {
                if (!purchase)
                    return;

                var operated = false;
                // 解锁内容
                if (NamespaceID.IsValid(stage.Unlocks)) {
                    Main.SaveManager.Unlock(stage.Unlocks);
                    operated = true;
                }
                // 设置统计
                var stats = stage.Stats;
                if (stats != null && stats.length > 0) {
                    for (stat in stats) {
                        if (!NamespaceID.IsValid(stat.Entry))
                            continue;
                        var value = stat.Value;
                        if (NamespaceID.IsValid(stat.Category)) {
                            var statValue = Main.SaveManager.GetStat(stat.Category, stat.Entry);
                            Main.SaveManager.SetStat(stat.Category, stat.Entry, statValue + value);
                        } else {
                            var statValue = Main.SaveManager.GetDirectEntryStat(stat.Entry);
                            Main.SaveManager.SetDirectEntryStat(stat.Entry, statValue + value);
                        }
                    }
                    operated = true;
                }
                if (!operated) {
                    return;
                }
                Main.SaveManager.AddMoney(-price);
                Main.SoundManager.Play2D(LogicSoundID.cashRegister);
                Main.SaveManager.SaveToFile(); // 购买物品后保存游戏
                UpdateMoney();
                UpdatePage();
            });
        } else {
            var title = Main.LanguageManager._(INSUFFICIENT_MONEY);
            var desc = Main.LanguageManager._(INSUFFICIENT_MONEY_DESCRIPTION);
            Main.Scene.ShowDialogMessage(title, desc);
        }
    }
    private function OnTalkActionCallback(cmd:String, parameters:Array<String>):Void {
        Global.Game.RunCallbackFiltered(LogicCallbacks.TALK_ACTION, new TalkActionParams(talkSystem, cmd, parameters), cmd);
    }
    // #endregion

    private function UpdateProducts():Void {
        products = [];
        var productEntries = Main.SaveManager.GetUnlockedProducts();
        Main.StoreManager.GetOrderedProducts(productEntries, productsPerRow, products);
    }
    private function UpdatePage():Void {
        var viewDatas = Lambda.array(Lambda.map(sliceProducts(page * productsPerPage, productsPerPage), c -> Main.StoreManager.GetProductViewData(c)));
        ui.SetProducts(viewDatas);

        var totalPages = GetTotalPages();
        var interactable = totalPages > 1;
        ui.SetPageButtonInteractable(interactable, interactable);

        ui.SetPageNumber(Main.LanguageManager._(PAGE_TEMPLATE, [page + 1, totalPages]));
    }
    // PORT-NOTE: C# LINQ `Skip(...).Take(...)`.
    private function sliceProducts(skip:Int, take:Int):Array<NamespaceID> {
        var result:Array<NamespaceID> = [];
        var start = skip < 0 ? 0 : skip;
        var end = Std.int(Math.min(start + take, products.length));
        for (i in start...end) result.push(products[i]);
        return result;
    }
    private function GetTotalPages():Int {
        return Mathf.CeilToInt(products.length / productsPerPage);
    }
    private function ShowChat():Void {
        var chat = Main.StoreManager.GetRandomChat(characterId, chatRNG);
        if (chat == null)
            return;
        var message = GetTranslatedString(LogicStrings.CONTEXT_STORE_TALK, chat.Text, []);
        ui.ShowTalk(message);
        var soundID = chat.Sound;
        if (NamespaceID.IsValid(soundID))
            Main.SoundManager.Play2D(soundID);
    }
    private function UpdateMoney():Void {
        // PORT-NOTE: C# numeric format "N0" (thousands separator).
        ui.SetMoney(formatN0(Main.SaveManager.GetMoney()));
    }
    private static function formatN0(value:Int):String {
        var negative = value < 0;
        var s = Std.string(negative ? -value : value);
        var grouped = "";
        var count = 0;
        var i = s.length - 1;
        while (i >= 0) {
            grouped = s.charAt(i) + grouped;
            count++;
            if (count % 3 == 0 && i > 0) grouped = "," + grouped;
            i--;
        }
        return negative ? "-" + grouped : grouped;
    }
    private function GetCurrentProduct(index:Int):NamespaceID {
        var i = page * productsPerPage + index;
        if (i < 0 || i >= products.length)
            return null;
        return products[i];
    }
    private function ResetChatTimeout():Void {
        chatTimeout = MAX_CHAT_TIMEOUT;
    }
    private function GetTranslatedString(context:String, text:String, args:Array<Dynamic>):String {
        if (text == null || text.length == 0)
            return "";
        return Main.LanguageManager._p(context, text, args);
    }

    @:translateMsg("商店对话框标题")
    public static inline var PURCHASE:String = "购买物品";
    @:translateMsg("商店对话框内容，{0}为价格", "selfPlural")
    public static inline var PURCHASE_DESCRIPTION:String = "确定以{0:N0}的价格买下这个物品？";
    @:translateMsg("商店对话框标题")
    public static inline var INSUFFICIENT_MONEY:String = "金钱不足";
    @:translateMsg("商店对话框内容")
    public static inline var INSUFFICIENT_MONEY_DESCRIPTION:String = "你没有足够的金钱！";
    @:translateMsg("商店的页面计数，{0}为当前页面，{1}为总页面")
    public static inline var PAGE_TEMPLATE:String = "{0}/{1}";

    private var Main(get, never):MainManager;
    inline function get_Main():MainManager return MainManager.Instance;

    private var products:Array<NamespaceID> = [];
    private static inline var MAX_CHAT_TIMEOUT:Float = 10;
    private static inline var MAX_CHAT_FADE_TIMEOUT:Float = 5;
    private var chatTimeout:Float;
    private var chatFadeTimeout:Float;
    private var characterId:NamespaceID = null;
    private var pointingProduct:Bool;
    private var page:Int;
    private var chatRNG:RandomGenerator = null;
    private var talkSystem:ITalkSystem = null;


    @:serializeField
    private var cameraShakeRoot:Transform = null;
    @:serializeField
    private var ui:StoreUI = null;
    @:serializeField
    private var talkController:TalkController = null;
    @:serializeField
    private var character:TalkCharacterController = null;
    @:serializeField
    private var productsPerRow:Int = 4;
    @:serializeField
    private var productsPerPage:Int = 8;

    // PORT-NOTE: C# string.GetHashCode 的对应物（Haxe 的 String 无 hashCode）。
    private static function hashCodeOf(s:String):Int {
        var h = 0;
        if (s != null) {
            for (i in 0...s.length)
                h = 31 * h + s.charCodeAt(i);
        }
        return h & 0x7FFFFFFF;
    }
}
