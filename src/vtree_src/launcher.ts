import $ from 'jquery'
import TreeManager from './tree_manager'
import Hooks from './hooks'
import type Config from '../configuration'
import type NodeData from './node_data'

export default class Launcher {
  hooks: Hooks<(nodeData: NodeData) => void> = new Hooks()
  treeManager: TreeManager
  isRefreshEventInitialized = false

  launch(config: Config) {
    this.treeManager = new TreeManager(config, this.hooks)
    this.initRemoveEvent()
    this.initRefreshEvent(config)
  }

  initRemoveEvent() {
    // Special event definition
    if ($.event.special.remove) return

    $.event.special.remove = {
      remove(handleObj) {
        const el = this
        const e = {
          type: 'remove',
          data: handleObj.data,
          currentTarget: el
        }

        // @ts-ignore
        return handleObj.handler(e)
      }
    }
  }

  initRefreshEvent(config: Config) {
    if (this.isRefreshEventInitialized) return
    this.isRefreshEventInitialized = true

    const refreshHandler = (e: JQuery.TriggeredEvent) => {
      e.stopPropagation()

      // finding closest element with node (it can be actually e.currentTarget)
      let $elWithNode = $(e.currentTarget).closest(config.selector)
      let nodeId = $elWithNode.data('vtree-node-id')

      // if current target don't have node, searching for it's parent
      while ($elWithNode.length && !nodeId) {
        $elWithNode = $elWithNode.parent().closest(config.selector)
        nodeId = $elWithNode.data('vtree-node-id')
      }

      if (!nodeId) return

      const node = this.treeManager.nodesCache.getById(nodeId)
      this.treeManager.refresh(node)
    }

    $('body').off('refresh') // dispose any existing handlers
    $('body').on('refresh', refreshHandler)
    $('body').on('refresh', '*' , refreshHandler)
  }

  createViewsTree() {
    this.treeManager.createTree()
  }
}
