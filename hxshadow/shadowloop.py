import io, os, re, subprocess, sys, shutil
from hxutil import build_index, module_of, read, write, scan_defs

NL = chr(10)
LB = chr(123)
RB = chr(125)
MY = ('mvz2/metas', 'mvz2/models', 'mvz2/localization', 'mvz2/saves',
      'mvz2/options', 'mvz2/talk', 'mvz2/talkdata')
SHADOW = 'hxshadow'
BASH = 'C:' + os.sep + 'Program Files' + os.sep + 'Git' + os.sep + 'bin' + os.sep + 'bash.exe'
KNOWN = {'FlxTypedSignal': 'flixel.util.FlxSignal.FlxTypedSignal',
         'FlxSignal': 'flixel.util.FlxSignal.FlxSignal',
         'FlxPoint': 'flixel.math.FlxPoint',
         'FlxRect': 'flixel.math.FlxRect',
         'FlxColor': 'flixel.util.FlxColor'}


def paths(printed):
    p = printed.replace('\\', '/')
    if p.startswith(SHADOW + '/'):
        rel = p[len(SHADOW) + 1:]
    elif p.startswith('source/'):
        rel = p[len('source/'):]
    else:
        rel = p
    return os.path.join(SHADOW, rel), os.path.join('source', rel)


def is_mine(printed):
    p = printed.replace('\\', '/')
    for pre in (SHADOW + '/source/', 'source/'):
        if p.startswith(pre):
            p = p[len(pre):]
            break
    return any(p.startswith(m + '/') for m in MY)


def run():
    r = subprocess.run([BASH, SHADOW + '/check.sh'], capture_output=True, text=True)
    return (r.stdout + r.stderr).strip()


ERR = re.compile(r'^(.+?):(\d+): characters \d+-\d+ : (.*)$')


def add_import(slines, imp):
    key = imp.split(';')[0].strip()
    for l in slines:
        if l.strip().split('//')[0].strip() == key:
            return False
    for i, l in enumerate(slines):
        if l.strip().startswith('package '):
            slines.insert(i + 1, imp + '; // SHADOWFIX')
            return True
    for i, l in enumerate(slines):
        if l.strip().startswith('import '):
            slines.insert(i, imp + '; // SHADOWFIX')
            return True
    slines.insert(0, 'package x;')
    return True


def mechanical(p):
    s = read(p)
    o = s
    s = re.sub(r'(?m)^(\s*import\s+)mvz2\.IO\.', r'\1mvz2.io.', s)
    s = re.sub(r'\{var ([A-Za-z_]\w*):([A-Za-z_][\w.<>,?\[\]]*)\}', r'{ var \1:\2; }', s)
    s = re.sub(r'(?m)^(\s*(?:public |private |static |override |inline |dynamic )*function [^\n]*?\)\s*:[A-Za-z_][\w.<>,]*)\s+return ([^\n{}]+);\s*$',
               r'\1 { return \2; } // SHADOWFIX', s)

    def rep(m):
        ind = m.group(1)
        body = m.group(2).rstrip(NL)
        fin = m.group(3).strip(NL)
        return NL.join([ind + 'try', ind + LB, body, fin, ind + RB, ind + 'catch (e:Dynamic)',
                        ind + LB, fin, ind + '\tthrow e;', ind + RB]) + NL
    s = re.sub(r'(?ms)^([ \t]*)try\s*\n[ \t]*\{' + NL + r'(.*?)\n[ \t]*\}' + NL + r'[ \t]*finally\s*\n[ \t]*\{' + NL + r'(.*?)\n[ \t]*\}' + NL, rep, s)
    if s != o:
        write(p, s)
        return True
    return False


def main():
    idx = None
    seen = {}
    for it in range(400):
        out = run()
        if not out:
            print('CLEAN after %d foreign-shadow iterations' % it)
            return
        first = [l for l in out.split('\n') if l.strip()][0]
        m = ERR.match(first)
        if not m:
            print('UNPARSED:', first[:300])
            return
        printed, ln, msg = m.group(1), int(m.group(2)), m.group(3)
        if is_mine(printed):
            print('MINE -> stop:', first)
            return
        sp, rp = paths(printed)
        if os.path.exists(sp) and os.path.exists(rp) and os.path.getmtime(rp) > os.path.getmtime(sp) + 0.001:
            shutil.copy2(rp, sp)
            print('[%d] shadow refresh %s (real file updated)' % (it, rp))
        if not os.path.exists(sp):
            os.makedirs(os.path.dirname(sp), exist_ok=True)
            shutil.copy2(rp, sp)
            print('[%d] shadow copy %s' % (it, rp))
        key = (printed, msg)
        seen[key] = seen.get(key, 0) + 1
        if seen[key] > 2:
            print('STUCK on %s' % first)
            return
        if mechanical(sp):
            print('[%d] mechanical-shadow %s' % (it, rp))
            continue
        m7 = re.match(r"You can't iterate on a Dynamic value", msg)
        if m7:
            slines = read(sp).split('\n')
            line = slines[ln - 1]
            mm = re.search(r'\bfor\s*\(\s*\w+\s+in\s+(.+?)\)', line)
            if mm:
                slines[ln - 1] = line[:mm.start(1)] + '(cast ' + mm.group(1) + ':Array<Dynamic>)' + line[mm.end(1):]
                write(sp, '\n'.join(slines))
                print('[%d] shadow cast-iterable (%s)' % (it, rp))
                continue
        m4 = re.match(r'Field get_(\w+) needed by [\w\.]+ is missing', msg)
        if m4:
            from fixifaceprop import fix as ifacefix
            if ifacefix(sp, m4.group(1), tag='SHADOWFIX'):
                print('[%d] shadow property-ify %s (%s)' % (it, m4.group(1), rp))
                continue
        m5 = re.match(r'Static access to instance field (\w+) is not allowed', msg)
        if m5:
            name = m5.group(1)
            slines = read(sp).split('\n')
            line = slines[ln - 1]
            mm = re.search(r'(?<![\w.])([\w.]*[A-Z]\w*)\.' + re.escape(name) + r'\(', line)
            if mm:
                slines[ln - 1] = line.replace(mm.group(0), 'new %s().%s(' % (mm.group(1), name))
                write(sp, '\n'.join(slines))
                print('[%d] shadow instance-ify %s.%s (%s)' % (it, mm.group(1), name, rp))
                continue
        m2 = re.match(r'Redefinition of variable (\w+)', msg)
        if m2:
            name = m2.group(1)
            slines = read(sp).split('\n')
            del slines[ln - 1]
            for i, l in enumerate(slines):
                if re.match(r'^\s*(?:public |private |static )*function (?:get_|set_)' + name + r'\b', l) and 'override' not in l:
                    slines[i] = re.sub(r'(function )', r'override \1', l, count=1)
            write(sp, '\n'.join(slines))
            print('[%d] shadow drop redefined property %s (%s)' % (it, name, rp))
            continue
        m3 = re.match(r'Duplicate class field declaration : [\w\.]*?(\w+)$', msg)
        if m3:
            name = m3.group(1)
            slines = read(sp).split('\n')
            slines[ln - 1] = re.sub(r'(function\s+)' + re.escape(name) + r'\b',
                                    r'\1' + name + '_alt', slines[ln - 1], count=1)
            write(sp, '\n'.join(slines))
            print('[%d] shadow rename duplicate overload %s (%s)' % (it, name, rp))
            continue
        if msg.startswith('Type not found : '):
            full = msg[len('Type not found : '):]
            short = full.split('.')[-1]
            slines = read(sp).split('\n')
            cur = slines[ln - 1] if ln - 1 < len(slines) else ''
            if idx is None:
                idx = build_index()
            # case A2: <ImportedModule>.<SecondaryType> used with module qualifier
            IMPL = re.compile(r'(?m)^[ \t]*import\s+([\w\.]+)\s*;')
            body = read(sp)
            fixed_any = []
            implines = set()
            for im in IMPL.finditer(body):
                implines.add(im.group(0))
            lines0 = body.split('\n')
            for im in list(IMPL.finditer(body)):
                fq = im.group(1)
                mf = os.path.join('source', *fq.split('.')) + '.hx'
                if not os.path.exists(mf):
                    continue
                shortmod = fq.split('.')[-1]
                for s2, _l in scan_defs(mf):
                    if s2 == shortmod:
                        continue
                    pat = r'\b' + re.escape(shortmod) + r'\.' + re.escape(s2) + r'\b'
                    hit = False
                    for i, l in enumerate(lines0):
                        if l.strip().startswith('import '):
                            continue
                        if re.search(pat, l):
                            lines0[i] = re.sub(pat, s2, l)
                            hit = True
                    if hit:
                        fixed_any.append('%s.%s' % (fq, s2))
            if fixed_any:
                sl2 = lines0
                for f2 in sorted(set(fixed_any)):
                    add_import(sl2, 'import ' + f2)
                write(sp, '\n'.join(sl2))
                print('[%d] shadow unqualify %s (%s)' % (it, sorted(set(fixed_any)), rp))
                continue
            body = '\n'.join(lines0)
            # case A: Module.SubType accessed through a module name
            modfile = os.path.join('source', *full.split('.')) + '.hx'
            if os.path.exists(modfile):
                subs = [n for n, _ in scan_defs(modfile) if n != short]
                body = read(sp)
                used = [s for s in subs if re.search(r'\b' + re.escape(full) + r'\.' + re.escape(s) + r'\b', body)]
                if used:
                    for s in used:
                        body = re.sub(r'\b' + re.escape(full) + r'\.' + re.escape(s) + r'\b', s, body)
                    sl = body.split('\n')
                    for s in used:
                        add_import(sl, 'import %s.%s' % (full, s))
                    write(sp, '\n'.join(sl))
                    print('[%d] shadow unqualify %s (%s)' % (it, used, rp))
                    continue
            if cur.strip().startswith('import'):
                rest = ''.join(slines[:ln - 1] + slines[ln:])
                if not re.search(r'\b' + re.escape(short) + r'\b', rest):
                    write(sp, '\n'.join(slines[:ln - 1] + slines[ln:]))
                    print('[%d] shadow drop unused import %s (%s)' % (it, short, rp))
                    continue
                hits = [h for h in (idx.get(full) or idx.get('#' + short) or [])
                        if os.path.abspath(h) != os.path.abspath(rp)]
                targets = sorted(set(module_of(h, short) for h in hits))
                if len(targets) == 1 and targets[0] != full:
                    slines[ln - 1] = 'import %s; // SHADOWFIX' % targets[0]
                    write(sp, '\n'.join(slines))
                    print('[%d] shadow rewrite import %s -> %s (%s)' % (it, full, targets[0], rp))
                    continue
                if not hits:
                    modfile2 = os.path.join('source', *full.split('.')) + '.hx'
                    if not os.path.exists(modfile2):
                        pkg = '.'.join(full.split('.')[:-1])
                        cls = full.split('.')[-1]
                        members = sorted(set(re.findall(r'\b' + re.escape(cls) + r'\.(\w+)', read(sp))))
                        body2 = '\n'.join('\tpublic static var %s:Dynamic; // SHADOWSTUB' % x for x in members)
                        write(os.path.join(SHADOW, *full.split('.')) + '.hx',
                              'package %s;\n\nclass %s {\n%s\n}\n' % (pkg, cls, body2))
                        print('[%d] shadow STUB %s (%s) members=%s' % (it, full, rp, members))
                        continue
            else:
                hits = [h for h in (idx.get(full) or idx.get('#' + short) or [])
                        if os.path.abspath(h) != os.path.abspath(rp)]
                targets = sorted(set(module_of(h, short) for h in hits))
                add = targets[0] if len(targets) == 1 else KNOWN.get(short)
                if add and add_import(slines, 'import ' + add):
                    write(sp, '\n'.join(slines))
                    print('[%d] shadow add import %s (%s)' % (it, add, rp))
                    continue
                if not hits:
                    # last resort: create a stub in the referencing file's own package
                    pm = re.search(r'(?m)^package\s+([\w\.]*)\s*;', read(sp))
                    pkg = pm.group(1) if pm else ''
                    members = sorted(set(re.findall(r'\b' + re.escape(short) + r'\.(\w+)', read(sp))))
                    body3 = '\n'.join('\tvar %s = 0; // SHADOWSTUB' % x for x in members) or '\tvar None_ = 0;'
                    write(os.path.join(SHADOW, *(pkg.split('.') if pkg else []), short + '.hx'),
                          'package %s;\n\nenum abstract %s(Int) {\n%s\n}\n' % (pkg, short, body3))
                    print('[%d] shadow STUB enum %s in %s members=%s' % (it, short, pkg, members))
                    continue
        print(first)
        return
    print('iteration limit')


main()
