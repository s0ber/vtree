import Hooks from './hooks'
import type NodeWrapper from './node_wrapper'

let nodeId = 1

export default class Node {
  el: HTMLElement
  id: string
  parent?: Node
  children: Node[]
  private isActivated = false
  isRemoved = false

  nodeWrapper?: NodeWrapper

  constructor(public $el: JQuery, public hooks = new Hooks()) {
    this.el = this.$el[0]
    this.id = `nodeId${nodeId}`
    this.parent = null
    this.children = []

    nodeId++

    this.init()
  }

  setParent(node: Node) {
    this.parent = node
  }

  prependChild(node: Node) {
    this.children.unshift(node)
  }

  appendChild(node: Node) {
    this.children.push(node)
  }

  removeChild(node: Node) {
    let nodeIndex = this.children.indexOf(node)
    if (nodeIndex === -1) return

    this.children.splice(nodeIndex, 1)
  }

  init() {
    this.hooks.init(this)
  }

  activate() {
    if (this.isActivated) return
    this.isActivated = true

    this.hooks.activate(this)
  }

  remove() {
    if (this.isRemoved) return
    this.isRemoved = true

    if (this.isActivated) {
      this.unload()
    }
  }

  unload() {
    this.hooks.unload(this)
    this.isActivated = false
  }
}
