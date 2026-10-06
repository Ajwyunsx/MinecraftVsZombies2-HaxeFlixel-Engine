#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""MVZ2 Unity -> HaxeFlixel 移植：关卡/UI prefab 与场景序列化数据转换器（工作包 ②）

## 为什么需要这个脚本

`tools_build/build_models.py` 只转换了**模型** prefab（Addressables 标签 `Model`）。
关卡/UI 侧的组件（`GridController.size`、`LevelUIPreset.hintArrowOffset*`、`LevelCamera.cameraAnchor`
等）同样靠 prefab 注入 `[SerializeField]` 字段，但移植层没有任何数据来源 —— 字段停在零值，
`GridController.TransformWorld2ColliderPosition` 里的 `slope = BevelHeight / size.x` 直接除零。

Unity 侧的对应关系（逐字段查证，见 tools_build/scene_pipeline_findings.md）：

  Assets/GameContent/Scenes/Main.unity   = MainGame.prefab 的一个 PrefabInstance（+2 个根上新增组件）
  Assets/GameContent/Scenes/Level.unity  = Assets/Prefabs/Level/Level.prefab 的一个 PrefabInstance
  Assets/Prefabs/Level/Level.prefab      = 关卡场景的全部 UI/相机/网格层级（含 Lane/Grid 等嵌套 prefab）

**场景文件本身几乎没有数据**（只有根节点的 `m_Name`/`m_IsActive` 覆盖与 `m_AddedComponents`），
所以本脚本把**场景与 prefab 一视同仁**地按同一套合并规则导出成节点表；运行期按节点表重建
GameObject 层级即可等价于 Unity 的场景反序列化。

## 与 build_models.py 的关系

* YAML 解析、嵌套 PrefabInstance 合并、变体覆盖、删除项、悬空引用回退等逻辑**完全复用**
  `build_models.py`（直接 import，不复制实现），保证两个转换器的语义一致。
* 输出格式与 `model_prefabs/**` 完全一致（`mvz2.models.ModelPrefabData` 的编码约定），
  因此运行期可以复用同一套解码器 `ModelPrefabContext` / 字段写入 `ModelPrefabFieldApplier`。
* 本脚本额外做的是**组件投影**：Unity 内置 UI/2D/相机等组件的字段名是 `m_*`（Unity YAML 的
  序列化名），而移植层 shim 用的是 Unity C# API 的属性名（`sprite`/`color`/`text`…）。
  这里为每个已知组件类型给出显式字段映射，未映射的字段记入清单的 `unmappedFields` 统计
  （不静默丢弃，便于后续补映射）。

## 输出

  <out>/scene_manifest.json                索引：场景条目 + prefab 条目（key -> 分文件路径）
  <out>/scene_prefabs/scenes/<name>.json   每个场景一棵节点树（含 prefab 实例与根节点覆盖）
  <out>/scene_prefabs/<path>.json          每个 prefab 一棵节点树

key 的取值：场景用 Unity 场景名（`Main` / `Level`）；prefab 用相对 `Assets/` 的路径去掉扩展名
（如 `Prefabs/Level/UI/UIPreset`），运行期 `ScenePrefabLoader` 按 key 取。

用法（在仓库根目录执行）：
    python HaxePort/tools_build/build_scene.py                 # 全量转换
    python HaxePort/tools_build/build_scene.py --report        # 只打印统计，不写文件
    python HaxePort/tools_build/build_scene.py --scenes-only   # 只转两个场景
    python HaxePort/tools_build/build_scene.py --only Prefabs/Level/Level
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from collections import Counter, OrderedDict

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

import build_models as bm  # noqa: E402  （复用 Unity YAML 解析 / prefab 合并 / 节点图构建）

# PORT-NOTE: build_models.build_node_graph 内部**按名字**调用 project_component（模块全局查找），
# 因此 _build_node_graph 用 monkey-patch 替换它来注入本脚本的组件投影。这里先存下原始函数，
# 兜底分支只能调它，调 bm.project_component 会在 patch 生效期间死循环。
_ORIGINAL_PROJECT_COMPONENT = bm.project_component

DEFAULT_PROJECT_ROOT = bm.DEFAULT_PROJECT_ROOT
DEFAULT_OUT_DIR = bm.DEFAULT_OUT_DIR

# 分文件目录（相对 <out>）。刻意不叫 scenes：assets 里已有 Unity 的 Scenes 镜像目录，
# Windows 不区分大小写会写串（与 build_models.py 的 model_prefabs 同一个理由）。
PREFAB_OUT_DIR_NAME = "scene_prefabs"

# 要转换的场景（Unity 场景名 -> 工程内路径）。与 PORTING.md / InitState.hx 的场景名一致。
SCENES = OrderedDict([
    ("Main", "Assets/GameContent/Scenes/Main.unity"),
    ("Level", "Assets/GameContent/Scenes/Level.unity"),
])

# prefab 扫描根（相对工程根）。Assets/Prefabs 下是全部关卡/UI/管理器 prefab；
# GameContent/Assets 下的模型 prefab 由 build_models.py 负责，这里不重复。
PREFAB_ROOTS = ["Assets/Prefabs"]

# --------------------------------------------------------------------------------------
# Unity 内置（非工程内 .cs）MonoBehaviour 的脚本 guid -> Unity 类型全名
# --------------------------------------------------------------------------------------
#
# PORT-NOTE: 这些组件来自 Unity 包（com.unity.ugui / com.unity.textmeshpro），工程里没有对应的
# `.cs`/`.cs.meta`，因此 build_models.UnityProject.script_index 里查不到它们；导出数据里
# `script` 会为空、运行期无法解析组件类。这里用**固定的包内 guid**（Unity 包的 guid 是全局常量，
# 不随工程变化）补上类型名，字段名再经 UI_COMPONENT_FIELDS 映射到 Unity C# API 的属性名。
#
# 这些 guid 由「组件文档的字段集合」反查确认（tools_build/scene_pipeline_findings.md 有对照表）：
# 例如 fe87c0e1… 同时带 m_Sprite/m_FillAmount/m_Type，只有 UnityEngine.UI.Image 符合。
UNITY_PACKAGE_SCRIPTS = {
    # ---- com.unity.ugui：UnityEngine.UI ----
    "fe87c0e1cc204ed48ad3b37840f39efc": "UnityEngine.UI.Image",
    "1344c3c82d62a2a41a3576d8abb8e3ea": "UnityEngine.UI.RawImage",
    "4e29b1a8efbd4b44bb3f3716e73f07ff": "UnityEngine.UI.Button",
    "9085046f02f69544eb97fd06b6048fe2": "UnityEngine.UI.Toggle",
    "2fafe2cfe61f6974895a912c3755e8f1": "UnityEngine.UI.ToggleGroup",
    "67db9e8f0e2ae9c40bc1e2b64352a6b4": "UnityEngine.UI.Slider",
    "2a4db7a114972834c8e4117be1d82ba3": "UnityEngine.UI.Scrollbar",
    "1aa08ab6e0800fa44ae55d278d1423e3": "UnityEngine.UI.ScrollRect",
    "7b743370ac3e4ec2a1668f5455a8ef8a": "TMPro.TMP_Dropdown",
    "2da0c512f12947e489f739169773d7ca": "TMPro.TMP_InputField",
    "e19747de3f5aca642ab2be37e372fb86": "UnityEngine.UI.Shadow",
    "3312d7739989d2b4e91e6319e9a96d76": "UnityEngine.UI.Outline",
    "31a19414c41e5ae4aae2af33fee712f6": "UnityEngine.UI.Mask",
    "306cc8c2b49d7114eaa3623786fc2126": "UnityEngine.UI.LayoutElement",
    "59f8146938fff824cb5fd77236b75775": "UnityEngine.UI.VerticalLayoutGroup",
    "30649d3a9faa99c48a7b1166b86bf2a0": "UnityEngine.UI.HorizontalLayoutGroup",
    "8a8695521f0d02e499659fee002a26c2": "UnityEngine.UI.GridLayoutGroup",
    "3245ec927659c4140ac4f8d17403cc18": "UnityEngine.UI.ContentSizeFitter",
    "86710e43de46f6f4bac7c8e50813a599": "UnityEngine.UI.AspectRatioFitter",
    "0cd44c1031e13a943bb63640046fad76": "UnityEngine.UI.CanvasScaler",
    "dc42784cf147c0c48a680349fa168899": "UnityEngine.UI.GraphicRaycaster",
    "76c392e42b5098c458856cdf6ecaaaa1": "UnityEngine.EventSystems.EventSystem",
    "4f231c4fb786f3946a6b90b886c48677": "UnityEngine.EventSystems.StandaloneInputModule",
    "56666c5a40171f54783dd416a44f42bf": "UnityEngine.EventSystems.PhysicsRaycaster",
    # ---- com.unity.textmeshpro ----
    "f4688fdb7df04437aeb418b961361dc5": "TMPro.TextMeshProUGUI",
    "9541d86e2fd84c1d9990edf0852d74ab": "TMPro.TextMeshPro",
    # 证据：Prefabs/UI/Widgets/InputField.prefab 的 m_TextComponent 指向 TextMeshProUGUI
    # （guid f4688fdb…）且带 m_GlobalFontAsset（TMP 专有字段）；ugui 的 InputField.m_TextComponent
    # 必须是 UnityEngine.UI.Text，所以这是 TMPro.TMP_InputField。Dropdown 同理
    # （Prefabs/UI/Widgets/Dropdown.prefab 的 m_CaptionText/m_ItemText 都是 TMP）。
    "2da0c512f12947e489f739169773d7ca": "TMPro.TMP_InputField",
    "7b743370ac3e4ec2a1668f5455a8ef8a": "TMPro.TMP_Dropdown",
}

# 组件类型 -> (Unity YAML 字段名, 移植层 shim 字段名) 列表。
# 未列出的类型走 build_models.project_component 的默认投影（保留原始字段名）。
UI_COMPONENT_FIELDS = {
    "UnityEngine.UI.Image": [
        ("m_Sprite", "sprite"), ("m_Color", "color"), ("m_Type", "type"),
        ("m_PreserveAspect", "preserveAspect"), ("m_FillCenter", "fillCenter"),
        ("m_FillMethod", "fillMethod"), ("m_FillAmount", "fillAmount"),
        ("m_FillClockwise", "fillClockwise"), ("m_FillOrigin", "fillOrigin"),
        ("m_UseSpriteMesh", "useSpriteMesh"),
        ("m_PixelsPerUnitMultiplier", "pixelsPerUnitMultiplier"),
        ("m_RaycastTarget", "raycastTarget"), ("m_RaycastPadding", "raycastPadding"),
        ("m_Maskable", "maskable"), ("m_Material", "material"),
        ("m_OnCullStateChanged", "onCullStateChanged"),
        ("m_Enabled", "enabled"),
    ],
    "UnityEngine.UI.RawImage": [
        ("m_Texture", "texture"), ("m_Color", "color"), ("m_UVRect", "uvRect"),
        ("m_RaycastTarget", "raycastTarget"), ("m_RaycastPadding", "raycastPadding"),
        ("m_Maskable", "maskable"),
        ("m_Material", "material"), ("m_Enabled", "enabled"),
    ],
    "UnityEngine.UI.Selectable": [
        ("m_Interactable", "interactable"), ("m_TargetGraphic", "targetGraphic"),
        ("m_Transition", "transition"), ("m_Colors", "colors"),
        ("m_SpriteState", "spriteState"), ("m_Navigation", "navigation"),
        ("m_AnimationTriggers", "animationTriggers"), ("m_Enabled", "enabled"),
    ],
    "UnityEngine.UI.Button": [
        ("m_Interactable", "interactable"), ("m_TargetGraphic", "targetGraphic"),
        ("m_Transition", "transition"), ("m_Colors", "colors"),
        ("m_SpriteState", "spriteState"), ("m_Navigation", "navigation"),
        ("m_AnimationTriggers", "animationTriggers"), ("m_Enabled", "enabled"),
    ],
    "UnityEngine.UI.Toggle": [
        ("m_IsOn", "isOn"), ("m_Interactable", "interactable"),
        ("m_TargetGraphic", "targetGraphic"), ("m_Transition", "transition"),
        ("m_Colors", "colors"), ("m_SpriteState", "spriteState"),
        ("m_Navigation", "navigation"), ("m_AnimationTriggers", "animationTriggers"),
        ("graphic", "graphic"), ("toggleTransition", "toggleTransition"),
        ("m_Group", "group"), ("m_Enabled", "enabled"),
        # PORT-NOTE: 事件字段名与 shim 一致，但**不导出**（见文件头部「事件字段」说明）。
    ],
    "UnityEngine.UI.ToggleGroup": [("m_AllowSwitchOff", "allowSwitchOff")],
    "UnityEngine.UI.Slider": [
        ("m_Value", "value"), ("m_MinValue", "minValue"), ("m_MaxValue", "maxValue"),
        ("m_WholeNumbers", "wholeNumbers"), ("m_FillRect", "fillRect"),
        ("m_HandleRect", "handleRect"), ("m_Direction", "direction"),
        ("m_Interactable", "interactable"), ("m_TargetGraphic", "targetGraphic"),
        ("m_Transition", "transition"), ("m_Colors", "colors"),
        ("m_Navigation", "navigation"), ("m_Enabled", "enabled"),
    ],
    "UnityEngine.UI.Scrollbar": [
        ("m_Value", "value"), ("m_Size", "size"), ("m_NumberOfSteps", "numberOfSteps"),
        ("m_HandleRect", "handleRect"), ("m_Direction", "direction"),
        ("m_Interactable", "interactable"), ("m_TargetGraphic", "targetGraphic"),
        ("m_Transition", "transition"), ("m_Colors", "colors"),
        ("m_Navigation", "navigation"), ("m_Enabled", "enabled"),
    ],
    "UnityEngine.UI.ScrollRect": [
        ("m_Content", "content"), ("m_Viewport", "viewport"),
        ("m_Horizontal", "horizontal"), ("m_Vertical", "vertical"),
        ("m_MovementType", "movementType"), ("m_Elasticity", "elasticity"),
        ("m_Inertia", "inertia"), ("m_DecelerationRate", "decelerationRate"),
        ("m_ScrollSensitivity", "scrollSensitivity"),
        ("m_HorizontalScrollbar", "horizontalScrollbar"),
        ("m_VerticalScrollbar", "verticalScrollbar"),
        ("m_HorizontalScrollbarVisibility", "horizontalScrollbarVisibility"),
        ("m_VerticalScrollbarVisibility", "verticalScrollbarVisibility"),
        ("m_HorizontalScrollbarSpacing", "horizontalScrollbarSpacing"),
        ("m_VerticalScrollbarSpacing", "verticalScrollbarSpacing"),
        ("m_Enabled", "enabled"),
    ],
    "TMPro.TMP_Dropdown": [
        ("m_Template", "template"), ("m_CaptionText", "captionText"),
        ("m_CaptionImage", "captionImage"), ("m_ItemText", "itemText"),
        ("m_ItemImage", "itemImage"), ("m_Value", "value"),
        ("m_Options", "options"), ("m_AlphaFadeSpeed", "alphaFadeSpeed"),
        # TODO-PORT: TMP_Dropdown 的 m_Placeholder 在 unity.tmpro.TMP_Dropdown shim 上没有对应
        # 字段（shim 只有 template/captionText/captionImage/itemText/itemImage），保持未映射。
        ("m_Interactable", "interactable"), ("m_TargetGraphic", "targetGraphic"),
        ("m_Transition", "transition"), ("m_Colors", "colors"),
        ("m_Navigation", "navigation"), ("m_Enabled", "enabled"),
    ],
    "TMPro.TMP_InputField": [
        ("m_Text", "text"), ("m_ContentType", "contentType"),
        ("m_LineType", "lineType"), ("m_InputType", "inputType"),
        ("m_CharacterLimit", "characterLimit"), ("m_CharacterValidation", "characterValidation"),
        ("m_KeyboardType", "keyboardType"), ("m_ReadOnly", "readOnly"),
        ("m_RichText", "richText"), ("m_CaretBlinkRate", "caretBlinkRate"),
        ("m_CaretWidth", "caretWidth"), ("m_CaretColor", "caretColor"),
        ("m_CustomCaretColor", "customCaretColor"), ("m_SelectionColor", "selectionColor"),
        ("m_AsteriskChar", "asteriskChar"), ("m_Placeholder", "placeholder"),
        ("m_TextComponent", "textComponent"), ("m_GlobalFontAsset", "globalFontAsset"),
        ("m_GlobalPointSize", "globalPointSize"), ("m_ScrollSensitivity", "scrollSensitivity"),
        ("m_Interactable", "interactable"), ("m_TargetGraphic", "targetGraphic"),
        ("m_Transition", "transition"), ("m_Colors", "colors"),
        ("m_Navigation", "navigation"), ("m_Enabled", "enabled"),
    ],
    "UnityEngine.UI.Shadow": [
        ("m_EffectColor", "effectColor"), ("m_EffectDistance", "effectDistance"),
        ("m_UseGraphicAlpha", "useGraphicAlpha"),
    ],
    # TODO-PORT: Outline 的 m_Softness 在 unity.ui.Shadow shim 上没有对应字段（只保留
    # effectColor / effectDistance / useGraphicAlpha），保持未映射。
    "UnityEngine.UI.Outline": [("m_EffectColor", "effectColor"),
                               ("m_EffectDistance", "effectDistance"),
                               ("m_UseGraphicAlpha", "useGraphicAlpha")],
    "UnityEngine.UI.Mask": [("m_ShowMaskGraphic", "showMaskGraphic")],
    "UnityEngine.UI.LayoutElement": [
        ("m_IgnoreLayout", "ignoreLayout"), ("m_MinWidth", "minWidth"),
        ("m_MinHeight", "minHeight"), ("m_PreferredWidth", "preferredWidth"),
        ("m_PreferredHeight", "preferredHeight"), ("m_FlexibleWidth", "flexibleWidth"),
        ("m_FlexibleHeight", "flexibleHeight"), ("m_LayoutPriority", "layoutPriority"),
    ],
    "UnityEngine.UI.VerticalLayoutGroup": [
        ("m_Padding", "padding"), ("m_ChildAlignment", "childAlignment"),
        ("m_Spacing", "spacing"),
        ("m_ChildForceExpandWidth", "childForceExpandWidth"),
        ("m_ChildForceExpandHeight", "childForceExpandHeight"),
        ("m_ChildControlWidth", "childControlWidth"),
        ("m_ChildControlHeight", "childControlHeight"),
        ("m_ChildScaleWidth", "childScaleWidth"),
        ("m_ChildScaleHeight", "childScaleHeight"),
        ("m_ReverseArrangement", "reverseArrangement"),
    ],
    "UnityEngine.UI.HorizontalLayoutGroup": [
        ("m_Padding", "padding"), ("m_ChildAlignment", "childAlignment"),
        ("m_Spacing", "spacing"),
        ("m_ChildForceExpandWidth", "childForceExpandWidth"),
        ("m_ChildForceExpandHeight", "childForceExpandHeight"),
        ("m_ChildControlWidth", "childControlWidth"),
        ("m_ChildControlHeight", "childControlHeight"),
        ("m_ChildScaleWidth", "childScaleWidth"),
        ("m_ChildScaleHeight", "childScaleHeight"),
        ("m_ReverseArrangement", "reverseArrangement"),
    ],
    "UnityEngine.UI.GridLayoutGroup": [
        ("m_Padding", "padding"), ("m_ChildAlignment", "childAlignment"),
        ("m_CellSize", "cellSize"), ("m_Spacing", "spacing"),
        ("m_StartCorner", "startCorner"), ("m_StartAxis", "startAxis"),
        ("m_Constraint", "constraint"), ("m_ConstraintCount", "constraintCount"),
    ],
    "UnityEngine.UI.ContentSizeFitter": [
        ("m_HorizontalFit", "horizontalFit"), ("m_VerticalFit", "verticalFit"),
    ],
    "UnityEngine.UI.AspectRatioFitter": [
        ("m_AspectMode", "aspectMode"), ("m_AspectRatio", "aspectRatio"),
    ],
    "UnityEngine.UI.CanvasScaler": [
        ("m_UiScaleMode", "uiScaleMode"), ("m_ReferenceResolution", "referenceResolution"),
        ("m_ScaleFactor", "scaleFactor"), ("m_ScreenMatchMode", "screenMatchMode"),
        ("m_MatchWidthOrHeight", "matchWidthOrHeight"),
        ("m_ReferencePixelsPerUnit", "referencePixelsPerUnit"),
        ("m_PhysicalUnit", "physicalUnit"), ("m_FallbackScreenDPI", "fallbackScreenDPI"),
        ("m_DefaultSpriteDPI", "defaultSpriteDPI"),
        ("m_DynamicPixelsPerUnit", "dynamicPixelsPerUnit"),
    ],
    "UnityEngine.UI.GraphicRaycaster": [
        ("m_IgnoreReversedGraphics", "ignoreReversedGraphics"),
        ("m_BlockingObjects", "blockingObjects"), ("m_BlockingMask", "blockingMask"),
        ("m_Enabled", "enabled"),
    ],
    "UnityEngine.EventSystems.EventSystem": [
        ("m_FirstSelected", "firstSelectedGameObject"),
        ("m_sendNavigationEvents", "sendNavigationEvents"),
        ("m_DragThreshold", "pixelDragThreshold"), ("m_Enabled", "enabled"),
    ],
    "UnityEngine.EventSystems.StandaloneInputModule": [
        ("m_HorizontalAxis", "horizontalAxis"), ("m_VerticalAxis", "verticalAxis"),
        ("m_SubmitButton", "submitButton"), ("m_CancelButton", "cancelButton"),
        ("m_InputActionsPerSecond", "inputActionsPerSecond"),
        ("m_RepeatDelay", "repeatDelay"),
        ("m_ForceModuleActive", "forceModuleActive"),
        ("m_SendPointerHoverToParent", "sendPointerHoverToParent"),
        ("m_Enabled", "enabled"),
    ],
    "UnityEngine.EventSystems.PhysicsRaycaster": [
        ("m_EventMask", "eventMask"), ("m_MaxRayIntersections", "maxRayIntersections"),
        ("m_Enabled", "enabled"),
    ],
    "TMPro.TextMeshProUGUI": [
        ("m_text", "text"), ("m_fontAsset", "font"), ("m_fontSize", "fontSize"),
        ("m_fontSizeBase", "fontSize"), ("m_fontSizeMin", "fontSizeMin"),
        ("m_fontSizeMax", "fontSizeMax"), ("m_enableAutoSizing", "enableAutoSizing"),
        ("m_fontStyle", "fontStyle"), ("m_textAlignment", "alignment"),
        ("m_fontColor", "color"), ("m_Color", "color"),
        ("m_HorizontalAlignment", "horizontalAlignment"),
        ("m_VerticalAlignment", "verticalAlignment"),
        ("m_RaycastTarget", "raycastTarget"), ("m_RaycastPadding", "raycastPadding"),
        ("m_Maskable", "maskable"),
        ("m_characterSpacing", "characterSpacing"), ("m_wordSpacing", "wordSpacing"),
        ("m_lineSpacing", "lineSpacing"), ("m_paragraphSpacing", "paragraphSpacing"),
        ("m_enableWordWrapping", "enableWordWrapping"), ("m_isRichText", "richText"),
        ("m_overflowMode", "overflowMode"), ("m_margin", "margin"),
        ("m_parseCtrlCharacters", "parseCtrlCharacters"),
        ("m_isRightToLeft", "isRightToLeftText"),
        ("m_raycastTarget", "raycastTarget"), ("m_maskable", "maskable"),
        ("m_Material", "fontSharedMaterial"), ("m_sharedMaterial", "fontSharedMaterial"),
        ("m_fontMaterials", "fontMaterials"),
        ("m_fontSharedMaterials", "fontSharedMaterials"),
        ("m_Enabled", "enabled"),
    ],
    "TMPro.TextMeshPro": [
        ("m_text", "text"), ("m_fontAsset", "font"), ("m_fontSize", "fontSize"),
        ("m_fontSizeBase", "fontSize"), ("m_fontSizeMin", "fontSizeMin"),
        ("m_fontSizeMax", "fontSizeMax"), ("m_enableAutoSizing", "enableAutoSizing"),
        ("m_fontStyle", "fontStyle"), ("m_textAlignment", "alignment"),
        ("m_fontColor", "color"), ("m_Color", "color"),
        ("m_HorizontalAlignment", "horizontalAlignment"),
        ("m_VerticalAlignment", "verticalAlignment"),
        ("m_RaycastTarget", "raycastTarget"), ("m_RaycastPadding", "raycastPadding"),
        ("m_Maskable", "maskable"), ("m_isRightToLeft", "isRightToLeftText"),
        ("m_characterSpacing", "characterSpacing"), ("m_wordSpacing", "wordSpacing"),
        ("m_lineSpacing", "lineSpacing"), ("m_paragraphSpacing", "paragraphSpacing"),
        ("m_enableWordWrapping", "enableWordWrapping"),
        ("m_isRichText", "richText"), ("m_overflowMode", "overflowMode"),
        ("m_margin", "margin"), ("m_parseCtrlCharacters", "parseCtrlCharacters"),
        ("m_Enabled", "enabled"),
    ],
    # ---- Canvas / CanvasGroup / Camera / 音频 / 灯光 ----
    "Canvas": [
        ("m_RenderMode", "renderMode"), ("m_Camera", "worldCamera"),
        ("m_PlaneDistance", "planeDistance"), ("m_SortingLayerID", "sortingLayerID"),
        ("m_SortingLayerName", "sortingLayerName"), ("m_SortingOrder", "sortingOrder"),
        ("m_TargetDisplay", "targetDisplay"), ("m_OverrideSorting", "overrideSorting"),
        ("m_PixelPerfect", "pixelPerfect"), ("m_AdditionalShaderChannelsFlag", "additionalShaderChannels"),
        ("m_Enabled", "enabled"),
    ],
    "CanvasGroup": [
        ("m_Alpha", "alpha"), ("m_Interactable", "interactable"),
        ("m_BlocksRaycasts", "blocksRaycasts"), ("m_IgnoreParentGroups", "ignoreParentGroups"),
        ("m_Enabled", "enabled"),
    ],
    "CanvasRenderer": [("m_CullTransparentMesh", "cullTransparentMesh")],
    "Camera": [
        # Unity 的 Camera 在 YAML 里用带空格的名字（"near clip plane" / "orthographic size"）。
        ("orthographic size", "orthographicSize"), ("m_OrthographicSize", "orthographicSize"),
        ("orthographic", "orthographic"), ("m_BackGroundColor", "backgroundColor"),
        ("m_BackgroundColor", "backgroundColor"),
        ("m_ClearFlags", "clearFlags"), ("near clip plane", "nearClipPlane"),
        ("m_NearClipPlane", "nearClipPlane"), ("far clip plane", "farClipPlane"),
        ("m_FarClipPlane", "farClipPlane"), ("field of view", "fieldOfView"),
        ("m_Depth", "depth"), ("m_CullingMask", "cullingMask"),
        ("m_TargetDisplay", "targetDisplay"), ("m_HDR", "allowHDR"),
        ("m_AllowMSAA", "allowMSAA"), ("m_Rect", "rect"), ("m_Enabled", "enabled"),
    ],
    "AudioSource": [
        # Unity 的 AudioSource 在 YAML 里用 C# 属性名（Volume/Loop/…）而不是 m_* 前缀。
        ("m_audioClip", "clip"), ("m_Volume", "volume"), ("m_PlayOnAwake", "playOnAwake"),
        ("Volume", "volume"), ("Loop", "loop"), ("Mute", "mute"),
        ("PlayOnAwake", "playOnAwake"), ("Pitch", "pitch"), ("m_Pitch", "pitch"),
        ("SpatialBlend", "spatialBlend"), ("Priority", "priority"),
        ("DopplerLevel", "dopplerLevel"), ("MinDistance", "minDistance"),
        ("MaxDistance", "maxDistance"), ("rolloffMode", "rolloffMode"),
        ("OutputAudioMixerGroup", "outputAudioMixerGroup"),
        ("m_Enabled", "enabled"),
    ],
    "Light": [
        ("m_Type", "type"), ("m_Color", "color"), ("m_Intensity", "intensity"),
        ("m_Range", "range"), ("m_SpotAngle", "spotAngle"), ("m_Enabled", "enabled"),
    ],
    "Rigidbody": [
        ("m_Mass", "mass"), ("m_Drag", "drag"), ("m_AngularDrag", "angularDrag"),
        ("m_UseGravity", "useGravity"), ("m_IsKinematic", "isKinematic"),
        ("m_Constraints", "constraints"), ("m_CollisionDetection", "collisionDetectionMode"),
        ("m_Interpolate", "interpolation"),
    ],
    "SpriteRenderer": [
        # PORT-NOTE: Unity YAML 里 `m_SortingLayer` 是**排序层的 int 哈希**（例如 -1992807571），
        # 不是名字；名字字段是 `m_SortingLayerName`（多数 prefab 里没有）。shim 只有
        # `sortingLayerName:String`，因此 m_SortingLayer 不映射（保留在 unmappedFields 里），
        # 需要 ID 时由 `sortingLayerID` 提供。
        ("m_Enabled", "enabled"), ("m_SortingLayerID", "sortingLayerID"),
        ("m_SortingLayerName", "sortingLayerName"), ("m_SortingOrder", "sortingOrder"),
        ("m_Sprite", "sprite"), ("m_Color", "color"), ("m_FlipX", "flipX"),
        ("m_FlipY", "flipY"), ("m_DrawMode", "drawMode"), ("m_Size", "size"),
        ("m_SpriteTileMode", "spriteTileMode"), ("m_MaskInteraction", "maskInteraction"),
        ("m_Materials", "materials"),
    ],
    "MeshRenderer": [
        ("m_Enabled", "enabled"), ("m_SortingLayerID", "sortingLayerID"),
        ("m_SortingLayerName", "sortingLayerName"), ("m_SortingOrder", "sortingOrder"),
        ("m_Materials", "materials"),
    ],
    "SpriteMask": [
        # 字段名对齐 unity.SpriteMask shim（frontSortingOrder / backSortingOrder / alphaCutoff）。
        ("m_Sprite", "sprite"), ("m_AlphaCutoff", "alphaCutoff"),
        ("m_MaskAlphaCutoff", "alphaCutoff"),
        ("m_FrontSortingOrder", "frontSortingOrder"),
        ("m_BackSortingOrder", "backSortingOrder"),
        # Renderer 基类字段（unity.Renderer shim）。
        ("m_SortingLayerID", "sortingLayerID"), ("m_SortingLayerName", "sortingLayerName"),
        ("m_SortingOrder", "sortingOrder"), ("m_Materials", "materials"),
        ("m_Enabled", "enabled"),
    ],
    "SortingGroup": [
        ("m_Enabled", "enabled"), ("m_SortingLayerID", "sortingLayerID"),
        ("m_SortingLayerName", "sortingLayerName"), ("m_SortingOrder", "sortingOrder"),
        ("m_SortAtRoot", "sortAtRoot"),
    ],
    "AudioListener": [("m_Enabled", "enabled")],
}

# 完全丢弃的 Unity 头字段（组件级），与 build_models 的 UNITY_HEADER_FIELDS 一致。
DROP_FIELDS = set(bm.UNITY_HEADER_FIELDS)

# Unity 把 LayerMask / 位掩码序列化成 `{serializedVersion: 2, m_Bits: <int>}`，
# 而移植层 shim 里这些字段是 Int（或 unity.LayerMask，构造参数就是那个 int）。
# 这些目标字段名在映射时自动拆出 m_Bits。
BIT_MASK_FIELDS = {
    "cullingMask", "eventMask", "blockingMask", "callbackLayers",
    "forceSendLayers", "forceReceiveLayers", "excludeLayers", "includeLayers",
}


def _transform_field_value(dst_field, value):
    """把 Unity 的序列化形态转成 shim 能直接接收的形态。"""
    if dst_field in BIT_MASK_FIELDS and isinstance(value, dict) and "m_Bits" in value:
        return value["m_Bits"]
    return value

# Unity 内置 MonoBehaviour / Renderer 里「移植层没有对应字段、也不打算有」的字段：静默丢弃不计数，
# 避免 unmappedFields 被渲染管线细节淹没。
IGNORED_UNMAPPED_FIELDS = {
    "m_OnCullStateChanged", "m_OnClick", "m_OnValueChanged", "m_OnDeselect",
    "m_OnEndEdit", "m_OnEndTextSelection", "m_OnSelect", "m_OnSubmit",
    "m_OnTextSelection", "m_OnTouchScreenKeyboardStatusChanged",
    "m_OnFocusSelectAll", "m_OnUpdateSelected", "m_OnDeselectAll",
    "m_Colors", "m_SpriteState", "m_AnimationTriggers", "m_Navigation",
    "m_Material", "m_baseMaterial", "m_fontMaterial", "m_fontMaterials",
    "m_fontSharedMaterials", "m_StyleSheet", "m_TextStyleHashCode",
    "m_VertexBufferAutoSizeReduction", "m_IsTextObjectScaleStatic",
    "m_isCullingEnabled", "m_isVolumetricText", "m_isUsingLegacyAnimationComponent",
    "m_geometrySortingOrder", "m_hasFontAssetChanged", "m_maskOffset",
    "m_useMaxVisibleDescender", "m_horizontalMapping", "m_verticalMapping",
    "m_uvLineOffset", "m_uv2LineOffset", "m_wordWrappingRatios", "m_pageToDisplay",
    "m_linkedTextComponent", "parentLinkedComponent", "m_renderer", "m_renderMode",
    "m_forceRenderMode", "checkPaddingRequired", "m_faceColor", "m_fontColor32",
    "m_fontColorGradient", "m_fontColorGradientPreset", "m_fontWeight",
    "m_enableVertexGradient", "m_tintAllSprites", "m_spriteAsset",
    "m_overrideHtmlColors", "m_charWidthMaxAdj", "m_lineSpacingMax",
    "m_autoSizeTextContainer", "m_material", "m_sharedMaterial",
    "m_AdditionalShaderChannelsFlag", "m_OverrideSorting", "m_SortingLayerName",
    "m_UiScaleMode", "m_EditorHideFlags",
    # ---- 渲染管线细节（移植层是 2D 渲染，无对应概念；build_models 同样不导出）----
    "m_CastShadows", "m_ReceiveShadows", "m_DynamicOccludee", "m_StaticShadowCaster",
    "m_MotionVectors", "m_LightProbeUsage", "m_ReflectionProbeUsage",
    "m_RayTracingMode", "m_RayTraceProcedural", "m_RenderingLayerMask",
    "m_RendererPriority", "m_SmallMeshCulling", "m_ForceMeshLod", "m_MeshLodSelectionBias",
    "m_ProbeAnchor", "m_LightProbeVolumeOverride", "m_ScaleInLightmap",
    "m_ReceiveGI", "m_PreserveUVs", "m_IgnoreNormalsForChartDetection",
    "m_ImportantGI", "m_StitchLightmapSeams", "m_SelectedEditorRenderState",
    "m_MinimumChartSize", "m_AutoUVMaxDistance", "m_AutoUVMaxAngle",
    "m_LightmapParameters", "m_SortingFudge", "m_StaticBatchInfo", "m_StaticBatchRoot",
    "m_ReceiveShadows2", "m_AdaptiveModeThreshold", "m_SpriteSortPoint",
    # ---- 3D / 物理 / 音频滤镜细节 ----
    "m_Convex", "m_IsTrigger", "m_UsedByEffector", "m_UsedByComposite", "m_Offset",
    "m_SpriteTilingProperty", "m_IsTrigger2", "m_Center", "m_Size", "m_Radius",
    "m_ContactCaptureLayers", "m_CallbackLayers", "m_ForceSendLayers", "m_ForceReceiveLayers",
    "m_ExcludeLayers", "m_IncludeLayers", "m_LayerOverridePriority", "m_CompositeOperation",
    "m_CompositeOrder", "m_GeometryType", "m_GenerationType", "m_VertexDistance",
    "m_EdgeRadius", "m_AutoTiling", "m_Points", "m_PathCount", "m_UseDelaunayMesh",
    "m_Interpolate", "m_Constraints", "m_CollisionDetection", "m_IsKinematic",
    "m_UseGravity", "m_Mass", "m_Drag", "m_AngularDrag", "m_Velocity", "m_AngularVelocity",
    "m_SleepThreshold", "m_MaxAngularVelocity", "m_MaxLinearVelocity", "m_MaxDepenetrationVelocity",
    "m_ImplicitCom", "m_ImplicitTensor", "m_InertiaTensor", "m_InertiaRotation",
    "m_IncludeLayers2", "m_ExcludeLayers2", "m_PlayerExists", "m_PlayerHideCursor",
    # ---- AudioSource / AudioListener 的 3D 空间细节（移植层无 3D 音频）----
    "m_GamepadSpeakerMix", "m_Spatialize", "m_SpatializePostEffects", "m_BypassEffects",
    "m_BypassListenerEffects", "m_BypassReverbZones", "m_ReverbZoneMix",
    "m_LowpassLevel", "m_HighpassLevel", "m_DistanceModel", "m_MinDistance",
    "m_MaxDistance", "m_RolloffCustomCurve", "m_Spread", "m_DopplerLevel",
    "m_GamepadSpeakerLevel", "m_Loop2", "m_Priority2",
    # ---- Camera 的 3D/后处理细节 ----
    "m_ClearFlags", "m_BackGroundColor", "m_projectionMatrixMode", "m_GateFitMode",
    "m_FOVAxisMode", "m_Iso", "m_ShutterSpeed", "m_Aperture", "m_FocusDistance",
    "m_FocalLength", "m_BladeCount", "m_Curvature", "m_BarrelClipping", "m_Anamorphism",
    "m_SensorSize", "m_LensShift", "m_NormalizedViewPortRect", "m_UseOcclusionCulling",
    "m_AllowHDR", "m_AllowMSAA", "m_AllowDynamicResolution", "m_ForceIntoRT",
    "m_OcclusionCulling", "m_StereoConvergence", "m_StereoSeparation",
    "m_DepthTextureMode", "m_TargetEye", "m_TargetTexture", "m_HDR",
    "m_NearClipPlane", "m_FarClipPlane", "m_FieldOfView", "m_OrthographicSize",
    "m_Orthographic", "m_Depth", "m_CullingMask", "m_RenderingPath",
    "m_TargetDisplay", "m_AudioListener", "m_Enabled2",
    # ---- Canvas 的 UI 细节 ----
    "m_OverridePixelPerfect", "m_VertexColorAlwaysGammaSpace", "m_SortingLayerName2",
    "m_NormalsRendering", "m_AdditionalShaderChannels",
}


def project_component_scene(doc_class, body, project, unmapped):
    """组件文档 -> (类型名, 字段表[, 脚本信息])，供 build_models.build_node_graph 使用。

    与 build_models.project_component 的差别：
      1. MonoBehaviour 的脚本 guid 若是 Unity 包内置（UNITY_PACKAGE_SCRIPTS），
         用包内类型名做投影并套用 UI_COMPONENT_FIELDS；
      2. 其余组件若在 UI_COMPONENT_FIELDS 里有映射（Canvas/Camera/AudioSource…），同样套用。

    PORT-NOTE: 兜底分支必须调 `_ORIGINAL_PROJECT_COMPONENT`（模块导入时捕获的原始函数），
    不能调 `bm.project_component` —— 后者会被 `_build_node_graph` 临时替换成本函数，直接死循环。
    """
    if doc_class == "MonoBehaviour":
        script_guid = bm._script_guid(body)
        package_type = UNITY_PACKAGE_SCRIPTS.get(script_guid) if script_guid else None
        if package_type is not None:
            spec = UI_COMPONENT_FIELDS.get(package_type)
            fields = OrderedDict()
            if spec is None:
                fields.update(_generic_fields_scene(body, package_type, unmapped))
            else:
                mapped_src = set()
                for src, dst in spec:
                    if src in body:
                        fields[dst] = _transform_field_value(dst, body[src])
                        mapped_src.add(src)
                for key, value in body.items():
                    if key in DROP_FIELDS or key in mapped_src:
                        continue
                    _record_unmapped(unmapped, package_type, key)
            return "MonoBehaviour", fields, {
                "path": "(Unity 包内置组件)",
                "namespace": package_type.rsplit(".", 1)[0],
                "class": package_type.rsplit(".", 1)[1],
                "fullName": package_type,
            }
        script = project.script_index.get(script_guid) if script_guid else None
        if script is not None:
            script = dict(script)
            # PORT-NOTE: build_models 的 script_index 用**文件名**当类名（`Foo.cs` -> `Foo`）。
            # 工程里存在「文件名 != 类名」的脚本（Engine/Tools/Unity/PositionTranslator.cs 里
            # 定义的类是 PositionTransition），运行期的组件表按 C# 类名索引，所以这里从源码里
            # 解析真实类名，避免这类脚本在运行期被判为未知组件。
            real_class = resolve_script_class(project, script_guid)
            if real_class is not None and real_class != script["class"]:
                script["class"] = real_class
                script["fullName"] = (script["namespace"] + "." + real_class) if script["namespace"] else real_class
        fields = OrderedDict()
        if "m_Enabled" in body:
            fields["enabled"] = body["m_Enabled"]
        fields.update(bm._generic_fields(body))
        return "MonoBehaviour", fields, script

    spec = UI_COMPONENT_FIELDS.get(doc_class)
    if spec is not None:
        fields = OrderedDict()
        mapped_src = set()
        for src, dst in spec:
            if src in body:
                fields[dst] = _transform_field_value(dst, body[src])
                mapped_src.add(src)
        for key, value in body.items():
            if key in DROP_FIELDS or key in mapped_src:
                continue
            _record_unmapped(unmapped, doc_class, key)
        return doc_class, fields
    return _ORIGINAL_PROJECT_COMPONENT(doc_class, body, project)


SCRIPT_CLASS_RE = re.compile(r"^\s*(?:public\s+|internal\s+|sealed\s+|abstract\s+|partial\s+)*class\s+([A-Za-z_]\w*)",
                              re.M)


def resolve_script_class(project, script_guid):
    """从 .cs 源码里解析第一个顶层类名（文件名与类名不一致时用）。"""
    path = project.guid_index.get(script_guid)
    if path is None or not path.endswith(".cs"):
        return None
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            text = f.read()
    except OSError:
        return None
    m = SCRIPT_CLASS_RE.search(text)
    return m.group(1) if m else None


def _generic_fields_scene(body, type_name, unmapped):
    fields = OrderedDict()
    for key, value in body.items():
        if key in DROP_FIELDS:
            continue
        _record_unmapped(unmapped, type_name, key)
    return fields


def _record_unmapped(unmapped, type_name, field):
    if field in IGNORED_UNMAPPED_FIELDS:
        return
    unmapped[type_name + "." + field] += 1


# --------------------------------------------------------------------------------------
# 组件类型覆盖审计（与 build_models.SUPPORTED_COMPONENT_TYPES 的口径一致）
# --------------------------------------------------------------------------------------
#
# 移植层有对应 Haxe 类的组件类型：unity shim 的内置组件 + 上面 UNITY_PACKAGE_SCRIPTS 里
# 已映射到 shim 的 UI 包组件。用于清单里的 unsupportedComponents（便于定位缺口）。
SUPPORTED_COMPONENT_TYPES = set(bm.SUPPORTED_COMPONENT_TYPES)
# UI 包组件在导出数据里的 type 仍然是 "MonoBehaviour"，靠 script 名判断；这里列出移植层有 shim 的。
SUPPORTED_SCRIPT_TYPES = {
    "UnityEngine.UI.Image", "UnityEngine.UI.RawImage", "UnityEngine.UI.Button",
    "UnityEngine.UI.Toggle", "UnityEngine.UI.ToggleGroup", "UnityEngine.UI.Slider",
    "UnityEngine.UI.Scrollbar", "UnityEngine.UI.ScrollRect", "UnityEngine.UI.Shadow",
    "UnityEngine.UI.Outline", "UnityEngine.UI.Mask", "UnityEngine.UI.LayoutElement",
    "UnityEngine.UI.ContentSizeFitter", "UnityEngine.UI.AspectRatioFitter",
    "UnityEngine.UI.CanvasScaler", "UnityEngine.UI.GraphicRaycaster",
    "UnityEngine.EventSystems.EventSystem",
    "UnityEngine.EventSystems.StandaloneInputModule",
    "TMPro.TextMeshProUGUI", "TMPro.TextMeshPro",
}
# PORT-NOTE: 以下 UI 包组件**没有** shim，会在运行期记入 unknownComponents（不静默丢失）：
#   UnityEngine.EventSystems.PhysicsRaycaster（无对应 shim；Raycaster 逻辑由
#   mvz2.level.LevelRaycaster / mvz2.ui.RaycastReceiver 自行实现）
#   AudioDistortionFilter / AudioLowPassFilter（音频滤镜，移植层无实现）
# 其余已注册 guid 的 UI/TMP 组件都有 shim（Image/RawImage/Button/Toggle/ToggleGroup/
# Slider/Scrollbar/ScrollRect/Shadow/Outline/Mask/LayoutElement/LayoutGroup 家族/
# ContentSizeFitter/AspectRatioFitter/CanvasScaler/GraphicRaycaster/EventSystem/
# StandaloneInputModule/TextMeshProUGUI/TextMeshPro/TMP_InputField/TMP_Dropdown）。
UNSUPPORTED_SCRIPT_TYPES = {
    "UnityEngine.EventSystems.PhysicsRaycaster",
    "UnityEngine.EventSystems.StandaloneInputModule",
    "AudioDistortionFilter", "AudioLowPassFilter",
}


def is_supported_component(comp):
    """导出数据里的组件在移植层是否有对应 Haxe 类。"""
    if comp["type"] == "MonoBehaviour":
        script = comp.get("script")
        if script is None:
            return False
        if script in UNSUPPORTED_SCRIPT_TYPES:
            return False
        return True
    return comp["type"] in SUPPORTED_COMPONENT_TYPES


# --------------------------------------------------------------------------------------
# 场景解析
# --------------------------------------------------------------------------------------

def parse_scene_entry(project, name, rel_path, resolved):
    """场景 -> 条目（记录根节点覆盖值，供诊断/对拍）。

    PORT-NOTE: 调用方必须传入**已解析**的 `resolved`（export 里先 resolve 再调本函数）——
    resolve_prefab 有缓存且悬空引用计数只在首次解析时累加，若这里自己再解析一次，
    计数会被算到 export 之外（表现为 danglingRefs 恒为 0）。
    """
    abs_path = os.path.join(project.root, rel_path)
    if not os.path.exists(abs_path):
        return None
    entry = {
        "name": name,
        "asset": project.rel_path(abs_path),
        "source": rel_path.replace("\\", "/"),
        "guid": resolved["guid"],
        "data": "%s/scenes/%s.json" % (PREFAB_OUT_DIR_NAME, name),
    }
    # 场景里唯一的 PrefabInstance = 场景根（见脚本头部说明）。
    instances = [rec for rec in resolved["objects"].values() if rec["class"] == "PrefabInstance"]
    if instances:
        source = (instances[0]["data"].get("m_SourcePrefab") or {}).get("guid")
        source_path = project.guid_index.get(source)
        entry["prefab"] = project.rel_path(source_path) if source_path else None
        entry["prefabSource"] = (os.path.relpath(source_path, project.root).replace("\\", "/")
                                 if source_path else None)
    return entry


def build(args):
    project = bm.UnityProject(args.project_root)
    project.mount_strays = True
    stats = Counter()
    unmapped = Counter()

    scenes = OrderedDict()
    prefabs = OrderedDict()
    written = 0

    def export(key, abs_path, kind, extra=None, extra_of=None):
        nonlocal written
        # PORT-NOTE: resolve_prefab 有缓存，缓存命中时不会重新产生 dangling/recovered 计数
        # （prefab 在图里被多次实例化时第二次起就命中缓存）。因此把计数差值的下界钳到 0，
        # 避免出现负数；统计口径是「首次解析该 prefab 时产生的悬空引用数」。
        before_dangling = project.dangling
        before_recovered = project.recovered
        try:
            resolved = project.resolve_prefab(abs_path)
            nodes, roots, warnings, strays = _build_node_graph(resolved, project, stats, unmapped)
        except Exception as exc:  # noqa: BLE001
            stats["failed"] += 1
            return {"key": key, "error": "%s: %s" % (type(exc).__name__, exc)}
        dangling = max(0, project.dangling - before_dangling)
        recovered = max(0, project.recovered - before_recovered)
        stats["converted"] += 1
        stats["nodes"] += len(nodes)
        stats["danglingRefs"] += dangling
        stats["recoveredRefs"] += recovered
        stats["strayRootsMounted"] += strays
        out_rel = sanitize_scene_file_path(key, kind)
        entry = OrderedDict()
        entry["key"] = key
        entry["kind"] = kind
        entry["asset"] = project.rel_path(abs_path)
        entry["source"] = os.path.relpath(abs_path, project.root).replace("\\", "/")
        entry["guid"] = resolved["guid"]
        entry["data"] = out_rel.replace("\\", "/")
        entry["nodeCount"] = len(nodes)
        entry["componentCount"] = sum(len(n["components"]) for n in nodes)
        entry["rootCount"] = len(roots)
        if dangling:
            entry["danglingRefs"] = dangling
        if recovered:
            entry["recoveredRefs"] = recovered
        if strays:
            entry["strayRoots"] = strays
        if extra_of is not None:
            extra = extra_of(resolved)
        if extra:
            entry.update(extra)
        unsupported = sorted({
            (c.get("script") or c["type"])
            for n in nodes for c in n["components"]
            if not is_supported_component(c)
        })
        if unsupported:
            entry["unsupportedComponents"] = unsupported
        if warnings:
            entry["warnings"] = warnings[:20]
        if not args.report:
            payload = {
                "version": 1,
                "generatedBy": "HaxePort/tools_build/build_scene.py",
                "key": key,
                "kind": kind,
                "asset": project.rel_path(abs_path),
                "source": os.path.relpath(abs_path, project.root).replace("\\", "/"),
                "guid": resolved["guid"],
                "roots": roots,
                "nodes": nodes,
                "warnings": warnings,
            }
            out_path = os.path.join(args.out, out_rel)
            os.makedirs(os.path.dirname(out_path), exist_ok=True)
            with open(out_path, "w", encoding="utf-8", newline="\n") as f:
                json.dump(payload, f, ensure_ascii=False, indent=None, sort_keys=False)
                f.write("\n")
            written += 1
        return entry

    # 1) 场景
    for name, rel in SCENES.items():
        abs_path = os.path.join(project.root, rel)
        if not os.path.exists(abs_path):
            stats["missingScene"] += 1
            continue
        # PORT-NOTE: extra 必须在 export 内部（resolve 之后、同一个 resolve 结果上）构造，
        # 否则 parse_scene_entry 自己再 resolve 一次会把悬空引用计数算到 export 的区间之外。
        entry = export(name, abs_path, "scene",
                       extra_of=lambda resolved: parse_scene_entry(project, name, rel, resolved) or {})
        scenes[name] = entry

    if args.scenes_only:
        args.only = None

    # 2) prefab（Assets/Prefabs 下的全部；模型 prefab 由 build_models.py 负责）
    if not args.scenes_only:
        for root_rel in PREFAB_ROOTS:
            root_abs = os.path.join(project.root, root_rel)
            if not os.path.isdir(root_abs):
                continue
            for dirpath, dirnames, filenames in os.walk(root_abs):
                dirnames.sort()
                for name in sorted(filenames):
                    if not name.endswith(".prefab"):
                        continue
                    abs_path = os.path.join(dirpath, name)
                    rel = os.path.relpath(abs_path, project.root).replace("\\", "/")
                    key = os.path.splitext(rel[len("Assets/"):])[0]
                    if args.only and key not in args.only:
                        continue
                    stats["total"] += 1
                    prefabs[key] = export(key, abs_path, "prefab")

    # 3) 清单
    if not args.report:
        manifest = {
            "version": 1,
            "generatedBy": "HaxePort/tools_build/build_scene.py",
            "note": ("关卡/UI prefab 与场景已按 Unity 的合并规则（嵌套 PrefabInstance / 变体覆盖 / "
                     "删除项）导出为节点表；字段编码与 model_prefabs 一致，运行期由 "
                     "mvz2.scenes.ScenePrefabLoader 重建 GameObject 层级。"
                     "scenes/prefabs 是数组（元素带 key）：Haxe 侧从 JSON 解析只得到匿名对象，"
                     "Map 需在运行期自行建立。"),
            "assetsRoot": "HaxePort/assets",
            "dataDir": PREFAB_OUT_DIR_NAME,
            "scenes": list(scenes.values()),
            "prefabs": list(prefabs.values()),
            "stats": dict(sorted(stats.items())),
            "unmappedFields": dict(unmapped.most_common(400)),
            "warnings": project.warnings[:200],
        }
        os.makedirs(args.out, exist_ok=True)
        with open(os.path.join(args.out, "scene_manifest.json"), "w",
                  encoding="utf-8", newline="\n") as f:
            json.dump(manifest, f, ensure_ascii=False, indent=1, sort_keys=False)
            f.write("\n")

    print("场景：%d，prefab：%d" % (len(scenes), len(prefabs)))
    for key in sorted(stats):
        print("  %-22s %s" % (key, stats[key]))
    print("未映射字段（组件.字段 -> 次数，前 40）：")
    for key, count in unmapped.most_common(40):
        print("  %-58s %s" % (key, count))
    print("未映射字段种类：%d（合计 %d 次）" % (len(unmapped), sum(unmapped.values())))
    if written:
        print("已写出：%s/scene_manifest.json，数据文件 %d 个" % (args.out, written))
    return 0


def _build_node_graph(resolved, project, stats, unmapped):
    """与 build_models.build_node_graph 相同，但用本脚本的组件投影。

    PORT-NOTE: build_models.build_node_graph 内部直接调 project_component，无法注入替换；
    这里用一个临时 monkey-patch 把投影函数换成 project_component_scene，其余逻辑完全复用
    （不复制那份 100 多行的树构建代码，避免两处实现漂移）。
    """
    original = bm.project_component

    def patched(doc_class, body, proj):
        return project_component_scene(doc_class, body, proj, unmapped)

    bm.project_component = patched
    try:
        return bm.build_node_graph(resolved, project)
    finally:
        bm.project_component = original


def sanitize_scene_file_path(key, kind):
    """key -> 输出文件相对路径。"""
    if kind == "scene":
        safe = re.sub(r"[^A-Za-z0-9_.\-]", "_", key)
        return os.path.join(PREFAB_OUT_DIR_NAME, "scenes", safe + ".json")
    safe = re.sub(r"[^A-Za-z0-9_.\-/]", "_", key)
    safe = safe.strip("/")
    if not safe:
        safe = "_"
    return os.path.join(PREFAB_OUT_DIR_NAME, safe + ".json")


def main(argv=None):
    parser = argparse.ArgumentParser(description="MVZ2 关卡/UI prefab 与场景 -> JSON 转换器")
    parser.add_argument("--project-root", default=DEFAULT_PROJECT_ROOT)
    parser.add_argument("--out", default=DEFAULT_OUT_DIR)
    parser.add_argument("--report", action="store_true", help="只打印统计，不写文件")
    parser.add_argument("--scenes-only", action="store_true", help="只转换两个场景")
    parser.add_argument("--only", action="append", default=None,
                        help="只转换指定 prefab key（相对 Assets 的路径去扩展名，可多次指定）")
    args = parser.parse_args(argv)
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except (AttributeError, ValueError):
        pass
    return build(args)


if __name__ == "__main__":
    raise SystemExit(main())
