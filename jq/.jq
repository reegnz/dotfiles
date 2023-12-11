def head($count):
  .[0:$count]|select(length > 0) |
  if type == "array" then .[] else . end;


def tail($count):
  .[$count:];


def head:
  head(1);


def tail:
  tail(1);


def capitalize:
  (head | ascii_upcase) + tail;


def from_kebab:
  split("-");


def to_kebab:
  join("-");


def from_snake:
  split("_");


def to_snake:
  join("_");


def from_pascal:
  [splits("(?=[A-Z])")] | map(select(. != "")) | map(ascii_downcase);


def to_pascal:
  map(capitalize) | join("");


def from_camel:
  from_pascal;


def to_camel:
  [ head ] + (tail | map(capitalize)) | join("");


def from_constant:
  from_snake | map(ascii_downcase);


def to_constant:
  map(ascii_upcase) | join("_");


def from_dot:
  split(".");


def to_dot:
  join(".");


def from_header:
  split("-") | map(ascii_downcase);


def to_header:
  map(capitalize) | join("-");

def to_manycase_regex:
  join("[ -_]*");


def map_keys(mapper):
  walk(
    if type == "object" then
      with_entries(.key |= mapper)
    else .
    end
  );

def map_files:
  reduce inputs as $line ({}; .[input_filename] += [$line]);

# usage: jq -r 'tsv_with_header' | column -t
def tsv_with_header:
  (.[0]|keys|map(ascii_upcase)) as $keys |
  $keys,(.[]|to_entries|map(.value)) |
  @tsv;

def flatten_object:
[
  leaf_paths as $path | {
    key: $path | join("_"), 
    value: getpath($path)
  }
]|from_entries;



def k8s_pods:
  .items |map({
    metadata
  }|
  .metadata |= {name, namespace} |
  .metadata
  );

def k8s_pod_annotations:
  .items|map(.metadata|{
    name,
    namespace,
    annotation: (.annotations|to_entries[]|(.key + "=" + .value))
  });

def k8s_images:
  [..|objects|.image|select(.)]|unique[];

def chunk($n):
  range(length/$n|ceil) as $i | .[$n*$i:$n*$i+5];
