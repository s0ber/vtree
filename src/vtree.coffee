# TODO: at this moment complicated views factory only works with Modula,
# export to window is not supported

class Vtree

  VIEW_SELECTOR = '[data-view]'
  APP_SELECTOR = '[data-app]'

  @options:
    viewSelector: VIEW_SELECTOR
    appSelector: APP_SELECTOR

  @create: ->
    @initTreeManager()
    @initRemoveEvent()
    @initRefreshEvent()

    @createViewsTree()

  @initTreeManager: ->
    return if @isTreeManagerInitialized()
    @setTreeManagerAsInitialized()

    TreeManager = require('vtree/tree_manager')
    @treeManager = new TreeManager

  @createViewsTree: ->
    @treeManager.createTree()

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

    $('body').on 'refresh', '*' , (e) =>
      e.stopPropagation()

      # finding closest element with viewNode (it can be actually e.currentTarget)
      $elWithNode = $(e.currentTarget).closest(@viewSelector())
      nodeId = $elWithNode.data('view-node-id')

      # if current target don't have viewNode, searching for it's parent
      while $elWithNode.length and not nodeId
        $elWithNode = $elWithNode.parent().closest(@viewSelector())
        nodeId = $elWithNode.data('view-node-id')

      return unless nodeId

      node = @treeManager.nodesCache.getById(nodeId)
      @treeManager.refresh(node)


  # private

  @isTreeManagerInitialized: ->
    @_isTreeManagerInitialized ||= false

  @setTreeManagerAsInitialized: ->
    @_isTreeManagerInitialized = true

  @isRemoveEventInitialized: ->
    @_isRemoveEventInitialized ||= false

  @setRemoveEventAsInitialized: ->
    @_isRemoveEventInitialized = true

  @isRefreshEventInitialized: ->
    @_isRefreshEventInitialized ||= false

  @setRefreshEventAsInitialized: ->
    @_isRefreshEventInitialized = true

  @viewSelector: ->
    @_viewSelector ||= "#{@options.appSelector}, #{@options.viewSelector}"

modula.export('vtree', Vtree)
