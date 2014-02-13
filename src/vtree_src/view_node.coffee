ViewFactory = require('vtree')
ViewHooks = require('vtree/view_hooks')

class ViewNode

  viewNodeId = 1

  constructor: (@$el, viewHooks) ->
    @options = ViewFactory.options
    @viewHooks = viewHooks || new ViewHooks()

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
    @viewHooks.init(@)

  activate: ->
    return if @isActivated()

    @setAsActivated()
    @viewHooks.activate(@)

  remove: ->
    return if @isRemoved()

    @setAsRemoved()
    if @isActivated()
      @unload()

  unload: ->
    @viewHooks.unload(@)
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
