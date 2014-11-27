Vtree = modula.require('vtree')
TreeManager = modula.require('vtree/tree_manager')

class Launcher

  @launch: ->
    @initTreeManager()
    @initRemoveEvent()
    @initRefreshEvent()

  @initTreeManager: ->
    return if @isTreeManagerInitialized()
    @setTreeManagerAsInitialized()
    @treeManager = new TreeManager()

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

  @initRefreshEvent: ->
    return if @isRefreshEventInitialized()
    @setRefreshEventAsInitialized()

    refreshHandler = (e) =>
      e.stopPropagation()

      # finding closest element with node (it can be actually e.currentTarget)
      $elWithNode = $(e.currentTarget).closest(Vtree.config().selector)
      nodeId = $elWithNode.data('vtree-node-id')

      # if current target don't have node, searching for it's parent
      while $elWithNode.length and not nodeId
        $elWithNode = $elWithNode.parent().closest(Vtree.config().selector)
        nodeId = $elWithNode.data('vtree-node-id')

      return unless nodeId

      node = @treeManager.nodesCache.getById(nodeId)
      @treeManager.refresh(node)

    $('body').on 'refresh', refreshHandler
    $('body').on 'refresh', '*' , refreshHandler

  @createViewsTree: ->
    @treeManager.createTree()


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
