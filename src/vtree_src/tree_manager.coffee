Vtree = require('vtree')
NodesCache = require('vtree/nodes_cache')

class TreeManager

  constructor: ->
    @options = Vtree.options

    # TODO: add ability to set order for library sources
    # (I haven't find a way of doing this)
    @ViewNode = require('vtree/view_node')
    @ViewWrapper = require('vtree/view_wrapper')
    @initViewHooks()

    @initialNodes = []
    @nodesCache = new NodesCache()

  initViewHooks: ->
    ViewHooks = require('vtree/view_hooks')
    @viewHooks = new ViewHooks
    @viewHooks.onInit @addViewNodeIdToElData.bind(@)
    @viewHooks.onInit @addRemoveEventHandlerToEl.bind(@)
    @viewHooks.onActivation @initView.bind(@)
    @viewHooks.onUnload @unloadView.bind(@)

  createTree: ->
    @setInitialNodes()
    @setParentsForInitialNodes()
    @setChildrenForInitialNodes()
    @activateInitialNodes()

  setInitialNodes: ->
    $els = $(@viewSelector())

    @initialNodes = []

    for i in [0...$els.length]
      node = new @ViewNode($els.eq(i), @viewHooks)
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
        # getting access to element viewNode through cache
        nodeId = $parentEl.data('view-node-id')
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

      # if el has link to viewNode then viewNode is initialized
      if nodeId = $el.data('view-node-id')
        node = @nodesCache.getById(nodeId)

      # else we need to initialize new viewNode
      else
        node = new @ViewNode($els.eq(i), @viewHooks)
        @nodesCache.add(node)

      newNodes.push(node)

    @setParentsForNodes(newNodes)
    @setChildrenForNodes(newNodes)
    @activateNode(refreshedNode)

  viewSelector: ->
    @_viewSelector ||= "#{@options.appSelector}, #{@options.viewSelector}"

  addViewNodeIdToElData: (viewNode) ->
    viewNode.$el.data('view-node-id', viewNode.id)

  addRemoveEventHandlerToEl: (viewNode) ->
    viewNode.$el.on('remove', => @removeNode(viewNode))

  initView: (viewNode) ->
    viewNode.viewWrapper = new @ViewWrapper(viewNode)

  unloadView: (viewNode) ->
    viewNode.viewWrapper?.unload?()

modula.export('vtree/tree_manager', TreeManager)
