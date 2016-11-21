TreeManager = modula.require('vtree/tree_manager')
Hooks = require('./hooks')

class Launcher

  @launch: (config) ->
    @initTreeManager(config)
    @initRemoveEvent(config)
    @initRefreshEvent(config)

  @initTreeManager: (config) ->
    return if @isTreeManagerInitialized()
    @setTreeManagerAsInitialized()
    @treeManager = new TreeManager(config, @hooks())

  @initRemoveEvent: ->
    return if @isRemoveEventInitialized()
    @setRemoveEventAsInitialized()

    # Special event definition
    $.event.special.remove =
      remove: (handleObj) ->
        el = this
        e =
          type: 'remove'
          data: handleObj.data
          currentTarget: el

        handleObj.handler(e)

  @initRefreshEvent: (config) ->
    return if @isRefreshEventInitialized()
    @setRefreshEventAsInitialized()

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


  # private

  @isTreeManagerInitialized: ->
    @_isTreeManagerInitialized ?= false

  @setTreeManagerAsInitialized: ->
    @_isTreeManagerInitialized = true

  @isRemoveEventInitialized: ->
    @_isRemoveEventInitialized ?= false

  @setRemoveEventAsInitialized: ->
    @_isRemoveEventInitialized = true

  @isRefreshEventInitialized: ->
    @_isRefreshEventInitialized ?= false

  @setRefreshEventAsInitialized: ->
    @_isRefreshEventInitialized = true

modula.export('vtree/launcher', Launcher)
