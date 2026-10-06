// Ported from: Assets/Scripts/View/DebugConsole/DebugConsoleInputField.cs
package mvz2.ui.debugconsole;


import unity.Animator;
import unity.Color;
import unity.Component;
import unity.GameObject;
import unity.RectTransform;
import unity.UnityObject;
import unity.Vector2;
import unity.events.UnityEvent1;
import unity.eventsystems.BaseEventData;
import unity.eventsystems.IEventSystemHandler;
import unity.eventsystems.PointerEventData;
import unity.tmpro.TMP_TextInfo;
import unity.tmpro.TMP_FontAsset;
import unity.tmpro.TMP_Text;
import unity.tmpro.TextMeshProUGUI;
import unity.ui.Graphic;
import unity.ui.Selectable;
import unity.eventsystems.EventSystem;
import unity.Mathf;
import unity.RectTransformUtility;
import unity.Time;
import unity.events.UnityEventBase;
import unity.eventsystems.IEventSystemHandler.IBeginDragHandler;
import unity.eventsystems.IEventSystemHandler.IDragHandler;
import unity.eventsystems.IEventSystemHandler.IEndDragHandler;
import unity.eventsystems.IEventSystemHandler.IPointerClickHandler;
import unity.eventsystems.IEventSystemHandler.IScrollHandler;
import unity.eventsystems.IEventSystemHandler.ISubmitHandler;
import unity.eventsystems.IEventSystemHandler.IUpdateSelectedHandler;
import unity.eventsystems.PointerEventData.InputButton;
import unity.tmpro.TMP_Text.TMP_InputValidator;
import unity.ui.Selectable.CanvasUpdate;
import unity.ui.Selectable.SelectionState;

// PORT-NOTE: 原 C# 文件是 Unity 官方 TMP_InputField 的整份 vendored 副本（4543 行，含 TMP 网格/光标渲染、
// 软键盘、IME、RichText 布局等引擎内部实现）。移植策略：
//   - 保留全部公开 API（属性 / 事件 / 枚举 / 公开方法）与输入法无关的编辑逻辑（光标/选区/校验/增删）。
//   - TMP 内部实现（Mesh 生成、光标顶点、RectMask2D、CanvasUpdateRegistry、TMPro_EventManager、软键盘）
//     在 Haxe 侧没有等价实现，统一以空实现占位并标注 TODO-PORT，与 unity.tmpro.TMP_InputField shim 的处理一致。
class DebugConsoleInputField extends Selectable implements IUpdateSelectedHandler implements IBeginDragHandler implements IDragHandler implements IEndDragHandler implements IPointerClickHandler implements ISubmitHandler implements IScrollHandler
{
	public function new()
	{
		super();
		SetTextComponentWrapMode();
	}

	// Setting the content type acts as a shortcut for setting a combination of InputType, CharacterValidation, LineType, and TouchScreenKeyboardType
	public var contentType(get, set):ContentType;
	function get_contentType():ContentType return m_ContentType;
	function set_contentType(value:ContentType):ContentType
	{
		if (m_ContentType != value)
		{
			m_ContentType = value;
			EnforceContentType();
		}
		return value;
	}
	private var m_ContentType:ContentType = ContentType.Standard;

	public var inputType(get, set):InputType;
	function get_inputType():InputType return m_InputType;
	function set_inputType(value:InputType):InputType
	{
		if (m_InputType != value)
		{
			m_InputType = value;
			SetToCustom();
		}
		return value;
	}
	private var m_InputType:InputType = InputType.Standard;

	private var m_AsteriskChar:String = "*";
	private var m_KeyboardType:Int = 0; // TouchScreenKeyboardType.Default
	private var m_LineType:LineType = LineType.SingleLine;
	private var m_HideMobileInput:Bool = false;
	private var m_HideSoftKeyboard:Bool = false;

	public var characterValidation(get, set):CharacterValidation;
	function get_characterValidation():CharacterValidation return m_CharacterValidation;
	function set_characterValidation(value:CharacterValidation):CharacterValidation
	{
		if (m_CharacterValidation != value)
		{
			m_CharacterValidation = value;
			SetToCustom();
		}
		return value;
	}
	private var m_CharacterValidation:CharacterValidation = CharacterValidation.None;
	private var m_RegexValue:String = "";
	private var m_GlobalPointSize:Float = 14;
	private var m_CharacterLimit:Int = 0;
	private var m_OnEndEdit:SubmitEvent = new SubmitEvent();
	private var m_OnSubmit:SubmitEvent = new SubmitEvent();
	private var m_OnSelect:SelectionEvent = new SelectionEvent();
	private var m_OnDeselect:SelectionEvent = new SelectionEvent();
	private var m_OnTextSelection:TextSelectionEvent = new TextSelectionEvent();
	private var m_OnEndTextSelection:TextSelectionEvent = new TextSelectionEvent();
	private var m_OnValueChanged:OnChangeEvent = new OnChangeEvent();
	private var m_OnValidateInput:Null<OnValidateInput>;
	private var m_CaretColor:Color = new Color(50.0 / 255.0, 50.0 / 255.0, 50.0 / 255.0, 1);
	private var m_CustomCaretColor:Bool = false;
	private var m_SelectionColor:Color = new Color(168.0 / 255.0, 206.0 / 255.0, 255.0 / 255.0, 192.0 / 255.0);
	private var m_Text:String = "";
	private var m_CaretBlinkRate:Float = 0.85;
	private var m_CaretWidth:Int = 1;
	private var m_ReadOnly:Bool = false;
	private var m_RichText:Bool = true;
	private var m_StringPosition:Int = 0;
	private var m_StringSelectPosition:Int = 0;
	private var m_CaretPosition:Int = 0;
	private var m_CaretSelectPosition:Int = 0;
	// PORT-NOTE: C# 的 UIVertex[]/Mesh/CanvasRenderer/RectTransform 光标顶点与网格成员在 Haxe 侧无对应实现。
	// TODO-PORT: 光标与选区的顶点渲染（m_CursorVerts / caretRectTrans / m_CachedInputRenderer / m_Mesh）。
	private var m_LastPosition:Vector2 = new Vector2();
	private var m_AllowInput:Bool = false;
	private var m_ShouldActivateNextUpdate:Bool = false;
	private var m_ScrollPosition:Float = 0;
	private var m_UpdateDrag:Bool = false;
	private var m_DragPositionOutOfBounds:Bool = false;
	private static inline var kHScrollSpeed:Float = 0.05;
	private static inline var kVScrollSpeed:Float = 0.10;
	private var m_CaretVisible:Bool;
	private var m_BlinkStartTime:Float = 0;
	private var m_OriginalText:String = "";
	private var m_WasCanceled:Bool = false;
	private var m_HasDoneFocusTransition:Bool = false;
	private var m_PreventCallback:Bool = false;
	private var m_IsTextComponentUpdateRequired:Bool = false;
	private var m_isLastKeyBackspace:Bool = false;
	private var m_PointerDownClickStartTime:Float;
	private var m_KeyDownStartTime:Float;
	private var m_DoubleClickDelay:Float = 0.5;
	private static inline var kEmailSpecialCharacters:String = "!#$%&'*+-/=?^_`{|}~";

	private var m_IsCompositionActive:Bool = false;
	private var m_ShouldUpdateIMEWindowPosition:Bool = false;
	private var m_PreviousIMEInsertionLine:Int = 0;

	// PORT-NOTE: unity.tmpro 兼容层未提供 BaseInput / 软键盘输入法合成串，用空串替代。
	public var compositionLength(get, never):Int;
	function get_compositionLength():Int
	{
		if (m_ReadOnly)
			return 0;

		return compositionString.length;
	}
	private var compositionString(get, never):String;
	function get_compositionString():String return "";

	// Should the mobile keyboard input be hidden.
	public var shouldHideMobileInput(get, never):Bool;
	function get_shouldHideMobileInput():Bool return true;

	public var shouldHideSoftKeyboard(get, never):Bool;
	function get_shouldHideSoftKeyboard():Bool return true;

	private function isKeyboardUsingEvents():Bool
	{
		return true;
	}

	// Input field's current text value.
	public var text(get, set):String;
	function get_text():String
	{
		return m_Text;
	}
	function set_text(value:String):String
	{
		SetText(value);
		return value;
	}

	// Set Input field's current text value without invoke onValueChanged.
	public function SetTextWithoutNotify(input:String):Void
	{
		SetText(input, false);
	}

	private function SetText(value:String, ?sendCallback:Bool = true):Void
	{
		if (text == value)
			return;

		if (value == null)
			value = "";

		value = value.split("\u0000").join(""); // remove embedded nulls

		m_Text = value;

		if (m_StringPosition > m_Text.length)
			m_StringPosition = m_StringSelectPosition = m_Text.length;
		else if (m_StringSelectPosition > m_Text.length)
			m_StringSelectPosition = m_Text.length;

		m_forceRectTransformAdjustment = true;

		m_IsTextComponentUpdateRequired = true;
		UpdateLabel();

		if (sendCallback)
			SendOnValueChanged();
	}

	public var isFocused(get, never):Bool;
	function get_isFocused():Bool return m_AllowInput;

	public var caretBlinkRate(get, set):Float;
	function get_caretBlinkRate():Float return m_CaretBlinkRate;
	function set_caretBlinkRate(value:Float):Float
	{
		if (m_CaretBlinkRate != value)
		{
			m_CaretBlinkRate = value;
			if (m_AllowInput)
				SetCaretActive();
		}
		return value;
	}

	public var caretWidth(get, set):Int;
	function get_caretWidth():Int return m_CaretWidth;
	function set_caretWidth(value:Int):Int
	{
		if (m_CaretWidth != value)
		{
			m_CaretWidth = value;
			MarkGeometryAsDirty();
		}
		return value;
	}

	public var textViewport(get, set):RectTransform;
	function get_textViewport():RectTransform return m_TextViewport;
	function set_textViewport(value:RectTransform):RectTransform
	{
		if (m_TextViewport != value)
		{
			m_TextViewport = value;
		}
		return value;
	}
	@:serializeField
	private var m_TextViewport:RectTransform;

	public var textComponent(get, set):TMP_Text;
	function get_textComponent():TMP_Text return m_TextComponent;
	function set_textComponent(value:TMP_Text):TMP_Text
	{
		if (m_TextComponent != value)
		{
			m_TextComponent = value;
			SetTextComponentWrapMode();
		}
		return value;
	}
	@:serializeField
	private var m_TextComponent:Null<TMP_Text>;

	public var placeholder(get, set):Graphic;
	function get_placeholder():Graphic return m_Placeholder;
	function set_placeholder(value:Graphic):Graphic
	{
		if (m_Placeholder != value)
		{
			m_Placeholder = value;
		}
		return value;
	}
	@:serializeField
	private var m_Placeholder:Graphic;

	public var scrollSensitivity(get, set):Float;
	function get_scrollSensitivity():Float return m_ScrollSensitivity;
	function set_scrollSensitivity(value:Float):Float
	{
		if (m_ScrollSensitivity != value)
		{
			m_ScrollSensitivity = value;
			MarkGeometryAsDirty();
		}
		return value;
	}
	private var m_ScrollSensitivity:Float = 1.0;

	public var caretColor(get, set):Color;
	function get_caretColor():Color return customCaretColor ? m_CaretColor : textComponent.color;
	function set_caretColor(value:Color):Color
	{
		if (!colorEquals(m_CaretColor, value))
		{
			m_CaretColor = value;
			MarkGeometryAsDirty();
		}
		return value;
	}

	public var customCaretColor(get, set):Bool;
	function get_customCaretColor():Bool return m_CustomCaretColor;
	function set_customCaretColor(value:Bool):Bool
	{
		if (m_CustomCaretColor != value)
		{
			m_CustomCaretColor = value;
			MarkGeometryAsDirty();
		}
		return value;
	}

	public var selectionColor(get, set):Color;
	function get_selectionColor():Color return m_SelectionColor;
	function set_selectionColor(value:Color):Color
	{
		if (!colorEquals(m_SelectionColor, value))
		{
			m_SelectionColor = value;
			MarkGeometryAsDirty();
		}
		return value;
	}

	public var onEndEdit(get, never):SubmitEvent;
	function get_onEndEdit():SubmitEvent return m_OnEndEdit;

	public var onSubmit(get, never):SubmitEvent;
	function get_onSubmit():SubmitEvent return m_OnSubmit;

	public var onSelect(get, never):SelectionEvent;
	function get_onSelect():SelectionEvent return m_OnSelect;

	public var onDeselect(get, never):SelectionEvent;
	function get_onDeselect():SelectionEvent return m_OnDeselect;

	public var onTextSelection(get, never):TextSelectionEvent;
	function get_onTextSelection():TextSelectionEvent return m_OnTextSelection;

	public var onEndTextSelection(get, never):TextSelectionEvent;
	function get_onEndTextSelection():TextSelectionEvent return m_OnEndTextSelection;

	public var onValueChanged(get, never):OnChangeEvent;
	function get_onValueChanged():OnChangeEvent return m_OnValueChanged;

	public var onValidateInput(get, set):Null<OnValidateInput>;
	function get_onValidateInput():Null<OnValidateInput> return m_OnValidateInput;
	function set_onValidateInput(value:Null<OnValidateInput>):Null<OnValidateInput>
	{
		m_OnValidateInput = value;
		return value;
	}

	public var characterLimit(get, set):Int;
	function get_characterLimit():Int return m_CharacterLimit;
	function set_characterLimit(value:Int):Int
	{
		var clamped = Std.int(Math.max(0, value));
		if (m_CharacterLimit != clamped)
		{
			m_CharacterLimit = clamped;
			UpdateLabel();
		}
		return value;
	}

	// Set the point size on both Placeholder and Input text object.
	public var pointSize(get, set):Float;
	function get_pointSize():Float return m_GlobalPointSize;
	function set_pointSize(value:Float):Float
	{
		var clamped = Math.max(0, value);
		if (m_GlobalPointSize != clamped)
		{
			m_GlobalPointSize = clamped;
			SetGlobalPointSize(m_GlobalPointSize);
			UpdateLabel();
		}
		return value;
	}

	// Sets the Font Asset on both Placeholder and Input child objects.
	public var fontAsset(get, set):TMP_FontAsset;
	function get_fontAsset():TMP_FontAsset return m_GlobalFontAsset;
	function set_fontAsset(value:TMP_FontAsset):TMP_FontAsset
	{
		if (m_GlobalFontAsset != value)
		{
			m_GlobalFontAsset = value;
			SetGlobalFontAsset(m_GlobalFontAsset);
			UpdateLabel();
		}
		return value;
	}
	@:serializeField
	private var m_GlobalFontAsset:TMP_FontAsset;

	// Determines if the whole text will be selected when focused.
	public var onFocusSelectAll(get, set):Bool;
	function get_onFocusSelectAll():Bool return m_OnFocusSelectAll;
	function set_onFocusSelectAll(value:Bool):Bool
	{
		m_OnFocusSelectAll = value;
		return value;
	}
	@:serializeField
	private var m_OnFocusSelectAll:Bool = true;
	private var m_isSelectAll:Bool;

	// Determines if the text and caret position as well as selection will be reset when the input field is deactivated.
	public var resetOnDeActivation(get, set):Bool;
	function get_resetOnDeActivation():Bool return m_ResetOnDeActivation;
	function set_resetOnDeActivation(value:Bool):Bool
	{
		m_ResetOnDeActivation = value;
		return value;
	}
	@:serializeField
	private var m_ResetOnDeActivation:Bool = true;
	private var m_SelectionStillActive:Bool = false;
	private var m_ReleaseSelection:Bool = false;

	private var m_PreviouslySelectedObject:GameObject;

	// Controls whether the original text is restored when pressing "ESC".
	public var restoreOriginalTextOnEscape(get, set):Bool;
	function get_restoreOriginalTextOnEscape():Bool return m_RestoreOriginalTextOnEscape;
	function set_restoreOriginalTextOnEscape(value:Bool):Bool
	{
		m_RestoreOriginalTextOnEscape = value;
		return value;
	}
	@:serializeField
	private var m_RestoreOriginalTextOnEscape:Bool = true;

	// Is Rich Text editing allowed?
	public var isRichTextEditingAllowed(get, set):Bool;
	function get_isRichTextEditingAllowed():Bool return m_isRichTextEditingAllowed;
	function set_isRichTextEditingAllowed(value:Bool):Bool
	{
		m_isRichTextEditingAllowed = value;
		return value;
	}
	@:serializeField
	private var m_isRichTextEditingAllowed:Bool = false;

	public var lineType(get, set):LineType;
	function get_lineType():LineType return m_LineType;
	function set_lineType(value:LineType):LineType
	{
		if (m_LineType != value)
		{
			m_LineType = value;
			SetToCustomIfContentTypeIsNot([ContentType.Standard, ContentType.Autocorrected]);
			SetTextComponentWrapMode();
		}
		return value;
	}

	// Limits the number of lines of text in the Input Field.
	public var lineLimit(get, set):Int;
	function get_lineLimit():Int return m_LineLimit;
	function set_lineLimit(value:Int):Int
	{
		if (m_LineType == LineType.SingleLine)
			m_LineLimit = 1;
		else if (m_LineLimit != value)
			m_LineLimit = value;

		return value;
	}
	@:serializeField
	private var m_LineLimit:Int = 0;

	// The TouchScreenKeyboard being used to edit the Input Field.
	public var keyboardType(get, set):Int;
	function get_keyboardType():Int return m_KeyboardType;
	function set_keyboardType(value:Int):Int
	{
		if (m_KeyboardType != value)
		{
			m_KeyboardType = value;
			SetToCustom();
		}
		return value;
	}

	// Sets the Input Validation to use a Custom Input Validation script.
	public var inputValidator(get, set):TMP_InputValidator;
	function get_inputValidator():TMP_InputValidator return m_InputValidator;
	function set_inputValidator(value:TMP_InputValidator):TMP_InputValidator
	{
		if (m_InputValidator != value)
		{
			m_InputValidator = value;
			SetToCustomCharValidation(CharacterValidation.CustomValidator);
		}
		return value;
	}
	@:serializeField
	private var m_InputValidator:TMP_InputValidator;

	public var readOnly(get, set):Bool;
	function get_readOnly():Bool return m_ReadOnly;
	function set_readOnly(value:Bool):Bool
	{
		m_ReadOnly = value;
		return value;
	}

	public var richText(get, set):Bool;
	function get_richText():Bool return m_RichText;
	function set_richText(value:Bool):Bool
	{
		m_RichText = value;
		SetTextComponentRichTextMode();
		return value;
	}

	// Derived property
	public var multiLine(get, never):Bool;
	function get_multiLine():Bool return m_LineType == LineType.MultiLineNewline || lineType == LineType.MultiLineSubmit;

	// Not shown in Inspector.
	public var asteriskChar(get, set):String;
	function get_asteriskChar():String return m_AsteriskChar;
	function set_asteriskChar(value:String):String
	{
		if (m_AsteriskChar != value)
		{
			m_AsteriskChar = value;
			UpdateLabel();
		}
		return value;
	}

	public var wasCanceled(get, never):Bool;
	function get_wasCanceled():Bool return m_WasCanceled;

	private function ClampStringPos(pos:Int):Int
	{
		if (pos < 0)
			return 0;
		else if (pos > text.length)
			return text.length;
		return pos;
	}

	private function ClampCaretPos(pos:Int):Int
	{
		if (pos < 0)
			return 0;
		else if (pos > m_TextComponent.textInfo.characterCount - 1)
			return m_TextComponent.textInfo.characterCount - 1;
		return pos;
	}

	// PORT-NOTE: C# 的 `ref int` 参数在 Haxe 中用「返回新值再赋值」代替。
	private var caretPositionInternal(get, set):Int;
	function get_caretPositionInternal():Int return m_CaretPosition + compositionLength;
	function set_caretPositionInternal(value:Int):Int
	{
		m_CaretPosition = ClampCaretPos(value);
		return value;
	}
	private var stringPositionInternal(get, set):Int;
	function get_stringPositionInternal():Int return m_StringPosition + compositionLength;
	function set_stringPositionInternal(value:Int):Int
	{
		m_StringPosition = ClampStringPos(value);
		return value;
	}
	private var caretSelectPositionInternal(get, set):Int;
	function get_caretSelectPositionInternal():Int return m_CaretSelectPosition + compositionLength;
	function set_caretSelectPositionInternal(value:Int):Int
	{
		m_CaretSelectPosition = ClampCaretPos(value);
		return value;
	}
	private var stringSelectPositionInternal(get, set):Int;
	function get_stringSelectPositionInternal():Int return m_StringSelectPosition + compositionLength;
	function set_stringSelectPositionInternal(value:Int):Int
	{
		m_StringSelectPosition = ClampStringPos(value);
		return value;
	}

	private var hasSelection(get, never):Bool;
	function get_hasSelection():Bool return stringPositionInternal != stringSelectPositionInternal;
	private var m_isSelected:Bool;
	private var m_IsStringPositionDirty:Bool;
	private var m_IsCaretPositionDirty:Bool;
	private var m_forceRectTransformAdjustment:Bool;

	// Get: Returns the focus position as thats the position that moves around even during selection.
	// Set: Set both the anchor and focus position such that a selection doesn't happen.
	public var caretPosition(get, set):Int;
	function get_caretPosition():Int return caretSelectPositionInternal;
	function set_caretPosition(value:Int):Int
	{
		selectionAnchorPosition = value;
		selectionFocusPosition = value;
		m_IsStringPositionDirty = true;
		return value;
	}

	public var selectionAnchorPosition(get, set):Int;
	function get_selectionAnchorPosition():Int return caretPositionInternal;
	function set_selectionAnchorPosition(value:Int):Int
	{
		if (compositionLength != 0)
			return value;

		caretPositionInternal = value;
		m_IsStringPositionDirty = true;
		return value;
	}

	public var selectionFocusPosition(get, set):Int;
	function get_selectionFocusPosition():Int return caretSelectPositionInternal;
	function set_selectionFocusPosition(value:Int):Int
	{
		if (compositionLength != 0)
			return value;

		caretSelectPositionInternal = value;
		m_IsStringPositionDirty = true;
		return value;
	}

	public var stringPosition(get, set):Int;
	function get_stringPosition():Int return stringSelectPositionInternal;
	function set_stringPosition(value:Int):Int
	{
		selectionStringAnchorPosition = value;
		selectionStringFocusPosition = value;
		m_IsCaretPositionDirty = true;
		return value;
	}

	// The fixed position of the selection in the raw string which may contains rich text.
	public var selectionStringAnchorPosition(get, set):Int;
	function get_selectionStringAnchorPosition():Int return stringPositionInternal;
	function set_selectionStringAnchorPosition(value:Int):Int
	{
		if (compositionLength != 0)
			return value;

		stringPositionInternal = value;
		m_IsCaretPositionDirty = true;
		return value;
	}

	// The variable position of the selection in the raw string which may contains rich text.
	public var selectionStringFocusPosition(get, set):Int;
	function get_selectionStringFocusPosition():Int return stringSelectPositionInternal;
	function set_selectionStringFocusPosition(value:Int):Int
	{
		if (compositionLength != 0)
			return value;

		stringSelectPositionInternal = value;
		m_IsCaretPositionDirty = true;
		return value;
	}

	// protected override
	public override function OnEnable():Void
	{
		super.OnEnable();

		if (m_Text == null)
			m_Text = "";

		// TODO-PORT: 原实现依赖 ILayoutController / LayoutGroup / CanvasRenderer / RectMask2D / TMPro_EventManager，
		// Haxe 兼容层未提供，这里仅保留 UpdateLabel。
		if (m_TextComponent != null)
		{
			UpdateLabel();
		}
	}
	// protected override
	public override function OnDisable():Void
	{
		DeactivateInputField();
		super.OnDisable();
	}

	private function SetCaretVisible():Void
	{
		if (!m_AllowInput)
			return;
		m_CaretVisible = true;
		m_BlinkStartTime = unity.Time.unscaledTime;
		SetCaretActive();
	}
	private function SetCaretActive():Void
	{
		if (!m_AllowInput)
			return;
		// TODO-PORT: C# 用协程闪烁光标（CaretBlink）；顶点渲染在兼容层中不存在，这里只保留可见状态。
		m_CaretVisible = true;
	}
	// protected
	public function OnFocus():Void
	{
		if (m_OnFocusSelectAll)
			SelectAll();
	}
	// protected
	public function SelectAll():Void
	{
		m_isSelectAll = true;
		stringPositionInternal = text.length;
		stringSelectPositionInternal = 0;
	}
	public function MoveTextEnd(shift:Bool):Void
	{
		if (m_isRichTextEditingAllowed)
		{
			var position = text.length;
			if (shift)
			{
				stringSelectPositionInternal = position;
			}
			else
			{
				stringPositionInternal = position;
				stringSelectPositionInternal = stringPositionInternal;
			}
		}
		else
		{
			var position = m_TextComponent.textInfo.characterCount - 1;
			if (shift)
			{
				caretSelectPositionInternal = position;
				stringSelectPositionInternal = GetStringIndexFromCaretPosition(position);
			}
			else
			{
				caretPositionInternal = caretSelectPositionInternal = position;
				stringSelectPositionInternal = stringPositionInternal = GetStringIndexFromCaretPosition(position);
			}
		}
		UpdateLabel();
	}
	public function MoveTextStart(shift:Bool):Void
	{
		if (m_isRichTextEditingAllowed)
		{
			var position = 0;
			if (shift)
			{
				stringSelectPositionInternal = position;
			}
			else
			{
				stringPositionInternal = position;
				stringSelectPositionInternal = stringPositionInternal;
			}
		}
		else
		{
			var position = 0;
			if (shift)
			{
				caretSelectPositionInternal = position;
				stringSelectPositionInternal = GetStringIndexFromCaretPosition(position);
			}
			else
			{
				caretPositionInternal = caretSelectPositionInternal = position;
				stringSelectPositionInternal = stringPositionInternal = GetStringIndexFromCaretPosition(position);
			}
		}
		UpdateLabel();
	}
	public function MoveToEndOfLine(shift:Bool, ctrl:Bool):Void
	{
		var currentLine = m_TextComponent.textInfo.characterInfo[caretPositionInternal].lineNumber;
		var characterIndex = ctrl == true ? m_TextComponent.textInfo.characterCount - 1 : m_TextComponent.textInfo.lineInfo[currentLine].lastCharacterIndex;
		var position = m_TextComponent.textInfo.characterInfo[characterIndex].index;
		if (shift)
		{
			stringSelectPositionInternal = position;
			caretSelectPositionInternal = characterIndex;
		}
		else
		{
			stringPositionInternal = position;
			stringSelectPositionInternal = stringPositionInternal;
			caretSelectPositionInternal = caretPositionInternal = characterIndex;
		}
		UpdateLabel();
	}
	public function MoveToStartOfLine(shift:Bool, ctrl:Bool):Void
	{
		var currentLine = m_TextComponent.textInfo.characterInfo[caretPositionInternal].lineNumber;
		var characterIndex = ctrl == true ? 0 : m_TextComponent.textInfo.lineInfo[currentLine].firstCharacterIndex;
		var position = 0;
		if (characterIndex > 0)
			position = m_TextComponent.textInfo.characterInfo[characterIndex - 1].index + m_TextComponent.textInfo.characterInfo[characterIndex - 1].stringLength;
		if (shift)
		{
			stringSelectPositionInternal = position;
			caretSelectPositionInternal = characterIndex;
		}
		else
		{
			stringPositionInternal = position;
			stringSelectPositionInternal = stringPositionInternal;
			caretSelectPositionInternal = caretPositionInternal = characterIndex;
		}
		UpdateLabel();
	}

	private function MayDrag(eventData:PointerEventData):Bool
	{
		return IsActive() &&
			IsInteractable() &&
			eventData.button == unity.eventsystems.InputButton.Left &&
			m_TextComponent != null &&
			(m_SoftKeyboard == null || shouldHideSoftKeyboard || shouldHideMobileInput);
	}
	public function OnBeginDrag(eventData:PointerEventData):Void
	{
		if (!MayDrag(eventData))
			return;
		m_UpdateDrag = true;
	}
	public function OnDrag(eventData:PointerEventData):Void
	{
		if (!MayDrag(eventData))
			return;
		// TODO-PORT: TMP_TextUtilities.GetCursorIndexFromPosition 的 out CaretPosition 参数与字符布局信息
		// 在兼容层中不可用，拖拽选区的精确光标定位未实现。
		m_DragPositionOutOfBounds = !unity.RectTransformUtility.RectangleContainsScreenPoint(textViewport, eventData.position, eventData.pressEventCamera);
		MarkGeometryAsDirty();
	}
	public function OnEndDrag(eventData:PointerEventData):Void
	{
		if (!MayDrag(eventData))
			return;
		m_UpdateDrag = false;
	}
	// override
	public override function OnPointerDown(eventData:PointerEventData):Void
	{
		if (!MayDrag(eventData))
			return;
		m_PointerDownClickStartTime = unity.Time.unscaledTime;
		super.OnPointerDown(eventData);
	}

	public function OnPointerClick(eventData:PointerEventData):Void
	{
		// PORT-NOTE: 原实现依赖 m_ProcessingEvent / Input.GetKey 判断 shift，兼容层中以 false 占位。
		// TODO-PORT: 单击时的光标定位与双击选词需要 TMP_TextUtilities.FindIntersectingWord。
		OnSelect(eventData);
	}

	public function OnUpdateSelected(eventData:BaseEventData):Void
	{
		if (!isFocused)
			return;

		var consumedEvent = false;
		// TODO-PORT: C# 从 Event.PopEvent 取出键盘事件并进入 KeyPressed 状态机；
		// Haxe 兼容层没有 Event/EventQueue，键盘编辑链路（KeyPressed/MoveLeft/...）暂未接入。
		if (consumedEvent)
			UpdateLabel();

		eventData.Use();
	}

	public function OnScroll(eventData:PointerEventData):Void
	{
		if (!m_AllowInput)
			return;

		var currentScrollPosition = m_ScrollPosition;
		if (m_ScrollSensitivity > 0)
		{
			var scrollDelta = eventData.scrollDelta.y;
			m_ScrollPosition += -1 * scrollDelta * m_ScrollSensitivity;
		}
		m_ScrollPosition = unity.Mathf.Clamp01(m_ScrollPosition);

		if (m_ScrollPosition != currentScrollPosition)
		{
			m_isLastKeyBackspace = false;
			MarkGeometryAsDirty();
		}
	}

	private function GetSelectedString():String
	{
		if (hasSelection)
		{
			return text.substring(stringPositionInternal, stringSelectPositionInternal);
		}
		return "";
	}

	private function FindNextWordBegin():Int
	{
		if (m_isRichTextEditingAllowed)
		{
			if (stringSelectPositionInternal < text.length)
			{
				var i = stringSelectPositionInternal + 1;
				while (i < text.length && text.charAt(i) != " " && text.charAt(i) != "." && text.charAt(i) != "," && text.charAt(i) != "\t" && text.charAt(i) != "\r" && text.charAt(i) != "\n")
				{
					++i;
				}
				return i;
			}
			return stringSelectPositionInternal;
		}
		// TODO-PORT: 富文本关闭时依赖 TMP_TextInfo.wordInfo 的单词边界，兼容层无布局信息，退化为原位置。
		return stringSelectPositionInternal;
	}

	private function MoveRight(shift:Bool, ctrl:Bool):Void
	{
		var isTextComponentUpdateRequired = false;
		var isScrollbarUpdateRequired = false;

		if (!hasSelection)
		{
			if (ctrl)
			{
				stringPositionInternal = FindNextWordBegin();
			}
			else
			{
				if (m_isRichTextEditingAllowed)
				{
					if (stringPositionInternal < text.length)
					{
						stringPositionInternal += 1;
					}
				}
			}

			if (shift)
			{
				caretSelectPositionInternal = caretPositionInternal;
			}
		}
		else
		{
			if (shift)
			{
				caretSelectPositionInternal = caretPositionInternal;
			}
			else
			{
				var pos = stringPositionInternal > stringSelectPositionInternal ? stringPositionInternal : stringSelectPositionInternal;
				caretPositionInternal = caretSelectPositionInternal = pos;
			}
		}

		// PORT-NOTE: 原实现里 isTextComponentUpdateRequired / isScrollbarUpdateRequired 仅用于跳过冗余更新，
		// 兼容层无对应状态，保留变量语义但不再使用。
		if (isTextComponentUpdateRequired || isScrollbarUpdateRequired)
		{
			// no-op
		}
	}

	private function FindPrevWordBegin():Int
	{
		if (m_isRichTextEditingAllowed)
		{
			if (stringSelectPositionInternal > 0)
			{
				var i = stringSelectPositionInternal - 2;
				while (i >= 0 && text.charAt(i) != " " && text.charAt(i) != "." && text.charAt(i) != "," && text.charAt(i) != "\t" && text.charAt(i) != "\r" && text.charAt(i) != "\n")
				{
					--i;
				}
				return i + 1;
			}
			return 0;
		}
		// TODO-PORT: 同 FindNextWordBegin，富文本关闭分支依赖 TMP_TextInfo.wordInfo。
		return stringSelectPositionInternal;
	}

	private function MoveLeft(shift:Bool, ctrl:Bool):Void
	{
		if (!hasSelection)
		{
			if (ctrl)
			{
				stringPositionInternal = FindPrevWordBegin();
			}
			else
			{
				if (m_isRichTextEditingAllowed)
				{
					if (stringPositionInternal > 0)
					{
						stringPositionInternal -= 1;
					}
				}
			}

			if (shift)
			{
				caretSelectPositionInternal = caretPositionInternal;
			}
		}
		else
		{
			if (shift)
			{
				caretPositionInternal = caretSelectPositionInternal;
			}
			else
			{
				var pos = stringPositionInternal < stringSelectPositionInternal ? stringPositionInternal : stringSelectPositionInternal;
				caretPositionInternal = caretSelectPositionInternal = pos;
			}
		}
	}

	private function MoveDown(shift:Bool):Void
	{
		MoveDownGoToLast(shift, false);
	}
	private function MoveDownGoToLast(shift:Bool, goToLastChar:Bool):Void
	{
		// TODO-PORT: 行间移动依赖 TMP_TextInfo.characterInfo/lineInfo 的布局信息，兼容层未实现。
		if (shift)
		{
			stringSelectPositionInternal = stringPositionInternal;
		}
		else
		{
			stringPositionInternal = stringSelectPositionInternal;
		}
	}
	private function MoveUp(shift:Bool):Void
	{
		MoveUpGoToFirst(shift, false);
	}
	private function MoveUpGoToFirst(shift:Bool, goToFirstChar:Bool):Void
	{
		// TODO-PORT: 同 MoveDown，行间移动依赖 TMP 布局信息。
		if (shift)
		{
			stringSelectPositionInternal = stringPositionInternal;
		}
		else
		{
			stringPositionInternal = stringSelectPositionInternal;
		}
	}
	private function MovePageUp(shift:Bool):Void
	{
		MovePageUpGoToFirst(shift, false);
	}
	private function MovePageUpGoToFirst(shift:Bool, goToFirstChar:Bool):Void
	{
		// TODO-PORT: 翻页移动依赖 TMP 布局信息与视口尺寸。
		MoveUpGoToFirst(shift, goToFirstChar);
	}
	private function MovePageDown(shift:Bool):Void
	{
		MovePageDownGoToLast(shift, false);
	}
	private function MovePageDownGoToLast(shift:Bool, goToLastChar:Bool):Void
	{
		// TODO-PORT: 翻页移动依赖 TMP 布局信息与视口尺寸。
		MoveDownGoToLast(shift, goToLastChar);
	}

	private function Delete():Void
	{
		// TODO-PORT: 富文本关闭时依赖 TMP 字符索引映射，兼容层仅实现 m_isRichTextEditingAllowed 分支。
		if (m_ReadOnly)
			return;

		var followingChar = text.length - 1;

		// Delete the selection
		if (hasSelection)
		{
			DeleteSelection();
		}
		else
		{
			// Delete the following char if not on the last character
			var pos = stringPositionInternal < stringSelectPositionInternal ? stringPositionInternal : stringSelectPositionInternal;
			if (pos < text.length)
			{
				m_Text = text.substring(0, pos) + text.substring(pos + 1);
				stringPositionInternal = stringSelectPositionInternal = pos;
			}
		}
		SendOnValueChangedAndUpdateLabel();
	}

	private function DeleteSelection():Void
	{
		var start = stringPositionInternal < stringSelectPositionInternal ? stringPositionInternal : stringSelectPositionInternal;
		var end = stringPositionInternal < stringSelectPositionInternal ? stringSelectPositionInternal : stringPositionInternal;
		m_Text = text.substring(0, start) + text.substring(end);
		stringPositionInternal = stringSelectPositionInternal = start;
	}

	private function DeleteKey():Void
	{
		// TODO-PORT: 同 Delete，富文本关闭分支未实现。
		if (m_ReadOnly)
			return;

		if (hasSelection)
		{
			DeleteSelection();
		}
		else
		{
			var pos = stringPositionInternal;
			if (pos < text.length)
			{
				m_Text = text.substring(0, pos) + text.substring(pos + 1);
			}
		}
		SendOnValueChangedAndUpdateLabel();
	}

	private function Backspace():Void
	{
		// TODO-PORT: 同 Delete，富文本关闭分支未实现。
		if (m_ReadOnly)
			return;

		if (hasSelection)
		{
			DeleteSelection();
		}
		else
		{
			var pos = stringPositionInternal;
			if (pos > 0)
			{
				m_Text = text.substring(0, pos - 1) + text.substring(pos);
				stringPositionInternal = stringSelectPositionInternal = pos - 1;
			}
		}
		SendOnValueChangedAndUpdateLabel();
	}

	// protected virtual
	public function Append(input:String):Void
	{
		if (m_ReadOnly)
			return;

		if (input == null || input.length == 0)
			return;

		if (m_Text != null && m_Text.length > 0 && m_Text.charAt(m_Text.length - 1) != "\n")
		{
			// no-op
		}
		var wasAdded = false;

		// Validate input
		for (i in 0...input.length)
		{
			var c = input.charAt(i);

			if (onValidateInput != null)
				c = onValidateInput(m_Text, m_Text.length, c);
			else if (characterValidation != CharacterValidation.None)
				c = Validate(m_Text, m_Text.length, c);

			// If the input is invalid, skip it
			if (c == null || c.length == 0)
				continue;

			// Append the character and update the label
			m_Text += c;
			wasAdded = true;
		}

		if (wasAdded)
			SendOnValueChangedAndUpdateLabel();
	}

	// protected virtual
	public function AppendChar(input:String):Void
	{
		if (m_ReadOnly)
			return;

		if (onValidateInput != null)
			input = onValidateInput(m_Text, m_Text.length, input);
		else if (characterValidation != CharacterValidation.None)
			input = Validate(m_Text, m_Text.length, input);

		// If the input is invalid, skip it
		if (input == null || input.length == 0)
			return;

		// Append the character and update the label
		m_Text += input;
		SendOnValueChangedAndUpdateLabel();
	}

	private function Insert(c:String):Void
	{
		// TODO-PORT: 依赖 TMP 字符索引映射，兼容层仅实现 m_isRichTextEditingAllowed 分支。
		if (m_ReadOnly)
			return;

		if (hasSelection)
		{
			DeleteSelection();
		}

		var pos = stringPositionInternal;
		m_Text = text.substring(0, pos) + c + text.substring(pos);
		stringPositionInternal = stringSelectPositionInternal = pos + 1;
		SendOnValueChangedAndUpdateLabel();
	}

	private function UpdateTouchKeyboardFromEditChanges():Void
	{
		// TODO-PORT: 兼容层没有软键盘实现。
	}

	private function SendOnValueChangedAndUpdateLabel():Void
	{
		SendOnValueChanged();
		UpdateLabel();
	}
	private function SendOnValueChanged():Void
	{
		if (m_OnValueChanged != null)
			m_OnValueChanged.Invoke(text);
	}
	// protected
	public function SendOnEndEdit():Void
	{
		if (m_OnEndEdit != null)
			m_OnEndEdit.Invoke(text);
	}
	// protected
	public function SendOnSubmit():Void
	{
		if (m_OnSubmit != null)
			m_OnSubmit.Invoke(text);
	}
	// protected
	public function SendOnFocus():Void
	{
		if (m_OnSelect != null)
			m_OnSelect.Invoke(text);
	}
	// protected
	public function SendOnFocusLost():Void
	{
		if (m_OnDeselect != null)
			m_OnDeselect.Invoke(text);
	}
	// protected
	public function SendOnTextSelection():Void
	{
		if (m_OnTextSelection != null)
			m_OnTextSelection.Invoke(text, stringPositionInternal, stringSelectPositionInternal);
	}
	// protected
	public function SendOnEndTextSelection():Void
	{
		if (m_OnEndTextSelection != null)
			m_OnEndTextSelection.Invoke(text, stringPositionInternal, stringSelectPositionInternal);
	}

	// protected
	public function UpdateLabel():Void
	{
		if (m_PreventCallback)
			return;

		m_PreventCallback = true;
		// PORT-NOTE: C# 在这里把 m_Text 逐字符按 characterValidation / characterLimit 重新拼装，
		// 并处理密码掩码、富文本与占位符显隐；兼容层把文本直接交给 TMP_Text。
		var fullText = m_Text;

		if (m_TextComponent != null)
		{
			m_TextComponent.text = fullText;
			// TODO-PORT: 占位符的显隐（m_Placeholder.enabled）与 TMP 的 SetVerticesDirty 未实现。
		}

		m_PreventCallback = false;
	}

	private function GetCaretPositionFromStringIndex(stringIndex:Int):Int
	{
		var count = m_TextComponent.textInfo.characterCount;
		for (i in 0...count)
		{
			if (m_TextComponent.textInfo.characterInfo[i].index >= stringIndex)
				return i;
		}
		return count;
	}

	private function GetStringIndexFromCaretPosition(caretPosition:Int):Int
	{
		return m_TextComponent.textInfo.characterInfo[caretPosition].index;
	}

	public function ForceLabelUpdate():Void
	{
		UpdateLabel();
	}

	private function MarkGeometryAsDirty():Void
	{
		// TODO-PORT: C# 调用 CanvasUpdateRegistry.RegisterCanvasElementForGraphicRebuild(this)，兼容层没有重建队列。
	}

	// PORT-NOTE: unity.ui.Selectable shim 已定义同名空实现，Haxe 要求子类显式 override。
	public override function Rebuild(update:unity.ui.CanvasUpdate):Void
	{
		if (update == unity.ui.CanvasUpdate.PreRender)
			UpdateGeometry();
	}
	public override function LayoutComplete():Void {}
	public override function GraphicUpdateComplete():Void {}

	private function UpdateGeometry():Void
	{
		// TODO-PORT: 原实现生成光标/选区网格并提交给 CanvasRenderer，兼容层无对应渲染管线。
	}

	// protected
	public function Validate(text:String, pos:Int, ch:String):String
	{
		switch (characterValidation)
		{
			case CharacterValidation.None:
				return ch;
			case CharacterValidation.Integer, CharacterValidation.Decimal:
				// These are very similar
				if (pos == 0 && ch == "-" && stringPositionInternal == 0)
					return ch;

				if (ch >= "0" && ch <= "9")
					return ch;

				if (characterValidation == CharacterValidation.Integer)
					return null;

				// These are the characters that are accepted when editing an integer or float.
				var accepted = "";
				if (stringPositionInternal == 0 || stringPositionInternal >= text.length - 1)
					accepted = "-";
				accepted += charDecimalSeparator();
				if (accepted.indexOf(ch) != -1)
				{
					// Only allow a decimal point if no one exists
					var decimalIndex = text.indexOf(charDecimalSeparator());
					var selectionPos = stringPositionInternal < stringSelectPositionInternal ? stringPositionInternal : stringSelectPositionInternal;
					var insertIndex = pos;
					if (insertIndex <= decimalIndex || decimalIndex == -1)
						return ch;
				}
				return null;
			case CharacterValidation.Alphanumeric:
				// All alphanumeric characters
				if (ch >= "A" && ch <= "Z") return ch;
				if (ch >= "a" && ch <= "z") return ch;
				if (ch >= "0" && ch <= "9") return ch;
				return null;
			case CharacterValidation.Name:
				// Allow single quote only, attach it to the previous character
				if (ch == "'")
					return ch;
				if (text.length > 0 && text.charAt(text.length - 1) == " ")
					return null;
				// Only allow characters if they are alphanumeric
				var isValid = (ch >= "A" && ch <= "Z") || (ch >= "a" && ch <= "z") || (ch >= "0" && ch <= "9");
				if (ch == " ")
					return ch;
				if (isValid)
					return ch;
				return null;
			case CharacterValidation.EmailAddress:
				// From StackOverflow about allowed characters
				if (ch == "@")
				{
					if (text.indexOf("@") == -1)
						return ch;
					return null;
				}
				if (ch == ".")
				{
					var atPosition = text.indexOf("@");
					if (atPosition != -1 && atPosition < pos)
						return ch;
					return null;
				}
				if (ch >= "A" && ch <= "Z") return ch;
				if (ch >= "a" && ch <= "z") return ch;
				if (ch >= "0" && ch <= "9") return ch;
				if (kEmailSpecialCharacters.indexOf(ch) != -1)
					return ch;
				return null;
			case CharacterValidation.Regex:
				// TODO-PORT: C# 用 System.Text.RegularExpressions 校验 m_RegexValue，Haxe 侧改用 EReg 后行为一致。
				if (m_RegexValue == null || m_RegexValue.length == 0)
					return ch;
				var regex = new EReg(m_RegexValue, "");
				if (regex.match(ch))
					return ch;
				return null;
			case CharacterValidation.CustomValidator:
				if (m_InputValidator != null)
				{
					return m_InputValidator.Validate(text, pos, ch);
				}
				return ch;
			default:
				return ch;
		}
	}

	// PORT-NOTE: C# 用 CultureInfo.CurrentCulture.NumberFormat.NumberDecimalSeparator；Haxe 固定为 "."。
	private inline function charDecimalSeparator():String return ".";

	// protected virtual
	public function IsValidChar(c:String):Bool
	{
		// Control keys
		if (c == "" || c.charCodeAt(0) == 127)
			return false;

		// Delete keys
		if (c == "\x08" || c == "\n" || c == "\r")
			return false;

		// Everything else
		return true;
	}

	public function ActivateInputField():Void
	{
		// PORT-NOTE: C# 会等待 LateUpdate 再激活（m_ShouldActivateNextUpdate），这里直接激活。
		if (!IsActive() || !IsInteractable() || m_ReadOnly)
			return;

		if (m_TextComponent != null)
		{
			m_TextComponent.ForceMeshUpdate();
		}

		ActivateInputFieldInternal();
	}

	private function ActivateInputFieldInternal():Void
	{
		if (unity.eventsystems.EventSystem.current == null)
			return;

		// TODO-PORT: 原实现会创建/激活软键盘（TouchScreenKeyboard）并处理 InPlaceEditing 分支，
		// 兼容层没有软键盘，仅保留焦点状态与文本备份。
		m_AllowInput = true;
		m_OriginalText = text;
		m_WasCanceled = false;
		m_HasDoneFocusTransition = false;
		OnFocus();
		SendOnFocus();
	}

	// override
	public override function OnSelect(eventData:BaseEventData):Void
	{
		if (IsInteractable() && !isFocused)
			m_ShouldActivateNextUpdate = true;
	}

	// PORT-NOTE: C# 的 OnControlClick / ReleaseSelection 为鼠标右键与内联编辑用。
	public function OnControlClick():Void {}
	public function ReleaseSelection():Void
	{
		m_ReleaseSelection = false;
		m_SelectionStillActive = false;
		MarkGeometryAsDirty();
	}

	public function DeactivateInputField(?clearSelection:Bool = false):Void
	{
		// Not activated, nothing to do!
		if (!m_AllowInput)
			return;

		// TODO-PORT: 软键盘销毁分支未实现。
		m_HasDoneFocusTransition = false;
		m_AllowInput = false;

		OnDeselect(null);
		if (clearSelection)
			ReleaseSelection();

		// In case we were in a state of restoring the original text, restore it
		if (m_WasCanceled && m_RestoreOriginalTextOnEscape)
			text = m_OriginalText;

		SendOnEndEdit();
		SendOnEndTextSelection();

		// If we have a vertical scrollbar and we are not focused, enable its navigation
		// TODO-PORT: 垂直滚动条与 TMP 网格清理未实现。
	}

	// override
	public override function OnDeselect(eventData:BaseEventData):Void
	{
		if (m_ResetOnDeActivation)
		{
			SendOnFocusLost();
			// TODO-PORT: 原实现在此处清理选择与光标状态并通知 EventSystem。
		}
	}

	public function OnSubmit(eventData:BaseEventData):Void
	{
		SendOnSubmit();
	}

	// PORT-NOTE: C# 的 protected 在 Haxe 中不存在（Haxe 没有 protected 修饰符），统一降级为 private。
	private function EnforceContentType():Void
	{
		switch (m_ContentType)
		{
			case ContentType.Standard:
				// Don't use the content type here, that will always toggle it!
				m_InputType = InputType.Standard;
				m_KeyboardType = 0;
				m_CharacterValidation = CharacterValidation.None;
			case ContentType.Autocorrected:
				// Don't use the content type here, that will always toggle it!
				m_InputType = InputType.AutoCorrect;
				m_KeyboardType = 0;
				m_CharacterValidation = CharacterValidation.None;
			case ContentType.IntegerNumber:
				m_LineType = LineType.SingleLine;
				m_InputType = InputType.Standard;
				m_KeyboardType = 4; // NumberPad
				m_CharacterValidation = CharacterValidation.Integer;
			case ContentType.DecimalNumber:
				m_LineType = LineType.SingleLine;
				m_InputType = InputType.Standard;
				m_KeyboardType = 5; // DecimalPad
				m_CharacterValidation = CharacterValidation.Decimal;
			case ContentType.Alphanumeric:
				m_LineType = LineType.SingleLine;
				m_InputType = InputType.Standard;
				m_KeyboardType = 1; // ASCIICapable
				m_CharacterValidation = CharacterValidation.Alphanumeric;
			case ContentType.Name:
				m_LineType = LineType.SingleLine;
				m_InputType = InputType.Standard;
				m_KeyboardType = 6; // Default
				m_CharacterValidation = CharacterValidation.Name;
			case ContentType.EmailAddress:
				m_LineType = LineType.SingleLine;
				m_InputType = InputType.Standard;
				m_KeyboardType = 7; // EmailAddress
				m_CharacterValidation = CharacterValidation.EmailAddress;
			case ContentType.Password:
				m_LineType = LineType.SingleLine;
				m_InputType = InputType.Password;
				m_KeyboardType = 8; // Default
				m_CharacterValidation = CharacterValidation.None;
			case ContentType.Pin:
				m_LineType = LineType.SingleLine;
				m_InputType = InputType.Password;
				m_KeyboardType = 8; // NumberPad
				m_CharacterValidation = CharacterValidation.Integer;
			// PORT-NOTE: C# switch 非穷尽（Custom 不在 C# 的 case 列表内，落到 switch 之外）；
			// Haxe 要求穷尽，补空 case。
			case ContentType.Custom:
		}
	}

	private function SetTextComponentWrapMode():Void
	{
		if (m_TextComponent == null)
			return;

		if (multiLine)
			m_TextComponent.enableWordWrapping = true;
		else
			m_TextComponent.enableWordWrapping = false;
	}

	private function SetTextComponentRichTextMode():Void
	{
		if (m_TextComponent == null)
			return;

		m_TextComponent.richText = m_RichText;
	}

	private function SetToCustomIfContentTypeIsNot(allowedContentTypes:Array<ContentType>):Void
	{
		if (m_ContentType == ContentType.Custom)
			return;

		for (i in 0...allowedContentTypes.length)
			if (m_ContentType == allowedContentTypes[i])
				return;

		m_ContentType = ContentType.Custom;
	}

	private function SetToCustom():Void
	{
		// Set to custom
		if (m_ContentType == ContentType.Custom)
			return;

		m_ContentType = ContentType.Custom;
	}
	private function SetToCustomCharValidation(characterValidation:CharacterValidation):Void
	{
		if (m_CharacterValidation == characterValidation)
			return;

		m_ContentType = ContentType.Custom;
		m_CharacterValidation = characterValidation;
	}

	// override
	public override function DoStateTransition(state:SelectionState, instant:Bool):Void
	{
		if (state == SelectionState.Normal && !isFocused)
			m_HasDoneFocusTransition = false;
		else if (state == SelectionState.Selected && m_HasDoneFocusTransition)
			return;

		// TODO-PORT: C# 在这里触发动画过渡（Selectable.DoStateTransition 的图形/动画分支）。
		super.DoStateTransition(state, instant);
	}

	public function CalculateLayoutInputHorizontal():Void {}
	public function CalculateLayoutInputVertical():Void {}

	public var minWidth(get, never):Float;
	function get_minWidth():Float return 0;
	public var preferredWidth(get, never):Float;
	function get_preferredWidth():Float
	{
		if (m_TextComponent != null)
			return m_TextComponent.preferredWidth;
		return -1;
	}
	public var flexibleWidth(get, never):Float;
	function get_flexibleWidth():Float return -1;
	public var minHeight(get, never):Float;
	function get_minHeight():Float return 0;
	public var preferredHeight(get, never):Float;
	function get_preferredHeight():Float
	{
		if (m_TextComponent != null)
			return m_TextComponent.preferredHeight;

		return -1;
	}
	public var flexibleHeight(get, never):Float;
	function get_flexibleHeight():Float return -1;
	public var layoutPriority(get, never):Int;
	function get_layoutPriority():Int return 1;

	public function SetGlobalPointSize(value:Float):Void
	{
		// PORT-NOTE: C# 同时设置 Placeholder（TMP_Text）与 m_TextComponent 的字号。
		if (m_Placeholder != null && Std.isOfType(m_Placeholder, TMP_Text))
		{
			var placeholderText:TMP_Text = cast m_Placeholder;
			placeholderText.fontSize = value;
		}

		if (m_TextComponent != null)
			m_TextComponent.fontSize = value;
	}

	public function SetGlobalFontAsset(value:TMP_FontAsset):Void
	{
		if (m_Placeholder != null && Std.isOfType(m_Placeholder, TMP_Text))
		{
			var placeholderText:TMP_Text = cast m_Placeholder;
			placeholderText.font = value;
		}

		if (m_TextComponent != null)
			m_TextComponent.font = value;
	}

	// PORT-NOTE: C# 的 SetPropertyUtility.SetColor(ref Color, Color) 用 Color.Equals 比较；
	// unity.Color 兼容层没有 Equals，这里按分量比较。
	private inline function colorEquals(a:Color, b:Color):Bool
	{
		return a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
	}

	// PORT-NOTE: C# 的 protected TouchScreenKeyboard m_SoftKeyboard 在兼容层中恒为 null。
	private var m_SoftKeyboard:Dynamic = null;
}

// C# 中为 DebugConsoleInputField 的内嵌枚举 ContentType。
enum abstract ContentType(Int)
{
	var Standard = 0;
	var Autocorrected = 1;
	var IntegerNumber = 2;
	var DecimalNumber = 3;
	var Alphanumeric = 4;
	var Name = 5;
	var EmailAddress = 6;
	var Password = 7;
	var Pin = 8;
	var Custom = 9;
}

// C# 中为 DebugConsoleInputField 的内嵌枚举 InputType。
enum abstract InputType(Int)
{
	var Standard = 0;
	var AutoCorrect = 1;
	var Password = 2;
}

// C# 中为 DebugConsoleInputField 的内嵌枚举 CharacterValidation。
enum abstract CharacterValidation(Int)
{
	var None = 0;
	var Digit = 1;
	var Integer = 2;
	var Decimal = 3;
	var Alphanumeric = 4;
	var Name = 5;
	var Regex = 6;
	var EmailAddress = 7;
	var CustomValidator = 8;
}

// C# 中为 DebugConsoleInputField 的内嵌枚举 LineType。
enum abstract LineType(Int)
{
	var SingleLine = 0;
	var MultiLineSubmit = 1;
	var MultiLineNewline = 2;
}

// C# 中为 DebugConsoleInputField 的内嵌枚举 EditState。
enum EditState
{
	Continue;
	Finish;
}

// C# 中为 DebugConsoleInputField.OnValidateInput 委托。
typedef OnValidateInput = String->Int->String->String;

// C# 中为 DebugConsoleInputField.SubmitEvent（UnityEvent<string>）。
class SubmitEvent extends UnityEvent1<String>
{
	public function new()
	{
		super();
	}
}

// C# 中为 DebugConsoleInputField.OnChangeEvent（UnityEvent<string>）。
class OnChangeEvent extends UnityEvent1<String>
{
	public function new()
	{
		super();
	}
}

// C# 中为 DebugConsoleInputField.SelectionEvent（UnityEvent<string>）。
class SelectionEvent extends UnityEvent1<String>
{
	public function new()
	{
		super();
	}
}

// C# 中为 DebugConsoleInputField.TextSelectionEvent（UnityEvent<string, int, int>）。
class TextSelectionEvent extends unity.events.UnityEventBase
{
	public var listeners:Array<String->Int->Int->Void> = [];

	public function new()
	{
		super();
	}
	public function AddListener(call:String->Int->Int->Void):Void
	{
		if (call != null) listeners.push(call);
	}
	public function RemoveListener(call:String->Int->Int->Void):Void
	{
		listeners.remove(call);
	}
	override public function RemoveAllListeners():Void
	{
		listeners = [];
	}
	public function Invoke(arg0:String, arg1:Int, arg2:Int):Void
	{
		for (l in listeners.copy()) l(arg0, arg1, arg2);
	}
}

// C# 中为 DebugConsoleInputField.TouchScreenKeyboardEvent（UnityEvent<TouchScreenKeyboard.Status>）。
class TouchScreenKeyboardEvent extends UnityEvent1<Int>
{
	public function new()
	{
		super();
	}
}
