$ = require 'jquery'
Configuration = require('./configuration')
DOM = require './vtree_src/dom'
Launcher = require './vtree_src/launcher'

module.exports = class Vtree
  @DOM: DOM

  @initNodes: ->
    @_launcher().launch(@config())
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
    for key, value of options
      @config()[key] = value

  @config: ->
    @_config ?= new Configuration

  @hooks: ->
    @_launcher().hooks()


  # private

  @_launcher: ->
    @__launcher ?= Launcher

window.Vtree = Vtree
