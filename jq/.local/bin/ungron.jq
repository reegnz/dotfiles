#!/usr/bin/env jq -n -R -f
# reverse of gron.jq, implements a subset of https://github.com/tomnomnom/gron

# split `.foo.bar[0]["key"]` into a jq path: numeric indices and quoted
# keys round-trip through fromjson, bare dot-keys stay strings.
def to_path:
  [splits("[][.]") | select(length > 0) | if test("^[0-9\"]") then fromjson else . end];

reduce inputs as $line (null;
  ($line | index(" = ")) as $i
  | setpath($line[:$i] | to_path; $line[$i+3:] | rtrimstr(";") | fromjson))
