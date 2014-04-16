class NodeData

  el: null
  $el: null

  isApplicationLayout: null
  isApplicationPart: null
  isComponentPart: null
  applicationId: null

  nodeName: null
  applicationName: null
  componentName: null

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
