"""For each page prefab: for Awake-declaring components, list record field names that have
no counterpart on the Haxe class (would make a runtime null-gate over-skip).

Usage: cd HaxePort && python tools_build/_page_field_audit.py
"""
import json
import os
import re

SRC = 'source'
DATA = 'assets/scene_prefabs/Prefabs'

cls2file = {}
for root, dirs, files in os.walk(SRC):
    for f in files:
        if not f.endswith('.hx'):
            continue
        p = os.path.join(root, f)
        rel = os.path.relpath(p, SRC).replace(os.sep, '/')[:-3]
        parts = rel.split('/')
        pkg = '.'.join(parts[:-1])
        full = (pkg + '.' + parts[-1]) if pkg else parts[-1]
        cls2file[full.lower()] = p

PAGES = {
    'Splash': 'Init/Splash', 'Titlescreen': 'Init/Titlescreen', 'Mainmenu': 'Mainmenu/Mainmenu',
    'Note': 'Note', 'Map': 'Map/Map', 'Almanac': 'Almanac/Almanac', 'Store': 'Store/Store',
    'Archive': 'Archive/Archive', 'Addons': 'Addons/Addons', 'MusicRoom': 'MusicRoom/MusicRoom',
    'Arcade': 'Arcade/Arcade', 'ChapterTransition': 'ChapterTransition', 'Credits': 'Mainmenu/Credits',
    'AchievementHint': 'UI/AchievementHint', 'DebugConsole': 'Level/UI/DebugConsole',
    'InputNameDialog': 'UI/Dialogs/InputNameDialog', 'DeleteUserDialog': 'UI/Dialogs/DeleteUserDialog',
    'CustomDialog': 'UI/Dialogs/CustomDialog',
}


def class_source(haxe):
    p = cls2file.get(haxe.lower())
    if not p:
        return None
    return open(p, encoding='utf-8').read()


def has_awake(src):
    return src is not None and re.search(r'\bfunction Awake\b', src) is not None


def declared(src, name):
    if re.search(r'\bvar\s+' + re.escape(name) + r'\b', src):
        return True
    if re.search(r'\bfunction\s+(get|set)_' + re.escape(name) + r'\b', src):
        return True
    return False


for page, key in PAGES.items():
    d = json.load(open(os.path.join(DATA, key + '.json'), encoding='utf-8'))
    rows = []
    for i, n in enumerate(d['nodes']):
        for c in n.get('components', []):
            haxe = c.get('haxe')
            if not haxe:
                continue
            src = class_source(haxe)
            if not has_awake(src):
                continue
            missing = [k for k in (c.get('fields') or {}) if k != 'enabled' and not declared(src, k)]
            if missing:
                rows.append((i, n['name'], haxe, missing))
    print('=== %s : %d Awake 组件含「数据里有、Haxe 类无」字段' % (page, len(rows)))
    for r in rows:
        print('    node %d %s : %s -> %s' % r)
