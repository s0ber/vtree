modules = {}

window.modula ?=

  export: (name, exports) ->
    modules[name] = exports

  require: (name) ->
    Module = modules[name]
    if Module
      Module
    else
      throw("Module '#{name}' not found.")
