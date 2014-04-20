Configuration = modula.require('vtree/configuration')

class Vtree

  @initNodes: ->
    @_launcher().launch()
    @_launcher().createViewsTree()

  @onNodeInit: (callback) ->
    @hooks().onInit(callback)

  @getInitCallbacks: ->
    @hooks().onInitCallbacks()

  @onNodeUnload: (callback) ->
    @hooks().onUnload(callback)

  @getUnloadCallbacks: ->
    @hooks().onUnloadCallbacks()

  @configure: (options) ->
    _.extend(@config(), options)

  @config: ->
    @_config ?= new Configuration

  @hooks: ->
    return @_hooks if @_hooks?
    Hooks = modula.require('vtree/hooks')
    @_hooks ?= new Hooks


  # private

  @_launcher: ->
    @__launcher ?= modula.require('vtree/launcher')

modula.export('vtree', Vtree)
window.Vtree = Vtree
