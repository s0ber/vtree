Hooks = modula.require('vtree/hooks')

class Node

  nodeId = 1

  constructor: (@$el, hooks) ->
    @hooks = hooks || new Hooks()

    @el = @$el[0]
    @id = "nodeId#{nodeId}"
    @parent = null
    @children = []

    nodeId++

    @init()

  setParent: (node) ->
    @parent = node

  setChildren: (nodes) ->
    @children = []
    for node in nodes
      @children.push(node) if node.parent is @
    @children

  removeChild: (node) ->
    return if (nodeIndex = _.indexOf(@children, node)) is -1
    @children.splice(nodeIndex, 1)

  init: ->
    @hooks.init(@)

  activate: ->
    return if @isActivated()

    @setAsActivated()
    @hooks.activate(@)

  remove: ->
    return if @isRemoved()

    @setAsRemoved()
    if @isActivated()
      @unload()

  unload: ->
    @hooks.unload(@)
    @setAsNotActivated()


  # private

  setAsActivated: ->
    @_isActivated = true

  setAsNotActivated: ->
    @_isActivated = false

  isActivated: ->
    @_isActivated ?= false

  setAsRemoved: ->
    @_isRemoved = true

  isRemoved: ->
    @_isRemoved ?= false

modula.export('vtree/node', Node)
