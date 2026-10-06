"""Audit: for each page prefab, list components that declare Awake and whether their
{ n, c } serialized references resolve to a component in the same prefab data.

Usage: cd HaxePort && python tools_build/_page_awake_audit.py [Page ...]
"""
import json
import os
import re
import sys

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
}


def has_awake(haxe):
    p = cls2file.get(haxe.lower())
    if not p:
        return False
    return re.search(r'\bfunction Awake\b', open(p, encoding='utf-8').read()) is not None


def refs(fields):
    out = []

    def walk(prefix, value):
        if isinstance(value, dict):
            if 'n' in value:
                out.append((prefix, value.get('n'), value.get('c')))
                return
            for k, v in value.items():
                walk(prefix + '.' + k if prefix else k, v)
        elif isinstance(value, list):
            for i, v in enumerate(value):
                walk('%s[%d]' % (prefix, i), v)

    for k, v in (fields or {}).items():
        walk(k, v)
    return out


def main():
    want = sys.argv[1:] or list(PAGES)
    for page in want:
        key = PAGES[page]
        d = json.load(open(os.path.join(DATA, key + '.json'), encoding='utf-8'))
        nodes = d['nodes']
        print('=== %s (%s)  nodes=%d roots=%s' % (page, key, len(nodes), d['roots']))
        root = nodes[d['roots'][0]]
        print('    root=%s comps=%s' % (root['name'], [c.get('script') or c.get('type') for c in root['components']]))
        for i, n in enumerate(nodes):
            for c in n.get('components', []):
                haxe = c.get('haxe')
                if not haxe or not has_awake(haxe):
                    continue
                print('  -- node %d %s : %s' % (i, n['name'], haxe))
                for name, rn, rc in refs(c.get('fields')):
                    if rn is None or rn >= len(nodes):
                        print('       %-28s -> BAD node %s' % (name, rn))
                        continue
                    target = nodes[rn]
                    if rc is None:
                        t = 'GameObject:%s' % target['name']
                    else:
                        comps = target.get('components') or []
                        if rc == 0:
                            t = 'Transform:%s' % target['name']
                        elif rc - 1 < len(comps):
                            rec = comps[rc - 1]
                            t = '%s:%s' % (rec.get('script') or rec.get('type'), target['name'])
                        else:
                            t = 'BAD c=%s (comps=%d):%s' % (rc, len(comps), target['name'])
                    print('       %-28s -> %s' % (name, t))


main()
