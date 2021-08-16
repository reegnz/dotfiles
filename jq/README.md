# jq convenience functions


## Mapping from one casing to another
```
jq 'map_keys(from_camel|to_snake)'

Input: {
  "SecretKey": "aaaaa",
  "PublicKey": "bbbb",
  "TestData": [
    {
      "InputSource": "file"
    }
  ]
}

Output: {
  "secret_key": "aaaaa",
  "public_key": "bbbb",
  "test_data": [
    {
      "input_source": "file"
    }
  ]
}
```

Casings supported:

* camelCase - from_camel, to_camel
* PascalCase - from_pascal, to_pascal
* snake_case - from_snake, to_snake
* CONSTANT_CASE - from_constant, to_constant
* kebab-case - from_kebab, to_kebab
* HEADER-CASE - from_header, to_header
* dot.case - from_dot, to_dot
