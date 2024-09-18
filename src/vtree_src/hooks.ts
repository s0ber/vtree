import type Node from './node'

type Callback = (node: Node) => void

export default class Hooks {
  onInitCallbacks: Callback[]
  private onActivationCallbacks: Callback[]
  onUnloadCallbacks: Callback[]

  constructor() {
    this.onInitCallbacks = []
    this.onActivationCallbacks = []
    this.onUnloadCallbacks = []
  }

  onInit(callback: Callback) {
    this.onInitCallbacks.push(callback)
  }

  init(node: Node) {
    this.onInitCallbacks.forEach(callback => callback(node))
  }

  onActivation(callback: Callback) {
    this.onActivationCallbacks.push(callback)
  }

  activate(node: Node) {
    this.onActivationCallbacks.forEach(callback => callback(node))
  }

  onUnload(callback: Callback) {
    this.onUnloadCallbacks.push(callback)
  }

  unload(node: Node) {
    this.onUnloadCallbacks.forEach(callback => callback(node))
  }

  reset() {
    this.onInitCallbacks = []
    this.onActivationCallbacks = []
    this.onUnloadCallbacks = []
  }
}
