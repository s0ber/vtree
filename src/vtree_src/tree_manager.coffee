$ = require 'jquery'
NodesCache = require('./vtree_nodes_cache')
Node = require('./node')
NodeWrapper = require('./node_wrapper')
Hooks = require('./hooks')

module.exports = class TreeManager

  constructor: (@config, @launcherHooks) ->
    throw new Error('Config is required') unless @config?
    throw new Error('Launcher hooks are required') unless @launcherHooks?
    @initNodeHooks()

    @isInitializing = false
    @initialNodes = []
    @nodesCache = new NodesCache()

  initNodeHooks: ->
    @hooks = new Hooks
    @hooks.onInit @addNodeIdToElData
    @hooks.onInit (node) => @addRemoveEventHandlerToEl(node)
    @hooks.onActivation (node) => @addNodeWrapper(node)
    @hooks.onUnload @unloadNode
    @hooks.onUnload @deleteNodeWrapper

  createTree: ->
    @isInitializing = true
    @setInitialNodes()
    @setParentsForInitialNodes()
    @setChildrenForInitialNodes()
    @activateInitialNodes()
    @isInitializing = false

  setInitialNodes: ->
    $els = $(@config.selector)
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
      $parentEl = node.$el.parent().closest(@config.selector)

      # element has no parent if not found (i.e. it is root element)
      if $parentEl.length is 0
        @nodesCache.addAsRoot(node)
      else
        # getting access to element node through cache
        nodeId = $parentEl.data('vtree-node-id')
        node.parent = @nodesCache.getById(nodeId)

  setChildrenForNodes: (nodes) ->
    return unless nodes.length

    for i in [(nodes.length - 1)..0]
      node = nodes[i]
      node.parent?.prependChild(node)

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
    for childNode in node.children
      @removeChildNodes(childNode)
      childNode.remove()
      @nodesCache.removeById(childNode.id)

  refresh: (refreshedNode) ->
    if @isInitializing
      throw new Error '''
        Vtree: You can't start initializing new nodes while current nodes are still initializing.
        Please modify DOM asynchronously in such cases (use Vtree.DOM.htmlAsync, Vtree.DOM.appendAsync, etc).
        This will guarantee that existing tree is completely initialized.
      '''

    @isInitializing = true
    $els = refreshedNode.$el.find(@config.selector)
    newNodes = [refreshedNode]

    for i in [0...$els.length]
      $el = $els.eq(i)

      # if el has link to node then node is initialized
      if nodeId = $el.data('vtree-node-id')
        node = @nodesCache.getById(nodeId)

      # else we need to initialize new node
      else
        node = new Node($el, @hooks)
        @nodesCache.add(node)

      newNodes.push(node)

    # destroy tree structure
    for node in newNodes
      node.children.length = 0

    @setParentsForNodes(newNodes)
    @setChildrenForNodes(newNodes)
    @activateNode(refreshedNode)
    @isInitializing = false

  addNodeIdToElData: (node) ->
    node.$el.data('vtree-node-id', node.id)

  addRemoveEventHandlerToEl: (node) ->
    node.$el.on('remove', => @removeNode(node))

  addNodeWrapper: (node) ->
    node.nodeWrapper = new NodeWrapper(node, @config, @launcherHooks)

  unloadNode: (node) ->
    node.nodeWrapper?.unload?()

  deleteNodeWrapper: (node) ->
    delete(node.nodeWrapper)
