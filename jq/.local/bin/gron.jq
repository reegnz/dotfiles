#!/usr/bin/env jq -r -f
# implements a subset of https://github.com/tomnomnom/gron

# can only dot index strings that do not start with a number and only 
# contain alphanumeric characters and underscores.
def can_dot_index:
  strings|select(test("^[^0-9]"))|select(test("[^a-zA-Z0-9_]")|not);

def fix_key:
  "."+can_dot_index//"[" + (tojson) + "]";
 
paths(scalars) as $key | "\($key | map(fix_key)|join("")) = \(getpath($key)|tojson);"
