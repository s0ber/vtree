Launcher = require('vtree/launcher')
Hooks = require('vtree/hooks')

class Vtree

  hooks = new Hooks()

  @initNodes: ->
    @_launcher().launch(hooks)
    @_launcher().createViewsTree()

  @onNodeInit: (callback) ->
    hooks.onInit(callback)

  @getInitCallbacks: ->
    hooks.onInitCallbacks()

  @onNodeUnload: (callback) ->
    hooks.onUnload(callback)

  @getUnloadCallbacks: ->
    hooks.onUnloadCallbacks()


  # private

  @_launcher: ->
    Launcher

modula.export('vtree', Vtree)
