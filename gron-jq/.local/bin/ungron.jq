#!/usr/bin/env jq -n -R -f
# reverse of gron.jq, implements a subset of https://github.com/tomnomnom/gron

# gron path tokens, as regex fragments with one capture group each.
def dot_key:     "\\.([a-zA-Z_][a-zA-Z0-9_]*)";       # .bareword
def array_index: "\\[([0-9]+)\\]";                    # [123]
def quoted_key:  "\\[(\"(?:[^\"\\\\]|\\\\.)*\")\\]";   # ["json-encoded key"]

# any single path token. the quoted form matches \" and \\, so keys containing
# . [ ] " or even " = " survive intact.
def token: dot_key + "|" + array_index + "|" + quoted_key;

# a gron line is `<path> = <json>;`. the path is a run of tokens, so a " = "
# inside a quoted key stays in the path rather than splitting off the value. a
# lone "." is the document root: to_path gives [], and setpath([]; v) replaces
# the whole value.
def line_re: "^(?<key>(?:" + token + ")+|\\.) = (?<value>.+);$";

# parse a gron line into raw {key, value} strings. capture yields nothing for a
# line that is not an assignment, which doubles as a filter below.
def entry: capture(line_re);

# split a path string into a jq path. each token yields one capture: barewords
# stay strings, indices become numbers, quoted keys decode through fromjson so
# escapes and punctuation round-trip.
def to_path:
  [ scan(token)
    | if   .[0] != null then .[0]
      elif .[1] != null then (.[1] | tonumber)
      else                    (.[2] | fromjson)
      end ];

# strip a trailing CR (CRLF input) and drop blank or non-assignment lines, so
# reordering or filtering with line tools cannot collapse the result to null.
reduce (inputs | rtrimstr("\r") | entry) as $entry (null;
  setpath($entry.key | to_path; $entry.value | fromjson))
