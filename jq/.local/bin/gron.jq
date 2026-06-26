#!/usr/bin/env jq -r -f
# implements a subset of https://github.com/tomnomnom/gron

# can only dot index strings that do not start with a number and only 
# contain alphanumeric characters and underscores.
def can_dot_index:
  strings|select(test("^[^0-9]"))|select(test("[^a-zA-Z0-9_]")|not);

def fix_key:
  ( "."+can_dot_index ) // "[" + (tojson) + "]";

# leaves are scalars and empty containers. paths(f) keeps a node only when f
# is truthy, so paths(scalars) wrongly drops false/null values - match by type.
def is_leaf:
  type as $t | $t != "array" and $t != "object" or length == 0;

paths(is_leaf) as $key | "\($key | map(fix_key)|join("")) = \(getpath($key)|tojson);"
