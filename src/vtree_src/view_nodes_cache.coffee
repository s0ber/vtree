class ViewNodesCache

  constructor: (@nodes = {}, @rootNodes = []) ->

  show: ->
    @nodes

  showRootNodes: ->
    @rootNodes

  add: (node) ->
    @nodes[node.id] = node

  addAsRoot: (node) ->
    @rootNodes.push(node)

  getById: (id) ->
    @nodes[id]

  removeById: (id) ->
    delete @nodes[id]
    @rootNodes = _.reject(@rootNodes, (node) -> node.id is id)

  clear: ->
    @nodes = {}
    @rootNodes = []

modula.export('vtree/view_nodes_cache', ViewNodesCache)
