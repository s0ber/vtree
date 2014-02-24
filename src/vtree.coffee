VtreeLauncher = require('vtree/vtree_launcher')
ViewHooks = require('vtree/view_hooks')

class Vtree

  viewHooks = new ViewHooks()

  @initNodes: ->
    @_launcher().launch(viewHooks)
    @_launcher().createViewsTree()

  @onNodeInit: (callback) ->
    viewHooks.onInit(callback)

  @getInitCallbacks: ->
    viewHooks.onInitCallbacks()

  @onNodeUnload: (callback) ->
    viewHooks.onUnload(callback)

  @getUnloadCallbacks: ->
    viewHooks.onUnloadCallbacks()


  # private

  @_launcher: ->
    VtreeLauncher

modula.export('vtree', Vtree)
