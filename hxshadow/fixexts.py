import io, os, re, sys

# Build map: extension-function-name -> module FQN, for extension-style static classes
FNDEF = re.compile(r'(?m)^[ \t]*(?:public |private )?static function ([A-Z]\w*)\s*\(\s*(\w+)\s*:\s*([\w\.<>]+)')
PKG = re.compile(r'(?m)^package\s+([\w\.]*)\s*;')
CLS = re.compile(r'(?m)^[ \t]*(?:public |private |final )*class\s+([A-Z]\w*)')
EXTFILE = re.compile(r'(Ext|Props|Helper|Extensions)\.hx$')

MY = ('metas', 'models', 'localization', 'saves', 'options', 'talk', 'talkdata')


def build():
    m = {}
    for dp, dn, fn in os.walk('source'):
        for f in fn:
            if not f.endswith('.hx') or not EXTFILE.search(f):
                continue
            p = os.path.join(dp, f)
            s = io.open(p, encoding='utf-8', errors='replace').read()
            pm = PKG.search(s)
            pkg = pm.group(1) if pm else ''
            mod = f[:-3]
            cls = CLS.search(s)
            clsname = cls.group(1) if cls else mod
            for mm in FNDEF.finditer(s):
                name = mm.group(1)
                # extension: first param is the receiver
                m.setdefault(name, set()).add('%s.%s' % (pkg, clsname) if pkg else clsname)
    return m


def main():
    ext = build()
    changed = 0
    for d in MY:
        for dp, dn, fn in os.walk('source/mvz2/' + d):
            for f in fn:
                if not f.endswith('.hx'):
                    continue
                p = os.path.join(dp, f)
                s = io.open(p, encoding='utf-8').read()
                usings = set(re.findall(r'(?m)^\s*using\s+([\w\.]+)\s*;', s))
                need = set()
                for name, mods in ext.items():
                    if len(mods) != 1:
                        continue
                    mod = list(mods)[0]
                    if mod in usings:
                        continue
                    # usage as instance method
                    if re.search(r'\.[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)?\.?' + name + r'\(', s) or re.search(r'\w\.' + name + r'\(', s):
                        need.add(mod)
                # keep only names actually called
                real = set()
                for mod in need:
                    for name, mods in ext.items():
                        if mods == {mod} and re.search(r'\.' + name + r'\(', s):
                            real.add(mod)
                            break
                if not real:
                    continue
                lines = s.split('\n')
                idxs = [i for i, l in enumerate(lines) if l.strip().startswith('import ') or l.strip().startswith('using ')]
                base = idxs[-1] if idxs else 0
                for k, mod in enumerate(sorted(real)):
                    lines.insert(base + 1 + k, 'using %s;  // EXTUSING' % mod)
                io.open(p, 'w', encoding='utf-8', newline='').write('\n'.join(lines))
                print('%s -> %s' % (p.replace(os.sep, '/'), sorted(real)))
                changed += 1
    print('files changed', changed)


main()
