Vtree = require('vtree')

class NodeWrapper

  layoutId = 0
  COMPONENT_PATTERN = /(.+)#(.+)/
  SECRET_KEY = 'semarf'

  constructor: (@node) ->
    @$el = @node.$el
    @el = @node.el

    layoutId++ if @isLayout()
    @identifyView()
    @initView()
    @initVtreeNode()

  identifyView: ->
    @layoutName = @layout().name
    @layoutId = @layout().id

    if @hasComponent()
      [@componentName, @viewName] = Vtree.config().extractComponentData(@$el)
    else
      @componentName = @layoutName
      @viewName = @viewUnderscoredName()

    @componentClassName = @componentName.camelize() + 'Component'
    @viewClassName = @viewName.camelize() + 'View'

  initView: ->
    viewName = "#{@componentClassName}.#{@viewClassName}"

    if ViewConstructor = window[@componentClassName]?[@viewClassName]
      @viewInstance = new ViewConstructor
        el: @el
        viewClassName: @viewClassName
        viewFullName: @viewName
        layoutId: @layoutId

    else
      # TODO: 'show errors'
      # Core.warn "Can find view class for '#{viewName}'"

  initVtreeNode: ->
    @vtreeNode = @createNode()
    @_hooks()?.init?(@vtreeNode)

  createNode: ->
    class VtreeNode
      init: ->
    new VtreeNode

  hasComponent: ->
    @_hasComponent ||= Vtree.config().hasComponent(@$el)

  layout: ->
    @_layout ||=
      if @isLayout()
        {name: @layoutUnderscoredName(), id: layoutId}
      else if @node.parent?
        @node.parent.nodeWrapper.layout()
      else
        {name: SECRET_KEY, id: 0}

  unload: ->
    delete @node


  # private

  isLayout: ->
    @_isLayout ?= Vtree.config().isLayout(@$el)

  layoutUnderscoredName: ->
    @_layoutUnderscoredName ?= Vtree.config().layoutUnderscoredName(@$el)

  viewUnderscoredName: ->
    @_viewUnderscoredName ?= Vtree.config().viewUnderscoredName(@$el)

  _hooks: ->
    # @options.hooks

modula.export('vtree/node_wrapper', NodeWrapper)
