class ViewWrapper

  layoutId = 0
  COMPONENT_PATTERN = /(.+)#(.+)/
  SECRET_KEY = 'semarf'

  constructor: (@viewNode, @options = {}) ->
    @$el = @viewNode.$el
    @el = @viewNode.el

    layoutId++ if @isLayout()
    @identifyView()
    @initView()
    @initVtreeNode()

  identifyView: ->
    @layoutName = @layout().name
    @layoutId = @layout().id

    if @hasComponent()
      [__, @componentName, @viewName] = @viewDataValue().match(COMPONENT_PATTERN)
    else
      [@componentName, @viewName] = [@layoutName, @viewDataValue()]

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
    @node = @createNode()
    @hooks()?.init?(@node)

  createNode: ->
    class VtreeNode
      init: ->
    new VtreeNode

  isLayout: ->
    @_isLayout ||= @$el.data('app')?

  viewDataValue: ->
    @_viewDataValue ||=
      if not @isLayout()
        @$el.data('view') || SECRET_KEY
      else
        'layout'

  hasComponent: ->
    @_hasComponent ||= COMPONENT_PATTERN.test(@viewDataValue())

  layout: ->
    @_layout ||=
      if @isLayout()
        {name: @$el.data('app'), id: layoutId}
      else if @viewNode.parent?
        @viewNode.parent.viewWrapper.layout()
      else
        {name: SECRET_KEY, id: 0}

  unload: ->
    delete @viewNode

  hooks: ->
    @options.hooks

modula.export('vtree/view_wrapper', ViewWrapper)
