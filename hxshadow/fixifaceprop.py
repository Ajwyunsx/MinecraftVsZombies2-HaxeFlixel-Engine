import io, os, re, sys


def read(p):
    return io.open(p, encoding='utf-8').read()


def write(p, s):
    io.open(p, 'w', encoding='utf-8', newline='').write(s)


def fix(path, field, apply=True, tag='IFACEFIX'):
    """Make `field` a (get, never) property backed by a private field."""
    s = read(path)
    lines = s.split('\n')
    decl_idx = None
    kind = None
    for i, l in enumerate(lines):
        if re.match(r'^\s*(?:override\s+)?public var ' + field + r'\((get|default)(,\s*(never|set|null))?\):', l) and l.strip().endswith(';'):
            decl_idx, kind = i, 'prop'
            break
        m = re.match(r'^(\s*)public var ' + field + r'\s*:\s*([^=;]+?)\s*(=\s*[^;]+)?;\s*$', l)
        if m:
            decl_idx, kind = i, 'field'
            break
    if decl_idx is None:
        return False
    indent = re.match(r'^(\s*)', lines[decl_idx]).group(1)
    backing = field[0].lower() + field[1:] + 'Field'
    if kind == 'prop':
        if re.search(r'(?m)^\s*(?:override\s+|inline\s+|public\s+|private\s+)*function get_' + field + r'\b', s):
            return False
        lines.insert(decl_idx + 1, '%sinline function get_%s() return %s; // %s' % (indent, field, backing, tag))
        body = '\n'.join(lines)
        if not re.search(r'(?m)^\s*private var ' + backing + r'\b', body):
            lines.insert(decl_idx + 2, '%sprivate var %s:Dynamic; // %s' % (indent, backing, tag))
        write(path, '\n'.join(lines))
        return True
    m = re.match(r'^(\s*)public var ' + field + r'\s*:\s*([^=;]+?)\s*(=\s*[^;]+)?;\s*$', lines[decl_idx])
    t = m.group(2).strip()
    init = (m.group(3) or '').strip()
    init = init[1:].strip() if init else ''
    new = ['%spublic var %s(get, never):%s;' % (indent, field, t),
           '%sinline function get_%s():%s return %s;' % (indent, field, t, backing),
           '%sprivate var %s:%s%s; // %s' % (indent, backing, t, (' = ' + init) if init else '', tag)]
    lines[decl_idx:decl_idx + 1] = new
    body = '\n'.join(lines)
    body = re.sub(r'\.' + field + r'\s*=(?!=)', '.' + backing + ' =', body)
    body = re.sub(r'(?<![\w\.])' + field + r'\s*=(?!=)', backing + ' =', body)
    if apply:
        write(path, body)
    return True


if __name__ == '__main__':
    for f in sys.argv[2:]:
        print(fix(sys.argv[1], f))
