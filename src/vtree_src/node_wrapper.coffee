Vtree = modula.require('vtree')
NodeData = modula.require('vtree/node_data')

class NodeWrapper

  componentId = 0
  SECRET_KEY = 'semarf'

  constructor: (@node) ->
    @$el = @node.$el
    @el = @node.el

    componentId++ if @isComponentIndex()
    @identifyNodeAttributes()
    @initNodeDataObject()

  identifyNodeAttributes: ->
    @componentName = @layout().name
    @componentId = @layout().id

    if @isStandAlone()
      [@namespaceName, @nodeName] = Vtree.config().extractComponentData(@$el)
    else
      @namespaceName = @componentName
      @nodeName = @nodeUnderscoredName()

  initNodeDataObject: ->
    @nodeData = @initNodeData()
    @_hooks()?.init?(@nodeData)

  initNodeData: ->
    if @isStandAlone()
      namespaceNameUnderscored = @namespaceName
      namespaceName = @_camelize(@namespaceName)
      applicationNameUnderscored = null
      applicationName = null
    else
      applicationNameUnderscored = @namespaceName
      applicationName = @_camelize(@namespaceName)
      namespaceNameUnderscored = null
      namespaceName = null

    new NodeData({
      el: @el
      $el: @$el
      isComponentIndex: @isComponentIndex()
      isComponentPart: not @isStandAlone()
      isStandAlone: @isStandAlone()
      componentId: if @isStandAlone() then null else @componentId
      applicationNode: @applicationNode()?.nodeWrapper?.nodeData || null

      nodeName: @_camelize(@nodeName)
      nodeNameUnderscored: @nodeName
      applicationName,
      applicationNameUnderscored,
      namespaceName,
      namespaceNameUnderscored
    })

  unload: ->
    @_hooks()?.unload?(@nodeData)
    delete @nodeData
    delete @node

  isStandAlone: ->
    @_isStandAlone ||= Vtree.config().isStandAlone(@$el)

  layout: ->
    @_layout ||=
      if @isComponentIndex()
        {name: @layoutUnderscoredName(), id: componentId, node: @node}
      else if @node.parent?
        @node.parent.nodeWrapper.layout()
      else
        {name: SECRET_KEY, id: 0}


  applicationNode: ->
    @_applicationNode ?=
      if @isStandAlone() or @isComponentIndex()
        null
      else
        @layout().node

  # private

  isComponentIndex: ->
    @_isComponentIndex ?= Vtree.config().isComponentIndex(@$el)

  layoutUnderscoredName: ->
    @_layoutUnderscoredName ?= Vtree.config().layoutUnderscoredName(@$el)

  nodeUnderscoredName: ->
    @_nodeUnderscoredName ?= Vtree.config().nodeUnderscoredName(@$el)

  _hooks: ->
    Vtree.hooks()

  _camelize: (string) ->
    string.replace /(?:^|[-_])(\w)/g, (_, c) ->
      if c then c.toUpperCase() else ''

modula.export('vtree/node_wrapper', NodeWrapper)
