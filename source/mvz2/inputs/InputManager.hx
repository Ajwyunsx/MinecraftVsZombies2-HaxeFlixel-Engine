// Ported from: Assets/Scripts/MVZ2/Managers/InputManager.cs
//             合并了 InputManager_Keys.cs（partial class 合并为单文件）。
package mvz2.inputs;

import mvz2.managers.MainManager;
import mvz2logic.callbacks.LogicCallbacks;
import mvz2logic.callbacks.LogicCallbacks.PostPointerActionParams;
import mvz2logic.games.IGlobalInput;
import mvz2logic.inputs.PointerPhase;
import mvz2logic.inputs.PointerTypes;
import mvz2logic.inputs.InputHelper;
// PORT-NOTE: IGlobalInput 的 out 参数按工程约定改为 tools.Ref<T> 容器。
import tools.Ref;
import unity.*;
import unity.Debug;
import mvz2.gamecontent.commands.Clear;
import mvz2.localization.LanguageManager;
import Main;
import unity.Touch.TouchPhase;

class InputManager extends MonoBehaviour implements IGlobalInput
{
	// #region 检测指针状态
	public function GetActivePointerType():Int
	{
		return currentPointerType;
	}
	// #endregion

	private function Update():Void
	{
		UpdatePointer();
		UpdateKeys();
	}
	private function UpdatePointer():Void
	{
		if (currentPointerType == PointerTypes.MOUSE)
		{
			if (Input.touchCount > 0)
			{
				currentPointerType = PointerTypes.TOUCH;
			}
		}
		else if (currentPointerType == PointerTypes.TOUCH)
		{
			if (Input.touchCount <= 0 && Input.mousePresent)
			{
				var mousePos = Input.mousePosition;
				if (mousePos.x >= 0 && mousePos.y >= 0 && mousePos.x <= Screen.width && mousePos.y <= Screen.height)
				{
					for (mouse in 0...3)
					{
						if (Input.GetMouseButtonDown(mouse))
						{
							currentPointerType = PointerTypes.MOUSE;
							break;
						}
					}
				}
			}
		}

		switch (currentPointerType)
		{
			case PointerTypes.MOUSE:
				{
					// PORT-NOTE: C# 依赖 Vector3 -> Vector2 的隐式转换；Haxe 的 unity.Vector3 只提供
					// Vector2 -> Vector3 的 @:from，故此处显式取 x/y 构造 Vector2。
					var position = new Vector2(Input.mousePosition.x, Input.mousePosition.y);
					// PORT-NOTE: C# `position - lastMousePosition`，Haxe abstract 用运算符重载。
					var delta = position - lastMousePosition;
					lastMousePosition = position;
					for (mouse in 0...3)
					{
						var hasState = false;
						if (Input.GetMouseButtonDown(mouse))
						{
							hasState = true;
							PollPointerEvent(currentPointerType, mouse, position, delta, PointerPhase.Press);
						}
						if (Input.GetMouseButton(mouse))
						{
							hasState = true;
							PollPointerEvent(currentPointerType, mouse, position, delta, PointerPhase.Hold);
						}
						if (Input.GetMouseButtonUp(mouse))
						{
							hasState = true;
							PollPointerEvent(currentPointerType, mouse, position, delta, PointerPhase.Release);
						}
						if (!hasState)
						{
							PollPointerEvent(currentPointerType, mouse, position, delta, PointerPhase.None);
						}
					}
				}
			case PointerTypes.TOUCH:
				var touchCount = Input.touchCount;
				for (i in 0...touchCount)
				{
					var touch = Input.GetTouch(i);
					var phase = PointerPhase.Hold;
					switch (touch.phase)
					{
						case TouchPhase.Began:
							phase = PointerPhase.Press;
						case TouchPhase.Ended, TouchPhase.Canceled:
							phase = PointerPhase.Release;
						default:
					}
					var delta = Vector2.zero;
					if (lastTouchPositions.length > i)
					{
						delta = touch.position - lastTouchPositions[i];
						lastTouchPositions[i] = touch.position;
					}
					else
					{
						lastTouchPositions.push(touch.position);
					}
					PollPointerEvent(currentPointerType, touch.fingerId, touch.position, delta, phase);
				}
				if (lastTouchPositions.length > touchCount)
					lastTouchPositions.splice(touchCount, lastTouchPositions.length - touchCount);
			default:
		}
		FlushPointerCaches();
	}
	private function FlushPointerCaches():Void
	{
		for (poll in pointerEventCacheList)
		{
			// PORT-NOTE: C# 原逻辑是 `new PostPointerActionParams { ... }` 对象初始化器；
			// Haxe 侧 LogicCallbacks.PostPointerActionParams 只提供带参构造。
			var param = new PostPointerActionParams(poll.type, poll.button, poll.position, poll.delta, poll.phase);
			Main.Game.RunCallbackFiltered(LogicCallbacks.POST_POINTER_ACTION, param, param.phase);
		}
		pointerEventCacheList = [];
	}
	private function PollPointerEvent(type:Int, button:Int, screenPosition:Vector2, delta:Vector2, phase:PointerPhase):Void
	{
		var cache = new PointerEventCacheData();
		cache.type = type;
		cache.button = button;
		cache.position = screenPosition;
		cache.phase = phase;
		cache.delta = delta;
		pointerEventCacheList.push(cache);
	}
	public function GetPointerScreenPosition():Vector2
	{
		return GetPointerScreenPositionByType(currentPointerType, 0);
	}
	// TODO-PORT: C# 同名重载 `GetPointerScreenPosition(int type, int button)`，重命名以区分。
	public function GetPointerScreenPositionByType(type:Int, button:Int):Vector2
	{
		return InputHelper.GetPointerPositionByButton(type, button);
	}
	// PORT-NOTE: IGlobalInput 统一使用 tools.Ref<Vector2> 表达 C# 的 out 参数。
	public function TryGetPointerScreenPosition(screenPosition:Ref<Vector2>):Bool
	{
		return TryGetPointerScreenPositionByType(currentPointerType, 0, screenPosition);
	}
	// TODO-PORT: C# 同名重载 `TryGetPointerScreenPosition(int, int, out Vector2)`。
	public function TryGetPointerScreenPositionByType(type:Int, button:Int, screenPosition:Ref<Vector2>):Bool
	{
		return InputHelper.TryGetPointerPosition(type, button, screenPosition);
	}
	public function IsPointerDown(type:Int, button:Int):Bool
	{
		// PORT-NOTE: C# 重载 `IsPointerDown(int type, int button)` 在 Haxe 中改名为
		// InputHelper.IsPointerDownByButton(type, button)（Haxe 无重载）。
		return InputHelper.IsPointerDownByButton(type, button);
	}
	public function IsPointerHolding(type:Int, button:Int):Bool
	{
		return InputHelper.IsPointerHoldingByButton(type, button);
	}
	public function IsPointerUp(type:Int, button:Int):Bool
	{
		return InputHelper.IsPointerUpByButton(type, button);
	}
	public var Main(get, never):MainManager;
	function get_Main():MainManager return MainManager.Instance;
	private var currentPointerType:Int = PointerTypes.MOUSE;
	private var lastMousePosition:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	private var lastTouchPositions:Array<Vector2> = [];
	private var pointerEventCacheList:Array<PointerEventCacheData> = [];

	// ===== InputManager_Keys.cs =====
	public function GetKeyDownOrHold(keycode:KeyCode):Bool
	{
		if (Input.GetKeyDown(keycode))
			return true;
		if (heldKeys.exists(keycode))
		{
			var heldTime = heldKeys.get(keycode);
			return Time.time - heldTime > keyHoldTimeThresold;
		}
		return false;
	}
	private function UpdateKeys():Void
	{
		for (keycode in keyInfos.keys())
		{
			if (Input.GetKeyDown(keycode))
			{
				heldKeys.set(keycode, Time.time);
			}
			if (Input.GetKeyUp(keycode))
			{
				heldKeys.remove(keycode);
			}
		}
	}
	public function InitKeys():Void
	{
		keyInfos.clear();
		AddKeyInfo(KeyCode.None, KEYNAME_NONE);
		AddKeyInfo(KeyCode.Backspace, KEYNAME_BACKSPACE);
		AddKeyInfo(KeyCode.Delete, KEYNAME_DELETE);
		AddKeyInfo(KeyCode.Tab, KEYNAME_TAB);
		AddKeyInfo(KeyCode.Clear, KEYNAME_CLEAR);
		AddKeyInfo(KeyCode.Return, KEYNAME_RETURN);
		AddKeyInfo(KeyCode.Pause, KEYNAME_PAUSE);
		AddKeyInfo(KeyCode.Escape, KEYNAME_ESCAPE);
		AddKeyInfo(KeyCode.Space, KEYNAME_SPACE);

		AddKeyInfo(KeyCode.Keypad0, KEYNAME_KEYPAD0);
		AddKeyInfo(KeyCode.Keypad1, KEYNAME_KEYPAD1);
		AddKeyInfo(KeyCode.Keypad2, KEYNAME_KEYPAD2);
		AddKeyInfo(KeyCode.Keypad3, KEYNAME_KEYPAD3);
		AddKeyInfo(KeyCode.Keypad4, KEYNAME_KEYPAD4);
		AddKeyInfo(KeyCode.Keypad5, KEYNAME_KEYPAD5);
		AddKeyInfo(KeyCode.Keypad6, KEYNAME_KEYPAD6);
		AddKeyInfo(KeyCode.Keypad7, KEYNAME_KEYPAD7);
		AddKeyInfo(KeyCode.Keypad8, KEYNAME_KEYPAD8);
		AddKeyInfo(KeyCode.Keypad9, KEYNAME_KEYPAD9);
		AddKeyInfo(KeyCode.KeypadPeriod, KEYNAME_KEYPADPERIOD);
		AddKeyInfo(KeyCode.KeypadDivide, KEYNAME_KEYPADDIVIDE);
		AddKeyInfo(KeyCode.KeypadMultiply, KEYNAME_KEYPADMULTIPLY);
		AddKeyInfo(KeyCode.KeypadMinus, KEYNAME_KEYPADMINUS);
		AddKeyInfo(KeyCode.KeypadPlus, KEYNAME_KEYPADPLUS);
		AddKeyInfo(KeyCode.KeypadEnter, KEYNAME_KEYPADENTER);
		AddKeyInfo(KeyCode.KeypadEquals, KEYNAME_KEYPADEQUALS);

		AddKeyInfo(KeyCode.UpArrow, KEYNAME_UPARROW);
		AddKeyInfo(KeyCode.DownArrow, KEYNAME_DOWNARROW);
		AddKeyInfo(KeyCode.RightArrow, KEYNAME_RIGHTARROW);
		AddKeyInfo(KeyCode.LeftArrow, KEYNAME_LEFTARROW);

		AddKeyInfo(KeyCode.Insert, KEYNAME_INSERT);
		AddKeyInfo(KeyCode.Home, KEYNAME_HOME);
		AddKeyInfo(KeyCode.End, KEYNAME_END);
		AddKeyInfo(KeyCode.PageUp, KEYNAME_PAGEUP);
		AddKeyInfo(KeyCode.PageDown, KEYNAME_PAGEDOWN);

		AddKeyInfo(KeyCode.F1, KEYNAME_F1);
		AddKeyInfo(KeyCode.F2, KEYNAME_F2);
		AddKeyInfo(KeyCode.F3, KEYNAME_F3);
		AddKeyInfo(KeyCode.F4, KEYNAME_F4);
		AddKeyInfo(KeyCode.F5, KEYNAME_F5);
		AddKeyInfo(KeyCode.F6, KEYNAME_F6);
		AddKeyInfo(KeyCode.F7, KEYNAME_F7);
		AddKeyInfo(KeyCode.F8, KEYNAME_F8);
		AddKeyInfo(KeyCode.F9, KEYNAME_F9);
		AddKeyInfo(KeyCode.F10, KEYNAME_F10);
		AddKeyInfo(KeyCode.F11, KEYNAME_F11);
		AddKeyInfo(KeyCode.F12, KEYNAME_F12);
		AddKeyInfo(KeyCode.F13, KEYNAME_F13);
		AddKeyInfo(KeyCode.F14, KEYNAME_F14);
		AddKeyInfo(KeyCode.F15, KEYNAME_F15);

		AddKeyInfo(KeyCode.Alpha0, KEYNAME_ALPHA0);
		AddKeyInfo(KeyCode.Alpha1, KEYNAME_ALPHA1);
		AddKeyInfo(KeyCode.Alpha2, KEYNAME_ALPHA2);
		AddKeyInfo(KeyCode.Alpha3, KEYNAME_ALPHA3);
		AddKeyInfo(KeyCode.Alpha4, KEYNAME_ALPHA4);
		AddKeyInfo(KeyCode.Alpha5, KEYNAME_ALPHA5);
		AddKeyInfo(KeyCode.Alpha6, KEYNAME_ALPHA6);
		AddKeyInfo(KeyCode.Alpha7, KEYNAME_ALPHA7);
		AddKeyInfo(KeyCode.Alpha8, KEYNAME_ALPHA8);
		AddKeyInfo(KeyCode.Alpha9, KEYNAME_ALPHA9);

		AddKeyInfo(KeyCode.Exclaim, KEYNAME_EXCLAIM);
		AddKeyInfo(KeyCode.DoubleQuote, KEYNAME_DOUBLEQUOTE);
		AddKeyInfo(KeyCode.Hash, KEYNAME_HASH);
		AddKeyInfo(KeyCode.Dollar, KEYNAME_DOLLAR);
		AddKeyInfo(KeyCode.Percent, KEYNAME_PERCENT);
		AddKeyInfo(KeyCode.Ampersand, KEYNAME_AMPERSAND);
		AddKeyInfo(KeyCode.Quote, KEYNAME_QUOTE);
		AddKeyInfo(KeyCode.LeftParen, KEYNAME_LEFTPAREN);
		AddKeyInfo(KeyCode.RightParen, KEYNAME_RIGHTPAREN);
		AddKeyInfo(KeyCode.Asterisk, KEYNAME_ASTERISK);
		AddKeyInfo(KeyCode.Plus, KEYNAME_PLUS);
		AddKeyInfo(KeyCode.Comma, KEYNAME_COMMA);
		AddKeyInfo(KeyCode.Minus, KEYNAME_MINUS);
		AddKeyInfo(KeyCode.Period, KEYNAME_PERIOD);
		AddKeyInfo(KeyCode.Slash, KEYNAME_SLASH);
		AddKeyInfo(KeyCode.Colon, KEYNAME_COLON);
		AddKeyInfo(KeyCode.Semicolon, KEYNAME_SEMICOLON);
		AddKeyInfo(KeyCode.Less, KEYNAME_LESS);
		AddKeyInfo(KeyCode.Equals, KEYNAME_EQUALS);
		AddKeyInfo(KeyCode.Greater, KEYNAME_GREATER);
		AddKeyInfo(KeyCode.Question, KEYNAME_QUESTION);
		AddKeyInfo(KeyCode.At, KEYNAME_AT);

		AddKeyInfo(KeyCode.LeftBracket, KEYNAME_LEFTBRACKET);
		AddKeyInfo(KeyCode.Backslash, KEYNAME_BACKSLASH);
		AddKeyInfo(KeyCode.RightBracket, KEYNAME_RIGHTBRACKET);
		AddKeyInfo(KeyCode.Caret, KEYNAME_CARET);
		AddKeyInfo(KeyCode.Underscore, KEYNAME_UNDERSCORE);
		AddKeyInfo(KeyCode.BackQuote, KEYNAME_BACKQUOTE);
		AddKeyInfo(KeyCode.A, KEYNAME_A);
		AddKeyInfo(KeyCode.B, KEYNAME_B);
		AddKeyInfo(KeyCode.C, KEYNAME_C);
		AddKeyInfo(KeyCode.D, KEYNAME_D);
		AddKeyInfo(KeyCode.E, KEYNAME_E);
		AddKeyInfo(KeyCode.F, KEYNAME_F);
		AddKeyInfo(KeyCode.G, KEYNAME_G);
		AddKeyInfo(KeyCode.H, KEYNAME_H);
		AddKeyInfo(KeyCode.I, KEYNAME_I);
		AddKeyInfo(KeyCode.J, KEYNAME_J);
		AddKeyInfo(KeyCode.K, KEYNAME_K);
		AddKeyInfo(KeyCode.L, KEYNAME_L);
		AddKeyInfo(KeyCode.M, KEYNAME_M);
		AddKeyInfo(KeyCode.N, KEYNAME_N);
		AddKeyInfo(KeyCode.O, KEYNAME_O);
		AddKeyInfo(KeyCode.P, KEYNAME_P);
		AddKeyInfo(KeyCode.Q, KEYNAME_Q);
		AddKeyInfo(KeyCode.R, KEYNAME_R);
		AddKeyInfo(KeyCode.S, KEYNAME_S);
		AddKeyInfo(KeyCode.T, KEYNAME_T);
		AddKeyInfo(KeyCode.U, KEYNAME_U);
		AddKeyInfo(KeyCode.V, KEYNAME_V);
		AddKeyInfo(KeyCode.W, KEYNAME_W);
		AddKeyInfo(KeyCode.X, KEYNAME_X);
		AddKeyInfo(KeyCode.Y, KEYNAME_Y);
		AddKeyInfo(KeyCode.Z, KEYNAME_Z);

		AddKeyInfo(KeyCode.LeftCurlyBracket, KEYNAME_LEFTCURLYBRACKET);
		AddKeyInfo(KeyCode.Pipe, KEYNAME_PIPE);
		AddKeyInfo(KeyCode.RightCurlyBracket, KEYNAME_RIGHTCURLYBRACKET);
		AddKeyInfo(KeyCode.Tilde, KEYNAME_TILDE);

		AddKeyInfo(KeyCode.Numlock, KEYNAME_NUMLOCK);
		AddKeyInfo(KeyCode.CapsLock, KEYNAME_CAPSLOCK);
		AddKeyInfo(KeyCode.ScrollLock, KEYNAME_SCROLLLOCK);
		AddKeyInfo(KeyCode.RightShift, KEYNAME_RIGHTSHIFT);
		AddKeyInfo(KeyCode.LeftShift, KEYNAME_LEFTSHIFT);
		AddKeyInfo(KeyCode.RightControl, KEYNAME_RIGHTCONTROL);
		AddKeyInfo(KeyCode.LeftControl, KEYNAME_LEFTCONTROL);
		AddKeyInfo(KeyCode.RightAlt, KEYNAME_RIGHTALT);
		AddKeyInfo(KeyCode.LeftAlt, KEYNAME_LEFTALT);
		AddKeyInfo(KeyCode.LeftCommand, KEYNAME_LEFTCOMMAND);
		AddKeyInfo(KeyCode.LeftWindows, KEYNAME_LEFTWINDOWS);
		AddKeyInfo(KeyCode.RightCommand, KEYNAME_RIGHTCOMMAND);
		AddKeyInfo(KeyCode.RightWindows, KEYNAME_RIGHTWINDOWS);
		AddKeyInfo(KeyCode.AltGr, KEYNAME_ALTGR);
		AddKeyInfo(KeyCode.Print, KEYNAME_PRINT);
		AddKeyInfo(KeyCode.Menu, KEYNAME_MENU);
	}
	public function GetKeyCodeNameKey(keycode:KeyCode):String
	{
		var info = GetKeyCodeInfo(keycode);
		if (info == null)
			return KEYNAME_UNKNOWN;
		return info.name;
	}
	public function GetKeyCodeName(keycode:KeyCode):String
	{
		var nameKey = GetKeyCodeNameKey(keycode);
		return Main.LanguageManager._p(InputManager.CONTEXT_KEY_NAME, nameKey);
	}
	public function GetCurrentPressedKey():KeyCode
	{
		for (pair in keyInfos.keyValueIterator())
		{
			if (Input.GetKeyDown(pair.key))
				return pair.key;
		}
		return KeyCode.None;
	}
	public function GetKeyCodeInfo(keycode:KeyCode):KeyCodeInfo
	{
		if (keyInfos.exists(keycode))
		{
			return keyInfos.get(keycode);
		}
		return null;
	}
	private function AddKeyInfo(code:KeyCode, name:String):Void
	{
		keyInfos.set(code, new KeyCodeInfo(code, name));
	}
	public var keyInfos:Map<KeyCode, KeyCodeInfo> = new Map();
	public var heldKeys:Map<KeyCode, Float> = new Map();
	@:serializeField
	private var keyHoldTimeThresold:Float = 0.5;

	public static inline var CONTEXT_KEY_NAME:String = "key.name";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_UNKNOWN:String = "未知";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_NONE:String = "无";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_BACKSPACE:String = "Backspace";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_DELETE:String = "Delete";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_TAB:String = "Tab";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_CLEAR:String = "Clear";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_RETURN:String = "Enter";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_PAUSE:String = "Pause";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_ESCAPE:String = "Escape";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_SPACE:String = "Space";

	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPAD0:String = "小键盘 0";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPAD1:String = "小键盘 1";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPAD2:String = "小键盘 2";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPAD3:String = "小键盘 3";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPAD4:String = "小键盘 4";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPAD5:String = "小键盘 5";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPAD6:String = "小键盘 6";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPAD7:String = "小键盘 7";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPAD8:String = "小键盘 8";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPAD9:String = "小键盘 9";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPADPERIOD:String = "小键盘 .";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPADDIVIDE:String = "小键盘 /";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPADMULTIPLY:String = "小键盘 *";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPADMINUS:String = "小键盘 -";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPADPLUS:String = "小键盘 +";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPADENTER:String = "小键盘 Enter";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_KEYPADEQUALS:String = "小键盘 =";

	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_UPARROW:String = "↑";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_DOWNARROW:String = "↓";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_RIGHTARROW:String = "→";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_LEFTARROW:String = "←";

	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_INSERT:String = "Insert";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_HOME:String = "Home";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_END:String = "End";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_PAGEUP:String = "PageUp";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_PAGEDOWN:String = "PageDown";

	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F1:String = "F1";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F2:String = "F2";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F3:String = "F3";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F4:String = "F4";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F5:String = "F5";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F6:String = "F6";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F7:String = "F7";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F8:String = "F8";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F9:String = "F9";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F10:String = "F10";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F11:String = "F11";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F12:String = "F12";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F13:String = "F13";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F14:String = "F14";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F15:String = "F15";

	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_ALPHA0:String = "0";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_ALPHA1:String = "1";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_ALPHA2:String = "2";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_ALPHA3:String = "3";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_ALPHA4:String = "4";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_ALPHA5:String = "5";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_ALPHA6:String = "6";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_ALPHA7:String = "7";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_ALPHA8:String = "8";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_ALPHA9:String = "9";

	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_EXCLAIM:String = "!";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_DOUBLEQUOTE:String = "\"";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_HASH:String = "#";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_DOLLAR:String = "$";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_PERCENT:String = "%";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_AMPERSAND:String = "&";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_QUOTE:String = "'";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_LEFTPAREN:String = "(";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_RIGHTPAREN:String = ")";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_ASTERISK:String = "*";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_PLUS:String = "+";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_COMMA:String = ",";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_MINUS:String = "-";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_PERIOD:String = ".";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_SLASH:String = "/";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_COLON:String = ":";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_SEMICOLON:String = ";";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_LESS:String = "<";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_EQUALS:String = "=";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_GREATER:String = ">";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_QUESTION:String = "?";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_AT:String = "@";

	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_LEFTBRACKET:String = "[";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_BACKSLASH:String = "\\";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_RIGHTBRACKET:String = "]";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_CARET:String = "^";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_UNDERSCORE:String = "_";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_BACKQUOTE:String = "`";

	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_A:String = "A";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_B:String = "B";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_C:String = "C";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_D:String = "D";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_E:String = "E";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_F:String = "F";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_G:String = "G";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_H:String = "H";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_I:String = "I";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_J:String = "J";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_K:String = "K";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_L:String = "L";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_M:String = "M";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_N:String = "N";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_O:String = "O";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_P:String = "P";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_Q:String = "Q";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_R:String = "R";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_S:String = "S";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_T:String = "T";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_U:String = "U";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_V:String = "V";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_W:String = "W";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_X:String = "X";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_Y:String = "Y";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_Z:String = "Z";

	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_LEFTCURLYBRACKET:String = "{";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_PIPE:String = "|";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_RIGHTCURLYBRACKET:String = "}";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_TILDE:String = "~";

	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_NUMLOCK:String = "Numlock";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_CAPSLOCK:String = "CapsLock";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_SCROLLLOCK:String = "ScrollLock";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_RIGHTSHIFT:String = "右Shift";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_LEFTSHIFT:String = "左Shift";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_RIGHTCONTROL:String = "右Ctrl";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_LEFTCONTROL:String = "左Ctrl";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_RIGHTALT:String = "右Alt";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_LEFTALT:String = "左Alt";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_LEFTCOMMAND:String = "左Command";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_LEFTWINDOWS:String = "左Windows";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_RIGHTCOMMAND:String = "右Command";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_RIGHTWINDOWS:String = "右Windows";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_ALTGR:String = "AltGr";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_PRINT:String = "Print";
	@:translateMsg("按键名", CONTEXT_KEY_NAME) public static inline var KEYNAME_MENU:String = "Menu";
}

class KeyCodeInfo
{
	public function new(code:KeyCode, name:String)
	{
		this.code = code;
		this.name = name;
	}
	public var code:KeyCode;
	public var name:String;
}

class PointerEventCacheData
{
	public var type:Int;
	public var button:Int;
	public var position:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public var delta:Vector2 = new Vector2(0, 0); // PORT-NOTE: C# Vector2 为 struct，默认 (0,0)；显式初始化避免 abstract-over-class 的 null 解引用
	public var phase:PointerPhase;

	public function ToString():String
	{
		return 'type: $type, button: $button, position: $position, delta: $delta, phase: $phase';
	}
	public function new() {}
}
