def is_simple_key:
  type == "string" and test("^[a-zA-Z_][a-zA-Z0-9_-]*$");

def format_key:
  if is_simple_key then . else tojson end;

def indent(level):
  split("\n") | map(" " * level + .) | join("\n");

def to_kyaml:
  if type == "object" and length > 0 then
    [ to_entries[] | "\( .key | format_key ): \( .value | to_kyaml )," ]
    | join("\n")
    | indent(2)
    | "{\n\(.)\n}"

  elif type == "array" and length > 0 then
    [ .[] | "\( . | to_kyaml )," ]
    | join("\n")
    | indent(2)
    | "[\n\(.)\n]"

  else
    tojson
  end;

"---", to_kyaml
