"""miniyaml — a small, dependency-free YAML *subset* parser.

The course tooling must run with the Python 3 standard library only, so it
cannot rely on PyYAML. All YAML files in this repository are written in the
subset below (CONTRIBUTING.md documents it, tests/test_course_yaml.py
cross-checks against PyYAML when it happens to be installed).

Supported:
  * block mappings            key: value  /  key:\\n  <indented block>
  * block sequences           - item  /  - key: value (mapping items)
  * flow collections          {a: 1, b: [x, y]}  and  [a, {b: c}]
  * scalars                   plain, 'single', "double" (with escapes),
                              int, float, true/false, null/~
  * block scalars             |, |-, |+, >, >-, >+
  * comments                  # ... (outside quotes)
  * a single document; a leading '---' line is ignored

Not supported: anchors/aliases, tags, multi-document streams, complex keys,
multi-line flow collections, multi-line plain scalars.
"""

import re

__all__ = ["load", "loads", "YAMLError"]


class YAMLError(ValueError):
    pass


_INT = re.compile(r"^[-+]?(0|[1-9][0-9]*)$")
_FLOAT = re.compile(r"^[-+]?([0-9]+\.[0-9]*|\.[0-9]+)([eE][-+]?[0-9]+)?$")


def _strip_comment(line):
    """Remove a trailing comment that is not inside quotes."""
    out = []
    quote = None
    i = 0
    while i < len(line):
        ch = line[i]
        if quote:
            out.append(ch)
            if quote == '"' and ch == "\\" and i + 1 < len(line):
                out.append(line[i + 1])
                i += 2
                continue
            if ch == quote:
                if quote == "'" and i + 1 < len(line) and line[i + 1] == "'":
                    out.append("'")
                    i += 2
                    continue
                quote = None
        else:
            if ch in "\"'" and (not out or out[-1] in " \t:[{,-" or "".join(out).strip() == ""):
                quote = ch
            elif ch == "#" and (not out or out[-1] in " \t"):
                break
            out.append(ch)
        i += 1
    return "".join(out).rstrip()


def _scalar(tok):
    tok = tok.strip()
    if tok == "":
        return None
    if tok[0] == '"':
        if len(tok) < 2 or tok[-1] != '"':
            raise YAMLError("unterminated double-quoted string: %r" % tok)
        body = tok[1:-1]
        return (body.encode("utf-8").decode("unicode_escape").encode("latin-1").decode("utf-8")
                if "\\" in body else body)
    if tok[0] == "'":
        if len(tok) < 2 or tok[-1] != "'":
            raise YAMLError("unterminated single-quoted string: %r" % tok)
        return tok[1:-1].replace("''", "'")
    low = tok.lower()
    if low in ("null", "~"):
        return None
    if low == "true":
        return True
    if low == "false":
        return False
    if _INT.match(tok):
        return int(tok)
    if _FLOAT.match(tok):
        return float(tok)
    return tok


class _Flow:
    """Parser for one-line flow collections."""

    def __init__(self, text):
        self.s = text
        self.i = 0

    def ws(self):
        while self.i < len(self.s) and self.s[self.i] in " \t":
            self.i += 1

    def parse(self):
        self.ws()
        v = self.value()
        self.ws()
        if self.i != len(self.s):
            raise YAMLError("unexpected text after flow value: %r" % self.s[self.i:])
        return v

    def value(self):
        self.ws()
        if self.i >= len(self.s):
            return None
        ch = self.s[self.i]
        if ch == "{":
            return self.mapping()
        if ch == "[":
            return self.sequence()
        return self.atom(stops=",]}")

    def atom(self, stops):
        self.ws()
        start = self.i
        if self.i < len(self.s) and self.s[self.i] in "\"'":
            q = self.s[self.i]
            self.i += 1
            while self.i < len(self.s):
                c = self.s[self.i]
                if q == '"' and c == "\\":
                    self.i += 2
                    continue
                if c == q:
                    if q == "'" and self.s[self.i + 1:self.i + 2] == "'":
                        self.i += 2
                        continue
                    self.i += 1
                    break
                self.i += 1
            return _scalar(self.s[start:self.i])
        while self.i < len(self.s) and self.s[self.i] not in stops:
            if self.s[self.i] == ":" and ":" in stops:
                break
            self.i += 1
        return _scalar(self.s[start:self.i])

    def expect(self, ch):
        self.ws()
        if self.i >= len(self.s) or self.s[self.i] != ch:
            raise YAMLError("expected %r in flow collection %r" % (ch, self.s))
        self.i += 1

    def mapping(self):
        self.expect("{")
        out = {}
        self.ws()
        if self.s[self.i:self.i + 1] == "}":
            self.i += 1
            return out
        while True:
            key = self.atom(stops=":,}")
            self.ws()
            if self.s[self.i:self.i + 1] == ":":
                self.i += 1
                val = self.value()
            else:
                val = None
            out[key] = val
            self.ws()
            if self.s[self.i:self.i + 1] == ",":
                self.i += 1
                continue
            self.expect("}")
            return out

    def sequence(self):
        self.expect("[")
        out = []
        self.ws()
        if self.s[self.i:self.i + 1] == "]":
            self.i += 1
            return out
        while True:
            out.append(self.value())
            self.ws()
            if self.s[self.i:self.i + 1] == ",":
                self.i += 1
                continue
            self.expect("]")
            return out


def _value(tok):
    tok = tok.strip()
    if tok.startswith("{") or tok.startswith("["):
        return _Flow(tok).parse()
    return _scalar(tok)


_KEY = re.compile(r"""^("(?:[^"\\]|\\.)*"|'(?:[^']|'')*'|[^\s#'"{}\[\],&*!|>%@`][^:]*?)\s*:(\s+|$)(.*)$""")


class _Parser:
    def __init__(self, text):
        self.raw = text.splitlines()
        self.lines = []  # (lineno, indent, content)
        for n, line in enumerate(self.raw):
            if "\t" in line[: len(line) - len(line.lstrip())]:
                raise YAMLError("line %d: tabs are not allowed for indentation" % (n + 1))
            stripped = _strip_comment(line)
            if stripped.strip() == "" or stripped.strip() == "---" and not self.lines:
                self.lines.append((n, None, None))
                continue
            ind = len(stripped) - len(stripped.lstrip(" "))
            self.lines.append((n, ind, stripped.strip()))
        self.pos = 0

    def peek(self):
        while self.pos < len(self.lines) and self.lines[self.pos][1] is None:
            self.pos += 1
        if self.pos >= len(self.lines):
            return None
        return self.lines[self.pos]

    def parse(self):
        first = self.peek()
        if first is None:
            return None
        val = self.block(first[1])
        rest = self.peek()
        if rest is not None:
            raise YAMLError("line %d: unexpected content (bad indentation?)" % (rest[0] + 1))
        return val

    def block(self, indent):
        line = self.peek()
        if line is None:
            return None
        if line[2].startswith("- ") or line[2] == "-":
            return self.seq(indent)
        return self.mapping(indent)

    def block_scalar(self, header, parent_indent):
        style = header[0]
        chomp = header[1:2]
        out = []
        block_indent = None
        while self.pos < len(self.lines):
            n = self.lines[self.pos][0]
            raw = self.raw[n]
            if raw.strip() == "":
                out.append("")
                self.pos += 1
                continue
            ind = len(raw) - len(raw.lstrip(" "))
            if ind <= parent_indent:
                break
            if block_indent is None:
                block_indent = ind
            if ind < block_indent:
                break
            out.append(raw[block_indent:])
            self.pos += 1
        # trailing blank lines
        trailing = 0
        while out and out[-1] == "":
            out.pop()
            trailing += 1
        if style == "|":
            text = "\n".join(out)
        else:
            # folded: single newlines become spaces, blank lines become newlines
            text = ""
            prev_blank = True
            for ln in out:
                if ln == "":
                    text += "\n"
                    prev_blank = True
                elif ln.startswith(" "):
                    text += ("" if prev_blank else "\n") + ln
                    prev_blank = False
                else:
                    text += ("" if prev_blank else " ") + ln
                    prev_blank = False
        if chomp == "-":
            return text
        if chomp == "+":
            return text + "\n" * (trailing + 1)
        return text + "\n" if text else ""

    def inline_value(self, rest, indent, lineno):
        rest = rest.strip()
        if rest in ("|", "|-", "|+", ">", ">-", ">+"):
            return self.block_scalar(rest, indent)
        if rest == "":
            nxt = self.peek()
            if nxt is None or nxt[1] < indent or (nxt[1] == indent and not nxt[2].startswith("-")):
                return None
            if nxt[1] == indent and nxt[2].startswith("-"):
                return self.seq(indent)
            return self.block(nxt[1])
        try:
            return _value(rest)
        except YAMLError as e:
            raise YAMLError("line %d: %s" % (lineno + 1, e))

    def mapping(self, indent):
        out = {}
        while True:
            line = self.peek()
            if line is None or line[1] < indent:
                return out
            n, ind, content = line
            if ind > indent:
                raise YAMLError("line %d: unexpected indentation" % (n + 1))
            if content.startswith("- "):
                return out
            m = _KEY.match(content)
            if not m:
                raise YAMLError("line %d: expected 'key: value', got %r" % (n + 1, content))
            key = _scalar(m.group(1))
            self.pos += 1
            if key in out:
                raise YAMLError("line %d: duplicate key %r" % (n + 1, key))
            out[key] = self.inline_value(m.group(3), indent, n)

    def seq(self, indent):
        out = []
        while True:
            line = self.peek()
            if line is None or line[1] < indent:
                return out
            n, ind, content = line
            if ind > indent:
                raise YAMLError("line %d: unexpected indentation" % (n + 1))
            if not (content.startswith("- ") or content == "-"):
                return out
            item = content[1:].lstrip(" ")
            item_indent = ind + (len(content) - len(item))
            self.pos += 1
            if item == "":
                nxt = self.peek()
                out.append(self.block(nxt[1]) if nxt and nxt[1] > indent else None)
                continue
            m = _KEY.match(item) if not item.startswith(("{", "[", '"', "'")) else None
            if m:
                # mapping inside a sequence item: treat first key as a line at item_indent
                self.pos -= 1
                self.lines[self.pos] = (n, item_indent, item)
                out.append(self.mapping(item_indent))
            elif item.startswith("- "):
                self.pos -= 1
                self.lines[self.pos] = (n, item_indent, item)
                out.append(self.seq(item_indent))
            else:
                out.append(self.inline_value(item, indent, n))


def loads(text):
    return _Parser(text).parse()


def load(path):
    with open(path, encoding="utf-8") as fh:
        return loads(fh.read())
