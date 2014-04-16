modules = {}

Modula =

  export: (name, exports) ->
    modules[name] = exports

  require: (name) ->
    Module = modules[name]
    if Module
      Module
    else
      throw("Module '#{name}' not found.")

window.modula = Modula
window.require = Modula.require
