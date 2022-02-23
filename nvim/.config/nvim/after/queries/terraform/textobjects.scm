(
  (block (identifier) @type (body)? @locals.inner) @locals.outer
  (#match? @type "locals")
)

(
  (block (identifier) @type (body)? @data.inner) @data.outer
  (#match? @type "data")
)

(
  (block (identifier) @type (body)? @resource.inner) @resource.outer
  (#match? @type "resource")
)

(
  (block (identifier) @type (body)? @module.inner) @module.outer
  (#match? @type "module")
)
