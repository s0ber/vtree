Vtree = modula.require('vtree')
NodeData = require('./node_data')

class NodeWrapper

  componentId = 0
  SECRET_KEY = 'semarf'

  constructor: (@node, @config) ->
    @$el = @node.$el
    @el = @node.el

    componentId++ if @isComponentIndex()
    @identifyNodeAttributes()
    @initNodeDataObject()

  identifyNodeAttributes: ->
    if @isStandAlone()
      [@namespaceName, @nodeName] = @config.extractStandAloneNodeData(@$el)
    else
      @namespaceName = @component().namespace
      @nodeName =
        if @isComponentIndex()
          'index'
        else
          @nodeUnderscoredName()

  initNodeDataObject: ->
    @nodeData = @initNodeData()
    @_hooks()?.init?(@nodeData)

  initNodeData: ->
    namespaceNameUnderscored = @namespaceName
    namespaceName = @_camelize(@namespaceName)

    if @isStandAlone()
      componentNameUnderscored = null
      componentName = null
    else
      componentNameUnderscored = @component().name
      componentName = @_camelize(componentNameUnderscored)

    new NodeData({
      el: @el
      $el: @$el
      isStandAlone: @isStandAlone()
      isComponentIndex: @isComponentIndex()
      isComponentPart: not @isStandAlone()
      componentId: if @isStandAlone() then null else @component().id
      componentIndexNode: @componentIndexNode()?.nodeWrapper?.nodeData || null

      nodeName: @_camelize(@nodeName)
      nodeNameUnderscored: @nodeName

      componentName,
      componentNameUnderscored,
      namespaceName,
      namespaceNameUnderscored
    })

  unload: ->
    @_hooks()?.unload?(@nodeData)
    delete @nodeData
    delete @node

  isStandAlone: ->
    @_isStandAlone ?= @config.isStandAlone(@$el)

  component: ->
    @_component ?=
      if @isComponentIndex()
        [namespaceName, componentName] = @config.extractComponentIndexNodeData(@$el)
        {namespace: namespaceName, name: componentName, id: componentId, node: @node}
      else if @node.parent?
        @node.parent.nodeWrapper.component()
      else
        {namespace: SECRET_KEY, name: SECRET_KEY, id: 0, node: @node}


  componentIndexNode: ->
    @_componentIndexNode ?=
      if @isStandAlone() or @isComponentIndex()
        null
      else
        @component().node

  # private

  isComponentIndex: ->
    @_isComponentIndex ?= @config.isComponentIndex(@$el)

  nodeUnderscoredName: ->
    @_nodeUnderscoredName ?= @config.nodeUnderscoredName(@$el)

  _hooks: ->
    Vtree.hooks()

  _camelize: (string) ->
    string.replace /(?:^|[-_])(\w)/g, (_, c) ->
      if c then c.toUpperCase() else ''

modula.export('vtree/node_wrapper', NodeWrapper)
