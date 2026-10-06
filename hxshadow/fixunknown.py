import io, os, re, sys
from hxutil import scan_defs, read, write

PKGRE = re.compile(r'(?m)^package\s+([\w\.]*)\s*;')
IMP = re.compile(r'(?m)^[ \t]*import\s+([\w\.]+)(?:\.([\w]+))?\s*;')
STD = set('''String Int Float Bool Void Dynamic Array Map Null Iterator Iterable
Math Std StringTools Type Reflect Lambda Date Xml XmlType Enum Value
ArrayAccess Class Object Any Function FlxSprite FlxGroup FlxState FlxBasic FlxGame
FlxG FlxSpriteGroup FlxTypedGroup FlxText FlxTextFormat FlxSound FlxTimer FlxTween
FlxPoint FlxRect FlxColor FlxCamera FlxObject FlxEmitter FlxPath FlxButton
Signal FlxSignal FlxTypedSignal FlxSignalBase FlxTypedSignal1 FlxKeyManager
FlxTypedSignal2 FlxTypedSignal3 Bytes Int64 UInt Single Err Coroutine'''.split())


def main(roots, apply=False):
    files = []
    for root in roots:
        for dp, dn, fn in os.walk(root):
            for f in fn:
                if f.endswith('.hx'):
                    files.append(os.path.join(dp, f))
    # index all definitions
    defs = {}
    for dp, dn, fn in os.walk('source'):
        for f in fn:
            if not f.endswith('.hx'):
                continue
            p = os.path.join(dp, f)
            s = io.open(p, encoding='utf-8', errors='replace').read()
            m = PKGRE.search(s)
            pkg = m.group(1) if m else ''
            mod = f[:-3]
            for name, ln in scan_defs(p):
                fqn = (pkg + '.' + (name if name == mod else mod + '.' + name)) if pkg else (name if name == mod else mod + '.' + name)
                defs.setdefault(name, set()).add(fqn)
    total = 0
    for p in files:
        s = read(p)
        m = PKGRE.search(s)
        pkg = m.group(1) if m else ''
        mod = os.path.basename(p)[:-3]
        imported = set()
        for im in IMP.finditer(s):
            imported.add(im.group(1).split('.')[-1])
            if im.group(2):
                imported.add(im.group(2))
        own = set(n for n, l in scan_defs(p))
        own |= set(re.findall(r'(?m)^[ \t]*(?:public |private |static |override |inline )*(?:var|final)\s+([A-Za-z_]\w*)\s*[:=]', s))
        own |= set(re.findall(r'(?m)^[ \t]*(?:public |private |static |override |inline |dynamic )*function\s+([A-Za-z_]\w*)', s))
        own |= set(re.findall(r'(?m)^[ \t]*(?:public |private )?(?:static )?(?:var|final)\s+([A-Za-z_]\w*)', s))
        own.update(imported)
        candidates = set()
        for mm in re.finditer(r'(?:[:<(,\[ \t]|new\s+|extends\s+|implements\s+|->\s*)([A-Z]\w*)\b', s):
            candidates.add(mm.group(1))
        newimports = []
        for name in sorted(candidates):
            if name in own or name in STD or name == mod:
                continue
            targets = defs.get(name)
            if not targets or len(targets) != 1:
                continue
            t = list(targets)[0]
            tpkg, _, tlast = t.rpartition('.')
            if tpkg == pkg and tlast == name:
                continue  # same-package module: resolves without import
            if not tlast == name:
                continue  # secondary types are handled by fixmissing.py
            newimports.append(t)
        if newimports:
            total += len(newimports)
            print('%s -> %s' % (p.replace(os.sep, '/'), sorted(set(newimports))))
            if apply:
                lines = s.split('\n')
                res = []
                done = False
                for line in lines:
                    res.append(line)
                    if not done and (line.strip().startswith('import ') or line.strip().startswith('package ')):
                        if line.strip().startswith('package '):
                            continue
                        for ni in sorted(set(newimports)):
                            res.append('import %s;  // UNKNOWNIMPORT' % ni)
                        done = True
                if not done:
                    res = []
                    for line in lines:
                        res.append(line)
                        if not done and line.strip().startswith('package '):
                            for ni in sorted(set(newimports)):
                                res.append('import %s;  // UNKNOWNIMPORT' % ni)
                            done = True
                write(p, '\n'.join(res))
    print('total', total)


if __name__ == '__main__':
    args = [a for a in sys.argv[1:] if a != '--apply']
    main(args, '--apply' in sys.argv)
