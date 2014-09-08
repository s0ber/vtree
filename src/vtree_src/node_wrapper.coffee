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
    if @isStandAlone()
      [@namespaceName, @nodeName] = Vtree.config().extractComponentData(@$el)
    else
      @namespaceName = @component().name
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
      componentId: if @isStandAlone() then null else @component().id
      componentIndexNode: @componentIndexNode()?.nodeWrapper?.nodeData || null

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

  component: ->
    @_component ||=
      if @isComponentIndex()
        {name: @componentUnderscoredName(), id: componentId, node: @node}
      else if @node.parent?
        @node.parent.nodeWrapper.component()
      else
        {name: SECRET_KEY, id: 0}


  componentIndexNode: ->
    @_componentIndexNode ?=
      if @isStandAlone() or @isComponentIndex()
        null
      else
        @component().node

  # private

  isComponentIndex: ->
    @_isComponentIndex ?= Vtree.config().isComponentIndex(@$el)

  componentUnderscoredName: ->
    @_componentUnderscoredName ?= Vtree.config().componentUnderscoredName(@$el)

  nodeUnderscoredName: ->
    @_nodeUnderscoredName ?= Vtree.config().nodeUnderscoredName(@$el)

  _hooks: ->
    Vtree.hooks()

  _camelize: (string) ->
    string.replace /(?:^|[-_])(\w)/g, (_, c) ->
      if c then c.toUpperCase() else ''

modula.export('vtree/node_wrapper', NodeWrapper)
