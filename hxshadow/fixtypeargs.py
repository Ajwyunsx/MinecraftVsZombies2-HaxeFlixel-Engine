import io, os, re, sys

# `X.Method<Type>(args)` is invalid Haxe (parsed as comparisons).
CALL = re.compile(r'([A-Za-z_][\w]*(?:\.[A-Za-z_]\w*)+)<([A-Z][\w\.<>,]*)>\(')
SKIP = re.compile(r'^\s*(?://|import |using |package |\*)')


def strip_calls(s):
    return CALL.sub(lambda m: m.group(1) + '(', s)


def fix_file(p):
    lines = io.open(p, encoding='utf-8').read().split('\n')
    changed = False
    for i, l in enumerate(lines):
        if SKIP.match(l) or '<' not in l:
            continue
        m = re.match(r'^(\s*)var\s+(\w+)\s*=\s*(.*)$', l)
        hit = CALL.search(l)
        if not hit:
            continue
        if m and CALL.search(m.group(3)):
            t = hit.group(2)
            rhs = strip_calls(m.group(3))
            lines[i] = '%svar %s:%s = %s' % (m.group(1), m.group(2), t, rhs)
        else:
            lines[i] = strip_calls(l)
        changed = True
    if changed:
        io.open(p, 'w', encoding='utf-8', newline='').write('\n'.join(lines))
        return True
    return False


if __name__ == '__main__':
    n = 0
    for root in sys.argv[1:]:
        for dp, dn, fn in os.walk(root):
            for f in fn:
                if f.endswith('.hx'):
                    if fix_file(os.path.join(dp, f)):
                        n += 1
                        print('fixed', os.path.join(dp, f).replace(os.sep, '/'))
    print('files changed', n)
