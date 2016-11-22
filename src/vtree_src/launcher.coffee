TreeManager = require('./tree_manager')
Hooks = require('./hooks')

module.exports = class Launcher

  @launch: (config) ->
    @initTreeManager(config)
    @initRemoveEvent()
    @initRefreshEvent(config)

  @initTreeManager: (config) ->
    @treeManager = new TreeManager(config, @hooks())

  @initRemoveEvent: ->
    # Special event definition
    $.event.special.remove ?=
      remove: (handleObj) ->
        el = this
        e =
          type: 'remove'
          data: handleObj.data
          currentTarget: el

        handleObj.handler(e)

  @initRefreshEvent: (config) ->
    return if @isRefreshEventInitialized
    @isRefreshEventInitialized = true

    refreshHandler = (e) =>
      e.stopPropagation()

      # finding closest element with node (it can be actually e.currentTarget)
      $elWithNode = $(e.currentTarget).closest(config.selector)
      nodeId = $elWithNode.data('vtree-node-id')

      # if current target don't have node, searching for it's parent
      while $elWithNode.length and not nodeId
        $elWithNode = $elWithNode.parent().closest(config.selector)
        nodeId = $elWithNode.data('vtree-node-id')

      return unless nodeId

      node = @treeManager.nodesCache.getById(nodeId)
      @treeManager.refresh(node)

    $('body').on 'refresh', refreshHandler
    $('body').on 'refresh', '*' , refreshHandler

  @createViewsTree: ->
    @treeManager.createTree()

  @hooks: ->
    return @_hooks if @_hooks?
    @_hooks ?= new Hooks

modula.export('vtree/launcher', Launcher)
