class NodeData

  el: null
  $el: null

  isComponentIndex: null
  isComponentPart: null
  isStandAlone: null
  componentId: null

  nodeName: null
  applicationName: null
  namespaceName: null

  nodeNameUnderscored: null
  applicationNameUnderscored: null
  componentNameUnderscored: null

  constructor: (options) ->
    _.extend(@, options)
    @data = {}

  setData: (name, value) ->
    @data[name] = value

  getData: (name) ->
    @data[name]

modula.export('vtree/node_data', NodeData)
