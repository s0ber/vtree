import $ from 'jquery'
import NodesCache from './vtree_nodes_cache'
import Node from './node'
import NodeWrapper from './node_wrapper'
import Hooks from './hooks'
import Config from '../configuration'

export default class TreeManager {
  isInitializing = false
  initialNodes: Node[] = []
  hooks = new Hooks()
  nodesCache = new NodesCache()

  constructor(public config: Config, public launcherHooks: Hooks) {
    this.hooks.onInit(this.addNodeIdToElData)
    this.hooks.onInit(node => this.addRemoveEventHandlerToEl(node))
    this.hooks.onActivation(node => this.addNodeWrapper(node))
    this.hooks.onUnload(this.unloadNode)
    this.hooks.onUnload(this.deleteNodeWrapper)
  }

  createTree() {
    this.isInitializing = true
    this.setInitialNodes()
    this.setParentsForInitialNodes()
    this.setChildrenForInitialNodes()
    this.activateInitialNodes()
    this.isInitializing = false
  }

  setInitialNodes() {
    const $els = $(this.config.selector)
    this.initialNodes = []

    for (let i of Array.from($els).keys()) {
      const node = new Node($els.eq(i), this.hooks)
      this.nodesCache.add(node)
      this.initialNodes.push(node)
    }
  }

  setParentsForInitialNodes() {
    this.setParentsForNodes(this.initialNodes)
  }

  setChildrenForInitialNodes() {
    this.setChildrenForNodes(this.initialNodes)
  }

  setParentsForNodes(nodes: Node[]) {
    for (let node of nodes) {
      const $parentEl = node.$el.parent().closest(this.config.selector)

      if ($parentEl.length) {
        // getting access to element node through cache
        const nodeId = $parentEl.data('vtree-node-id')
        node.parent = this.nodesCache.getById(nodeId)
      } else {
        this.nodesCache.addAsRoot(node)
      }
    }
  }

  setChildrenForNodes(nodes: Node[]) {
    if (!nodes.length) return
    const size = nodes.length

    for (let i of nodes.keys()) {
      const node = nodes[size - 1 - i] // iterate backwards

      node.parent?.prependChild(node)
    }
  }

  activateInitialNodes() {
    this.activateRootNodes()
  }

  activateRootNodes() {
    this.nodesCache.showRootNodes()
      .map(node => this.activateNode(node))
  }

  activateNode(node: Node) {
    node.activate()
    node.children.map(childNode => this.activateNode(childNode))
  }

  removeNode(node: Node) {
    if (node.isRemoved) return

    node.parent?.removeChild(node)

    this.removeChildNodes(node)
    node.remove()
    this.nodesCache.removeById(node.id)
  }

  removeChildNodes(node: Node) {
    for (let childNode of node.children) {
      this.removeChildNodes(childNode)
      childNode.remove()
      this.nodesCache.removeById(childNode.id)
    }
  }

  refresh(refreshedNode: Node) {
    if (this.isInitializing) {
      this.isInitializing = false
      throw new Error(`\
Vtree: You can't start initializing new nodes while current nodes are still initializing.
Please modify DOM asynchronously in such cases (use Vtree.DOM.htmlAsync, Vtree.DOM.appendAsync, etc).
This will guarantee that existing tree is completely initialized.\
`
      )
    }

    this.isInitializing = true
    const $els = refreshedNode.$el.find(this.config.selector)
    const newNodes = [refreshedNode]

    for (let i of Array.from($els).keys()) {
      const $el = $els.eq(i)
      let node: Node
      let nodeId = $el.data('vtree-node-id')

      // if el has link to node then node is initialized
      if (nodeId) {
        node = this.nodesCache.getById(nodeId)
      // else we need to initialize new node
      } else {
        node = new Node($el, this.hooks)
        this.nodesCache.add(node)
      }

      newNodes.push(node)
    }

    // destroy tree structure
    for (let node of newNodes) {
      node.children.length = 0
    }

    this.setParentsForNodes(newNodes)
    this.setChildrenForNodes(newNodes)
    this.activateNode(refreshedNode)
    this.isInitializing = false
  }

  addNodeIdToElData(node: Node) {
    node.$el.data('vtree-node-id', node.id)
  }

  addRemoveEventHandlerToEl(node: Node) {
    node.$el.on('remove', () => this.removeNode(node))
  }

  addNodeWrapper(node: Node) {
    node.nodeWrapper = new NodeWrapper(node, this.config, this.launcherHooks)
  }

  unloadNode(node: Node) {
    node.nodeWrapper?.unload()
  }

  deleteNodeWrapper(node: Node) {
    delete node.nodeWrapper
  }
}
