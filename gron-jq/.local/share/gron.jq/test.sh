#!/usr/bin/env bash
# Tests for gron.jq / ungron.jq. Resolves the scripts relative to itself, so it
# works both in the repo and once stowed into ~/.local.
set -u

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
bin=$here/../../bin
gron()   { jq -rf  "$bin/gron.jq"   "$@"; }
ungron() { jq -nRf "$bin/ungron.jq" "$@"; }

pass=0
fail=0
ok()  { pass=$((pass + 1)); printf 'ok   %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf 'FAIL %s\n     want: %s\n     got:  %s\n' "$1" "$2" "$3"; }

# roundtrip NAME JSON -- assert ungron(gron(JSON)) matches JSON structurally.
roundtrip() {
  local want got
  want=$(printf '%s' "$2" | jq -cS .)
  got=$(printf '%s' "$2" | gron | ungron | jq -cS .)
  [ "$got" = "$want" ] && ok "$1" || bad "$1" "$want" "$got"
}

# ungron_eq NAME WANT GRON_TEXT -- feed raw gron text (printf escapes honoured)
# straight to ungron; assert the rebuilt JSON. Used for messy/handcrafted input.
ungron_eq() {
  local got
  got=$(printf "$3" | ungron | jq -cS .)
  [ "$got" = "$2" ] && ok "$1" || bad "$1" "$2" "$got"
}

echo '# structure'
roundtrip 'nested object and array' '{"kind":"List","items":[{"kind":"Pod"},{"kind":"Service"}]}'
roundtrip 'top-level array'         '[1, "two", {"k": [3, 4]}]'
roundtrip 'deeply nested arrays'    '[[1,[2,[3]]]]'
roundtrip 'empties, null, false'    '{"obj": {}, "arr": [], "n": null, "f": false}'
roundtrip 'nested empty containers' '{"a": {"b": {}}, "c": [[]]}'
roundtrip 'numbers'                 '{"i": 0, "f": 1.5, "neg": -0.25, "exp": 1e10}'

echo '# top-level leaves (the document root has no path)'
roundtrip 'top-level scalar'        '42'
roundtrip 'top-level string'        '"hi"'
roundtrip 'top-level null'          'null'
roundtrip 'top-level false'         'false'
roundtrip 'top-level empty object'  '{}'
roundtrip 'top-level empty array'   '[]'

echo '# keys that must be quoted'
roundtrip 'dot in key'              '{"a.b": 1}'
roundtrip 'brackets in key'         '{"c[0]": 2}'
roundtrip 'equals separator in key' '{"x = y": 3}'
roundtrip 'semicolon in key'        '{"a;b": 4}'
roundtrip 'space in key'            '{"foo bar": 5}'
roundtrip 'empty string key'        '{"": 6}'
roundtrip 'leading-digit key'       '{"1a": 7}'
roundtrip 'numeric string vs index' '{"0": "z", "items": [10, 20]}'
roundtrip 'identifier-shaped keys'  '{"_x": 1, "x9": 2}'

echo '# escaping inside keys and values'
roundtrip 'quote in key'            '{"a\"b": 1}'
roundtrip 'backslash in key'        '{"a\\b": 1}'
roundtrip 'backslash-quote in key'  '{"a\\\"b": 1}'
roundtrip 'newline in key'          '{"a\nb": 1}'
roundtrip 'backslash in value'      '{"path": "c:\\tmp"}'
roundtrip 'newline in value'        '{"a": "line1\nline2"}'
roundtrip 'empty string value'      '{"a": ""}'
roundtrip 'value mimics a statement' '{"a": ".b = c;"}'
roundtrip 'stringy null and number' '{"x": "null", "y": "123", "z": "true"}'
roundtrip 'multibyte value'         '{"a": "héllo 😀"}'

echo '# filtering and streaming workflows'
got=$(printf '%s' '{"kind":"List","items":[{"kind":"Pod"},{"kind":"Service"}]}' \
  | gron | grep '^\.items' | ungron | jq -cS .)
[ "$got" = '{"items":[{"kind":"Pod"},{"kind":"Service"}]}' ] \
  && ok 'grep keeps items subtree' \
  || bad 'grep keeps items subtree' '{"items":[{"kind":"Pod"},{"kind":"Service"}]}' "$got"

got=$(printf '{"a":1}\n{"a":2}\n' | jq -s -rf "$bin/gron.jq" | ungron | jq -c '.[]' | paste -sd' ' -)
[ "$got" = '{"a":1} {"a":2}' ] \
  && ok 'stream via slurp and .[]' \
  || bad 'stream via slurp and .[]' '{"a":1} {"a":2}' "$got"

echo '# ungron tolerates messy input from line tools'
ungron_eq 'blank line in the middle' '{"a":1,"b":2}' '.a = 1;\n\n.b = 2;\n'
ungron_eq 'trailing blank line'      '{"a":1,"b":2}' '.a = 1;\n.b = 2;\n\n'
ungron_eq 'non-assignment line'      '{"a":1}'       '# a note\n.a = 1;\n'
ungron_eq 'CRLF line endings'        '{"a":1,"b":2}' '.a = 1;\r\n.b = 2;\r\n'
ungron_eq 'reordered lines'          '{"a":[1,2]}'   '.a[1] = 2;\n.a[0] = 1;\n'

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
