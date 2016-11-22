module.exports = class VtreeNodesCache

  constructor: (@nodes = {}, @rootNodes = []) ->

  show: ->
    @nodes

  showRootNodes: ->
    @rootNodes

  add: (node) ->
    @nodes[node.id] = node

  addAsRoot: (node) ->
    unless @nodes[node.id]?
      throw new Error('Trying to add node as root, but node is not cached previously')
    @rootNodes.push(node)

  getById: (id) ->
    @nodes[id]

  removeById: (id) ->
    if (nodeIndex = @rootNodes.indexOf(@nodes[id])) isnt -1
      @rootNodes.splice(nodeIndex, 1)
    delete @nodes[id]

  clear: ->
    @nodes = {}
    @rootNodes = []
