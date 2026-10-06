import io, os, re, sys

CLSDEF = re.compile(r'(?m)^([ \t]*)(?:public |private |final |extern )*class\s+([A-Z]\w*)([^\n]*)$')


def add_ctor(path, cls):
    s = io.open(path, encoding='utf-8').read()
    for m in CLSDEF.finditer(s):
        if m.group(2) != cls:
            continue
        tail = s[m.end():]
        bi = tail.find('{')
        if bi < 0 or ';' in tail[:bi]:
            continue
        indent = m.group(1) + '\t'
        rest = m.group(3)
        has_ext = 'extends' in rest
        body_start = m.end() + bi + 1
        # check constructor inside this class body
        d = 1
        j = body_start
        while j < len(s) and d > 0:
            if s[j] == '{':
                d += 1
            elif s[j] == '}':
                d -= 1
            j += 1
        body = s[body_start:j]
        if re.search(r'(?m)^[ \t]*(?:public |private |static |override |inline )*function\s+new\s*\(', body):
            return False
        ctor = '%spublic function new()%s' % (indent, ' { super(); } // CTORFIX' if has_ext else ' { } // CTORFIX')
        return s[:body_start] + '\n' + ctor + s[body_start:]
    return None


if __name__ == '__main__':
    for arg in sys.argv[1:]:
        f, c = arg.split('::')
        r = add_ctor(f, c)
        if r is None:
            print('NOT FOUND %s %s' % (f, c))
        elif r is False:
            print('HAS CTOR %s %s' % (f, c))
        else:
            io.open(f, 'w', encoding='utf-8', newline='').write(r)
            print('added ctor %s %s' % (f, c))
