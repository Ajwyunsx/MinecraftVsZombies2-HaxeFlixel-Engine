#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""MVZ2 Unity -> HaxeFlixel 移植：AnimatorController / AnimationClip 转换器

## 为什么需要这个脚本

Unity 侧的场景/UI 推进**依赖动画事件**：`Assets/Prefabs/Init/Splash.prefab` 的 `Splash` 节点上挂着
`Animator`（controller = `Assets/Animation/Init/Splash/splash.controller`），其默认状态播放
`splash.anim`，clip 的 `m_Events` 里有一条 `{time: 2.5, functionName: EnterTitleScreen}`。
Unity 在播放到 2.5 s 时对该 GameObject 上的 `SplashController` 调用 `EnterTitleScreen()`，
后者执行 `MainManager.Instance.Scene.DisplayTitlescreen()` —— **这是 Splash 页推进到标题页的唯一途径**。

移植层完全没有这套数据：`assets/Animation/` 下 152 个 `.controller` 与 612 个 `.anim` 已经镜像，
但没有任何脚本把它们转成运行期可用的形式，`unity.Animator.Update()` 是空实现，
`runtimeAnimatorController` 恒为 null。后果：`DisplayPage(Splash)` 之后永远停在黑屏的 Splash 页
（实测 release 跑 60 s，boot-trace 里再无任何页面切换痕迹）。

同一个缺口还挡住：`MainmenuController.Init`（`mainmenu_start.anim` 0.5 s 事件）、
`ChapterTransitionController.CallEnd`、`LevelUI.CallExitLevelToNote`、
`SoundPlayer.Play2D/PlaySound2D`、`Model.UpdateEnable` 等 —— 即**全工程的动画事件**。

## 转换范围

只转换**运行期真的会用到**的部分，不做通用动画系统：

* `AnimatorController`：参数表（名字/类型/默认值）、状态机（状态、默认状态、转移条件）、
  每个状态绑定的 clip 引用。**BlendTree 按「第一个子 clip」近似**（见下）。
* `AnimationClip`：`m_FloatCurves`（按 (path, classID, attribute) 归组）、`m_Events`、
  `m_SampleRate`、`m_WrapMode`。
* 曲线值按 Unity 的 `m_Curve` 关键帧原样导出（时间/值），运行期做线性插值。
  PORT-NOTE: Unity 的贝塞尔切线（`inSlope`/`outSlope`）**不导出**——移植层的动画只用来驱动
  透明度/位置/开关这类 UI 过渡，线性插值足够；`m_Curve` 的关键帧本身密度足够（这批 clip 都是
  手 K 的少量关键帧 + tangentMode 136 = 常量切线）。

## 输出

  <out>/anim_manifest.json                索引：controller / clip 路径 -> 分文件
  <out>/anim_prefabs/<path>.json          每个 controller / clip 一份

用法（在仓库根目录执行）：
    python HaxePort/tools_build/build_anim.py            # 全量转换
    python HaxePort/tools_build/build_anim.py --report   # 只打印统计，不写文件
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

from build_models import UnityProject, parse_unity_file  # noqa: E402

REPO_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))
# Unity 工程源（`Assets/**`，读取 .controller / .anim 的原始 YAML）。
UNITY_ASSETS_DIR = os.path.join(REPO_ROOT, "Assets")
# 移植层镜像（`HaxePort/assets/Animation/**`，运行期真的会读到的那些）。
MIRROR_ASSETS_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "..", "assets"))
OUT_DIR = MIRROR_ASSETS_DIR

# Unity 的 classID：组件类型。曲线里的 classID 决定写到哪个组件上。
#   1   GameObject      m_IsActive
#   4   Transform       m_LocalPosition / m_LocalScale / localEulerAnglesRaw
#   114 MonoBehaviour   脚本自定义字段（配合 script guid）
#   198 ParticleSystem  EmissionModule.enabled 等
#   212 SpriteRenderer  m_Color / m_FlipX / m_SortingOrder / m_Size
#   224 RectTransform   m_AnchoredPosition / m_SizeDelta / m_AnchorMin …
#   225 CanvasGroup     m_Alpha
CLASS_NAMES = {
    1: "GameObject",
    4: "Transform",
    114: "MonoBehaviour",
    198: "ParticleSystem",
    212: "SpriteRenderer",
    224: "RectTransform",
    225: "CanvasGroup",
}


def _float_curve_entry(curve):
    """把一条 m_FloatCurves 记录压成 (keys, path, classID, attribute, scriptGuid)。"""
    keys = []
    raw = (curve.get("curve") or {}).get("m_Curve") or []
    for key in raw:
        if not isinstance(key, dict):
            continue
        try:
            t = float(key.get("time"))
            v = float(key.get("value"))
        except (TypeError, ValueError):
            continue
        keys.append([t, v])
    keys.sort(key=lambda k: k[0])
    script = curve.get("script") or {}
    guid = script.get("guid") if isinstance(script, dict) else None
    return keys, curve.get("path") or "", int(curve.get("classID") or 0), curve.get("attribute") or "", guid


def _vector3_curve_entries(section, attribute_prefix, path_key):
    """
    把一段 Vector3 曲线段（`m_PositionCurves` / `m_EulerCurves` / `m_ScaleCurves`）展开成
    三条按分量拆分的 float 曲线。

    PORT-NOTE: Unity 的这两个曲线段把值写成 `{x,y,z}`（`m_FloatCurves` 则是标量 `value`），
    移植层的曲线求值器按「单条 float 曲线 -> 一个字段分量」工作（与 `m_FloatCurves` 一致），
    所以这里按分量展开成 `m_LocalPosition.x/y/z` 这样的 attribute，运行期不需要额外分支。
    `m_RotationCurves`（四元数 `{x,y,z,w}`）这批 clip 里为空，不处理。
    """
    entries = []
    for raw in section or []:
        if not isinstance(raw, dict):
            continue
        raw_keys = (raw.get("curve") or {}).get("m_Curve") or []
        components = {"x": [], "y": [], "z": []}
        for key in raw_keys:
            if not isinstance(key, dict):
                continue
            try:
                t = float(key.get("time"))
            except (TypeError, ValueError):
                continue
            value = key.get("value")
            if not isinstance(value, dict):
                continue
            for axis in ("x", "y", "z"):
                try:
                    components[axis].append([t, float(value.get(axis) or 0)])
                except (TypeError, ValueError):
                    pass
        path = raw.get(path_key) or ""
        for axis in ("x", "y", "z"):
            keys = components[axis]
            if not keys:
                continue
            keys.sort(key=lambda k: k[0])
            entries.append({
                "path": path,
                "classID": 4,
                "attribute": attribute_prefix + "." + axis,
                "script": None,
                "keys": keys,
            })
    return entries


def convert_clip(path, project):
    """把一个 .anim 转成运行期数据。"""
    docs = parse_unity_file(path)
    for doc in docs:
        if doc.class_name != "AnimationClip":
            continue
        body = doc.body
        curves = []
        for raw in body.get("m_FloatCurves") or []:
            if not isinstance(raw, dict):
                continue
            keys, cpath, class_id, attribute, guid = _float_curve_entry(raw)
            if not keys:
                continue
            curves.append({
                "path": cpath,
                "classID": class_id,
                "attribute": attribute,
                "script": guid,
                "keys": keys,
            })
        # Vector3 曲线段（Transform 的位置/欧拉角/缩放）。
        curves += _vector3_curve_entries(body.get("m_PositionCurves"), "m_LocalPosition", "path")
        curves += _vector3_curve_entries(body.get("m_EulerCurves"), "m_LocalEulerAngles", "path")
        curves += _vector3_curve_entries(body.get("m_ScaleCurves"), "m_LocalScale", "path")
        events = []
        for raw in body.get("m_Events") or []:
            if not isinstance(raw, dict):
                continue
            fn = raw.get("functionName")
            if not fn:
                continue
            try:
                time = float(raw.get("time") or 0)
            except (TypeError, ValueError):
                time = 0.0
            events.append({
                "time": time,
                # PORT-NOTE: 字段名用 `functionName` / `floatParam` / `intParam` 而不是 Unity 的
                # `function` / `float` / `int` —— 后三者是 Haxe 关键字（见 AnimData.hx 的 AnimEvent）。
                "functionName": fn,
                "data": raw.get("data") or "",
                "floatParam": _as_float(raw.get("floatParameter")),
                "intParam": int(raw.get("intParameter") or 0),
            })
        events.sort(key=lambda e: e["time"])
        # clip 长度 = 所有曲线关键帧时间的最大值（Unity 的 m_MuscleClip 里也有长度，
        # 但这批 clip 都是 m_Legacy=0 的通用曲线，取关键帧最大值等价）。
        length = 0.0
        for c in curves:
            if c["keys"]:
                length = max(length, c["keys"][-1][0])
        for e in events:
            length = max(length, e["time"])
        return {
            "kind": "clip",
            "name": body.get("m_Name") or os.path.splitext(os.path.basename(path))[0],
            "length": length,
            "sampleRate": _as_float(body.get("m_SampleRate"), 60.0),
            "wrapMode": int(body.get("m_WrapMode") or 0),
            "legacy": int(body.get("m_Legacy") or 0),
            "curves": curves,
            "events": events,
        }
    return None


def _as_float(value, default=0.0):
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _key(file_id):
    """
    Unity 的 fileID 是 64 位整数，可能超出 Int32（实测 `-7411722888129386122`）。
    Haxe 的 Int 是 32 位，直接用数字会在 JSON 解析时溢出/丢精度，因此**一律转成十进制字符串**
    作为表键与引用值（见 AnimData.hx 的 PORT-NOTE）。
    """
    return str(int(file_id))


def convert_controller(path, project, clip_paths):
    """把一个 .controller 转成运行期数据。

    Unity 的 controller 文件由三类文档组成，通过 fileID 互相引用：
      * `AnimatorController`(91)   —— 参数表 + 层（每层指向一个状态机）
      * `AnimatorStateMachine`(1107) —— 状态列表 + 默认状态 + 转移
      * `AnimatorState`(1102)      —— 单个状态，m_Motion 指向 clip
      * `AnimatorStateTransition`(1101) —— 转移（条件 = 参数名 + 比较模式）
      * `BlendTree`(206)           —— 混合树（按参数混合多个 clip）
    """
    docs = parse_unity_file(path)
    by_id = {}
    for doc in docs:
        by_id[_key(doc.file_id)] = doc

    def ref_file_id(value):
        if isinstance(value, dict):
            fid = value.get("fileID")
            if fid is not None:
                return str(int(fid))
        return None

    # guid -> 运行期 clip key（相对 assets 的路径去扩展名）
    def clip_key_of(guid):
        if not guid:
            return None
        p = project.guid_index.get(guid)
        if not p:
            return None
        return clip_paths.get(p)

    controller = None
    for doc in docs:
        if doc.class_name == "AnimatorController":
            controller = doc
            break
    if controller is None:
        return None

    # ---- 参数表 ----
    parameters = []
    for raw in controller.body.get("m_AnimatorParameters") or []:
        if not isinstance(raw, dict):
            continue
        name = raw.get("m_Name")
        if not name:
            continue
        parameters.append({
            "name": name,
            "type": int(raw.get("m_Type") or 1),
            "defaultFloat": _as_float(raw.get("m_DefaultFloat")),
            "defaultInt": int(raw.get("m_DefaultInt") or 0),
            "defaultBool": bool(raw.get("m_DefaultBool")),
        })

    # ---- 状态（含 BlendTree）----
    states = {}
    for doc in docs:
        if doc.class_name == "AnimatorState":
            motion_id = ref_file_id(doc.body.get("m_Motion"))
            clip_key = None
            blend = None
            motion_doc = by_id.get(motion_id) if motion_id is not None else None
            if motion_doc is not None and motion_doc.class_name == "BlendTree":
                # PORT-NOTE: BlendTree 无法在不实现完整混合逻辑的前提下 1:1 还原。
                # 这批 controller 里 BlendTree 只用于 Mainmenu 的背景图混合（按 BlendX/BlendY 选一张
                # 背景），移植层按「第一个子 clip」近似：**动画事件与状态时长仍正确**，
                # 只是混合出的画面不是插值结果。真正的混合需要 sprite 层支持，见报告「未完成项」。
                children = motion_doc.body.get("m_Childs") or []
                blend = {
                    "blendX": motion_doc.body.get("m_BlendParameter"),
                    "blendY": motion_doc.body.get("m_BlendParameterY"),
                    "children": [],
                }
                for child in children:
                    if not isinstance(child, dict):
                        continue
                    cm = child.get("m_Motion") or {}
                    ck = clip_key_of(cm.get("guid") if isinstance(cm, dict) else None)
                    blend["children"].append({
                        "clip": ck,
                        "threshold": _as_float(child.get("m_Threshold")),
                        "x": _as_float((child.get("m_Position") or {}).get("x")),
                        "y": _as_float((child.get("m_Position") or {}).get("y")),
                    })
                if blend["children"]:
                    clip_key = blend["children"][0]["clip"]
            else:
                guid = None
                if isinstance(doc.body.get("m_Motion"), dict):
                    guid = doc.body["m_Motion"].get("guid")
                clip_key = clip_key_of(guid)
            transitions = [ref_file_id(t) for t in (doc.body.get("m_Transitions") or [])]
            states[_key(doc.file_id)] = {
                "name": doc.body.get("m_Name") or "",
                "clip": clip_key,
                "blend": blend,
                "speed": _as_float(doc.body.get("m_Speed"), 1.0),
                "transitions": [t for t in transitions if t is not None],
            }

    # ---- 转移 ----
    transitions = {}
    for doc in docs:
        if doc.class_name != "AnimatorStateTransition":
            continue
        conditions = []
        for cond in doc.body.get("m_Conditions") or []:
            if not isinstance(cond, dict):
                continue
            event = cond.get("m_ConditionEvent")
            if not event:
                continue
            conditions.append({
                "mode": int(cond.get("m_ConditionMode") or 0),
                "event": event,
                "threshold": _as_float(cond.get("m_EventTreshold")),
            })
        transitions[_key(doc.file_id)] = {
            "conditions": conditions,
            "dst": ref_file_id(doc.body.get("m_DstState")),
            "hasExitTime": bool(doc.body.get("m_HasExitTime")),
            "exitTime": _as_float(doc.body.get("m_ExitTime"), 1.0),
            "duration": _as_float(doc.body.get("m_TransitionDuration")),
        }

    # ---- 状态机 ----
    machines = {}
    for doc in docs:
        if doc.class_name != "AnimatorStateMachine":
            continue
        children = []
        for child in doc.body.get("m_ChildStates") or []:
            if not isinstance(child, dict):
                continue
            fid = ref_file_id(child.get("m_State"))
            if fid is not None:
                children.append(fid)
        any_transitions = [ref_file_id(t) for t in (doc.body.get("m_AnyStateTransitions") or [])]
        machines[_key(doc.file_id)] = {
            "name": doc.body.get("m_Name") or "",
            "states": children,
            # PORT-NOTE: 字段名用 `defaultState` 而不是 Unity 的 `default` —— `default` 是
            # Haxe 关键字，不能做字段名（见 AnimData.hx 的 AnimStateMachine）。
            "defaultState": ref_file_id(doc.body.get("m_DefaultState")),
            "anyTransitions": [t for t in any_transitions if t is not None],
        }

    # ---- 层 ----
    layers = []
    for raw in controller.body.get("m_AnimatorLayers") or []:
        if not isinstance(raw, dict):
            continue
        machine_id = ref_file_id(raw.get("m_StateMachine"))
        layers.append({
            "name": raw.get("m_Name") or "",
            "machine": machine_id,
            "defaultWeight": _as_float(raw.get("m_DefaultWeight"), 1.0),
        })

    return {
        "kind": "controller",
        "name": controller.body.get("m_Name") or os.path.splitext(os.path.basename(path))[0],
        "parameters": parameters,
        "layers": layers,
        "machines": {k: v for k, v in machines.items()},
        "states": {k: v for k, v in states.items()},
        "transitions": {k: v for k, v in transitions.items()},
    }


def collect_animation_files(project):
    """扫描工程里的 .controller / .anim（只收 assets 里已镜像的那些）。"""
    controllers = {}
    clips = {}
    for dirpath, _dirnames, filenames in os.walk(os.path.join(project.root, "Assets")):
        for name in filenames:
            ext = os.path.splitext(name)[1].lower()
            if ext not in (".controller", ".anim", ".overridecontroller"):
                continue
            full = os.path.join(dirpath, name)
            rel = os.path.relpath(full, project.root).replace(os.sep, "/")
            # PORT-NOTE: 镜像路径 = `Assets/` 之后的相对路径（`HaxePort/assets/Animation/...`，
            # 与 resource_manifest.json 的 `path` 字段同一约定）。只收**已经镜像**的资产：
            # 没镜像的文件运行期取不到，转出来只会是死数据。
            mirror_rel = rel[len("Assets/"):] if rel.startswith("Assets/") else rel
            if not os.path.isfile(os.path.join(MIRROR_ASSETS_DIR, mirror_rel)):
                continue
            if ext in (".controller", ".overridecontroller"):
                controllers[full] = rel
            else:
                clips[full] = rel
    return controllers, clips


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--report", action="store_true", help="只打印统计，不写文件")
    parser.add_argument("--only", default=None, help="只转换匹配的路径子串")
    args = parser.parse_args()

    project = UnityProject(REPO_ROOT)
    controllers, clips = collect_animation_files(project)
    if args.only:
        controllers = {k: v for k, v in controllers.items() if args.only in v}
        clips = {k: v for k, v in clips.items() if args.only in v}

    # clip / controller 的 key = 相对 assets 根的**完整路径（含扩展名）**，
    # 与场景数据里 `runtimeAnimatorController.asset.path` 的写法完全一致
    # （例如 "Animation/Init/Splash/splash.controller"）。保留扩展名还能避免
    # `X/splash.controller` 与 `X/splash.anim` 去扩展名后同名互相覆盖。
    clip_paths = {}
    for full, rel in clips.items():
        clip_paths[full] = rel[len("Assets/"):]

    print("controller=%d clip=%d" % (len(controllers), len(clips)))

    out_dir = os.path.join(OUT_DIR, "anim_prefabs")
    manifest_entries = []
    stats = {"controllers": 0, "clips": 0, "curves": 0, "events": 0, "states": 0, "unresolvedClips": 0}

    for full, rel in sorted(controllers.items()):
        data = convert_controller(full, project, clip_paths)
        if data is None:
            print("  [skip] %s（没有 AnimatorController 文档）" % rel)
            continue
        # PORT-NOTE: key 保留扩展名 —— `X/splash.controller` 与 `X/splash.anim` 去扩展名后同名，
        # 会互相覆盖（实测：Splash 的 controller 数据被同名 clip 覆盖掉，动画事件整条丢失）。
        key = rel[len("Assets/"):]
        stats["controllers"] += 1
        stats["states"] += len(data["states"])
        for state in data["states"].values():
            if state["clip"] is None and state["blend"] is None:
                stats["unresolvedClips"] += 1
        manifest_entries.append({
            "key": key,
            "kind": "controller",
            "asset": rel,
            "data": "anim_prefabs/%s.json" % key,
            "stateCount": len(data["states"]),
            "parameterCount": len(data["parameters"]),
        })
        if not args.report:
            path = os.path.join(out_dir, key + ".json")
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, separators=(",", ":"))

    for full, rel in sorted(clips.items()):
        data = convert_clip(full, project)
        if data is None:
            print("  [skip] %s（没有 AnimationClip 文档）" % rel)
            continue
        key = rel[len("Assets/"):]
        stats["clips"] += 1
        stats["curves"] += len(data["curves"])
        stats["events"] += len(data["events"])
        manifest_entries.append({
            "key": key,
            "kind": "clip",
            "asset": rel,
            "data": "anim_prefabs/%s.json" % key,
            "curveCount": len(data["curves"]),
            "eventCount": len(data["events"]),
            "length": data["length"],
        })
        if not args.report:
            path = os.path.join(out_dir, key + ".json")
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, separators=(",", ":"))

    manifest = {
        "version": 1,
        "generatedBy": "tools_build/build_anim.py",
        "assetsRoot": "Assets",
        "dataDir": "anim_prefabs",
        "entries": manifest_entries,
        "stats": stats,
        "warnings": project.warnings,
    }
    if not args.report:
        with open(os.path.join(OUT_DIR, "anim_manifest.json"), "w", encoding="utf-8") as f:
            json.dump(manifest, f, ensure_ascii=False, indent=1)
    print("stats: %s" % json.dumps(stats, ensure_ascii=False))
    for w in project.warnings[:10]:
        print("  warning: %s" % w)


if __name__ == "__main__":
    main()
