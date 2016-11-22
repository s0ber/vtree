module.exports = class NodeData

  el: null
  $el: null

  isComponentIndex: null
  isComponentPart: null
  isStandAlone: null
  componentId: null

  componentIndexNode: null

  nodeName: null
  componentName: null
  namespaceName: null

  nodeNameUnderscored: null
  componentNameUnderscored: null
  namespaceNameUnderscored: null

  constructor: (options) ->
    for key, value of options
      @[key] = value
    @data = {}

  setData: (name, value) ->
    @data[name] = value

  getData: (name) ->
    @data[name]
