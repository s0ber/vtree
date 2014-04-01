Launcher = require('vtree/launcher')
VtreeHooks = require('vtree/vtree_hooks')

class Vtree

  hooks = new VtreeHooks()

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
