Vtree = modula.require('vtree')

NodesCache = modula.require('vtree/vtree_nodes_cache')
Node = modula.require('vtree/node')
NodeWrapper = modula.require('vtree/node_wrapper')
Hooks = modula.require('vtree/hooks')

class TreeManager

  constructor: ->
    @initNodeHooks()

    @initialNodes = []
    @nodesCache = new NodesCache()

  initNodeHooks: ->
    @hooks = new Hooks
    @hooks.onInit _.bind(@addNodeIdToElData, @)
    @hooks.onInit _.bind(@addRemoveEventHandlerToEl, @)
    @hooks.onActivation _.bind(@addNodeWrapper, @)
    @hooks.onUnload _.bind(@unloadView, @)
    @hooks.onUnload _.bind(@deleteNodeWrapper, @)

  createTree: ->
    @setInitialNodes()
    @setParentsForInitialNodes()
    @setChildrenForInitialNodes()
    @activateInitialNodes()

  setInitialNodes: ->
    $els = $(Vtree.config().selector)
    @initialNodes = []

    for i in [0...$els.length]
      node = new Node($els.eq(i), @hooks)
      @nodesCache.add(node)
      @initialNodes.push(node)

  setParentsForInitialNodes: ->
    @setParentsForNodes(@initialNodes)

  setChildrenForInitialNodes: ->
    @setChildrenForNodes(@initialNodes)

  setParentsForNodes: (nodes) ->
    for node in nodes
      $parentEl = node.$el.parent().closest(Vtree.config().selector)

      # element has no parent if not found (i.e. it is root element)
      if $parentEl.length is 0
        @nodesCache.addAsRoot(node)
      else
        # getting access to element node through cache
        nodeId = $parentEl.data('vtree-node-id')
        node.parent = @nodesCache.getById(nodeId)

  setChildrenForNodes: (nodes) ->
    return unless nodes.length

    node = nodes.shift()

    # setting child nodes for first node in list
    node.setChildren(nodes)

    # setting child nodes for remaining nodes
    @setChildrenForNodes(nodes)

  activateInitialNodes: ->
    @activateRootNodes(@initialNodes)

  activateRootNodes: (nodes) ->
    rootNodes = @nodesCache.showRootNodes()

    for node in rootNodes
      @activateNode(node)

  activateNode: (node) ->
    node.activate()

    for childNode in node.children
      @activateNode(childNode)

  removeNode: (node) ->
    return if node.isRemoved()

    if node.parent
      node.parent.removeChild(node)

    @removeChildNodes(node)
    node.remove()
    @nodesCache.removeById(node.id)

  removeChildNodes: (node) ->
    # we cloning children array, because it has dynamic length
    # and we need to iterate through every element
    tempChildren = _.clone(node.children)

    for childNode in tempChildren
      @removeChildNodes(childNode)
      childNode.remove()
      @nodesCache.removeById(childNode.id)

  refresh: (refreshedNode) ->
    $els = refreshedNode.$el.find(Vtree.config().selector)
    newNodes = [refreshedNode]

    for i in [0...$els.length]
      $el = $els.eq(i)

      # if el has link to node then node is initialized
      if nodeId = $el.data('vtree-node-id')
        node = @nodesCache.getById(nodeId)

      # else we need to initialize new node
      else
        node = new Node($els.eq(i), @hooks)
        @nodesCache.add(node)

      newNodes.push(node)

    @setParentsForNodes(newNodes)
    @setChildrenForNodes(newNodes)
    @activateNode(refreshedNode)

  addNodeIdToElData: (node) ->
    node.$el.data('vtree-node-id', node.id)

  addRemoveEventHandlerToEl: (node) ->
    node.$el.on('remove', => @removeNode(node))

  addNodeWrapper: (node) ->
    node.nodeWrapper = new NodeWrapper(node)

  unloadView: (node) ->
    node.nodeWrapper?.unload?()

  deleteNodeWrapper: (node) ->
    delete(node.nodeWrapper)

modula.export('vtree/tree_manager', TreeManager)
