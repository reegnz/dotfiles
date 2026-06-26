# gron.jq

A small [gron](https://github.com/tomnomnom/gron) written in jq. It flattens
JSON into one assignment per line and turns those lines back into JSON. I use it
when I want to filter JSON with ordinary line tools like `grep`, `awk`, or
`sort` and then get JSON back out the other end.

```
$ echo '{"kind":"List","items":[{"kind":"Pod"},{"kind":"Service"}]}' | gron.jq
.kind = "List";
.items[0].kind = "Pod";
.items[1].kind = "Service";
```

Every line stands on its own (`path = value;`), so you can grep, reorder, or
delete lines and `ungron.jq` will still rebuild valid JSON from whatever
survives.

## Install

It is part of the `gron-jq` stow package:

```
stow gron-jq
```

That symlinks `gron.jq` and `ungron.jq` into `~/.local/bin`, this README and the
test script into `~/.local/share/gron.jq`, and the man pages into
`~/.local/share/man/man1`. You need `jq` (tested with 1.8).

## Usage

Flatten, then reconstruct:

```
$ echo '{"a":{"b":[1,2]}}' | gron.jq
.a.b[0] = 1;
.a.b[1] = 2;

$ echo '{"a":{"b":[1,2]}}' | gron.jq | ungron.jq
{
  "a": {
    "b": [1, 2]
  }
}
```

Filter with shell, then rebuild. Here grep keeps only the `items` subtree:

```
$ echo '{"kind":"List","items":[{"kind":"Pod"}]}' \
    | gron.jq | grep '^\.items' | ungron.jq -c
{"items":[{"kind":"Pod"}]}
```

For a stream of documents, slurp them into an array on the way in with `jq -s`
and split them back out with `.[]`. That covers what gron calls `--stream`:

```
$ printf '{"a":1}\n{"a":2}\n' | jq -s -rf gron.jq | ungron.jq | jq -c '.[]'
{"a":1}
{"a":2}
```

Both scripts are executable. If you would rather spell out the jq flags, run
them as `jq -rf gron.jq` and `jq -nRf ungron.jq`.

## How it works

This is jq's `tostream` and `fromstream` written out as text.

`gron.jq` walks `paths(is_leaf)` and prints `path = value;` for each leaf. Those
are the same `(path, leaf)` records `tostream` produces, except the path is a jq
path expression rather than a JSON array. The document root has no path, so when
the whole input is itself a leaf (a scalar or an empty container) it is written
with a lone dot, as in `. = 42;`. On the way back, `.` parses to the empty path
`[]`, and `setpath([]; v)` replaces the whole value.

`ungron.jq` parses each line back into a jq path and folds the leaves together
with `reduce ... setpath`. It does not need the close markers that `fromstream`
relies on, and that is the whole reason line-by-line filtering survives a round
trip. It also skips blank lines and anything that is not an assignment, and
strips a trailing carriage return, so grep, awk, and sort can leave their usual
debris in the stream without breaking the result.

A leaf is a scalar or an empty container (`[]` or `{}`). gron.jq decides this by
type rather than truthiness on purpose. `paths(scalars)` quietly drops `false`
and `null` leaves because they are falsy, so `is_leaf` checks the type instead.

The path parser in `ungron.jq` understands quoting. Its grammar has three token
shapes: `.bareword`, `[123]`, and `["json string"]`. Because keys travel inside
that quoted form, a key containing `.`, `[`, `]`, `"`, or `=` comes back
unchanged.

## Limitations

gron.jq builds every path in memory before it prints anything, so it is a poor
fit for input larger than memory.

If you filter away every line under a container, and that container had no
empty-container line of its own, it will not be reconstructed.

`ungron.jq` reads the format `gron.jq` emits. It is not a general JavaScript
parser and it trusts its input to be well formed.

## Tests

```
$ ~/.local/share/gron.jq/test.sh
```

It round-trips a range of inputs, including awkward keys, empty containers,
`null`, `false`, and top-level arrays, plus the filtering and streaming examples
above. It exits non-zero if anything fails.

## See also

`gron.jq(1)`, `ungron.jq(1)`, jq's `tostream` and `fromstream`, and
[tomnomnom/gron](https://github.com/tomnomnom/gron).
