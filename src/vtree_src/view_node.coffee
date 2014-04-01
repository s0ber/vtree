VtreeHooks = require('vtree/vtree_hooks')

class ViewNode

  viewNodeId = 1

  constructor: (@$el, hooks, @options = {}) ->
    @hooks = hooks || new VtreeHooks()

    @el = @$el[0]
    @id = "viewNodeId#{viewNodeId}"
    @parent = null
    @children = []

    viewNodeId++

    @init()

  setParent: (viewNode) ->
    @parent = viewNode

  setChildren: (viewNodes) ->
    @children = _.filter(viewNodes, (node) =>
      node.parent and node.parent.el is @el
    )

  removeChild: (viewNode) ->
    return if _.indexOf(@children, viewNode) is -1
    @children = _.reject(@children, (childNode) -> childNode is viewNode)

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
    @_isActivated ||= false

  setAsRemoved: ->
    @_isRemoved = true

  isRemoved: ->
    @_isRemoved ||= false

modula.export('vtree/view_node', ViewNode)
