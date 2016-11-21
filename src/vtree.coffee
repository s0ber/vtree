Configuration = require('./configuration')
DOM = require './vtree_src/dom'
Hooks = require('./vtree_src/hooks')

class Vtree
  @DOM: DOM

  @initNodes: ->
    @_launcher().launch()
    @_launcher().createViewsTree()

  @initNodesAsync: ->
    AsyncFn.addToCallQueue =>
      dfd = new $.Deferred()
      AsyncFn.setImmediate =>
        @initNodes()
        dfd.resolve()
      dfd.promise()

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
    @_hooks ?= new Hooks


  # private

  @_launcher: ->
    @__launcher ?= modula.require('vtree/launcher')

modula.export('vtree', Vtree)
window.Vtree = Vtree
