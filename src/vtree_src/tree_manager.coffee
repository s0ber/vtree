NodesCache = require('vtree/vtree_nodes_cache')
Node = require('vtree/node')
NodeWrapper = require('vtree/node_wrapper')
Hooks = require('vtree/hooks')

class TreeManager

  constructor: (@options) ->
    @options ?= {appSelector: '[data-app]', viewSelector: '[data-view]'}

    @initNodeHooks()

    @initialNodes = []
    @nodesCache = new NodesCache()

  initNodeHooks: ->
    @hooks = new Hooks
    @hooks.onInit @addNodeIdToElData.bind(@)
    @hooks.onInit @addRemoveEventHandlerToEl.bind(@)
    @hooks.onActivation @addNodeWrapper.bind(@)
    @hooks.onUnload @unloadView.bind(@)
    @hooks.onUnload @deleteNodeWrapper.bind(@)

  createTree: ->
    @setInitialNodes()
    @setParentsForInitialNodes()
    @setChildrenForInitialNodes()
    @activateInitialNodes()

  setInitialNodes: ->
    $els = $(@viewSelector())
    @initialNodes = []

    for i in [0...$els.length]
      node = new Node($els.eq(i), @hooks, @options)
      @nodesCache.add(node)
      @initialNodes.push(node)

  setParentsForInitialNodes: ->
    @setParentsForNodes(@initialNodes)

  setChildrenForInitialNodes: ->
    @setChildrenForNodes(@initialNodes)

  setParentsForNodes: (nodes) ->
    for node in nodes
      $parentEl = node.$el.parent().closest(@viewSelector())

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
    $els = refreshedNode.$el.find(@viewSelector())
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

  viewSelector: ->
    @_viewSelector ||= "#{@options.appSelector}, #{@options.viewSelector}"

  addNodeIdToElData: (node) ->
    node.$el.data('vtree-node-id', node.id)

  addRemoveEventHandlerToEl: (node) ->
    node.$el.on('remove', => @removeNode(node))

  addNodeWrapper: (node) ->
    node.nodeWrapper = new NodeWrapper(node, @options)

  unloadView: (node) ->
    node.nodeWrapper?.unload?()

  deleteNodeWrapper: (node) ->
    delete(node.nodeWrapper)

modula.export('vtree/tree_manager', TreeManager)
