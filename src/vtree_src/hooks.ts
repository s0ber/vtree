import type Node from './node'

type Callback = (...args: any[]) => void

export default class Hooks {
  onInitCallbacks: Callback[]
  onActivationCallbacks: Callback[]
  onUnloadCallbacks: Callback[]

  constructor() {
    this.onInitCallbacks = []
    this.onActivationCallbacks = []
    this.onUnloadCallbacks = []
  }

  onInit(callback: Callback) {
    this.onInitCallbacks.push(callback)
  }

  init(...args: any[]) {
    this.onInitCallbacks.forEach(callback => callback(...args))
  }

  onActivation(callback: Callback) {
    this.onActivationCallbacks.push(callback)
  }

  activate(...args: any[]) {
    this.onActivationCallbacks.forEach(callback => callback(...args))
  }

  onUnload(callback: Callback) {
    this.onUnloadCallbacks.push(callback)
  }

  unload(...args: any[]) {
    this.onUnloadCallbacks.forEach(callback => callback(...args))
  }

  reset() {
    this.onInitCallbacks = []
    this.onActivationCallbacks = []
    this.onUnloadCallbacks = []
  }
}
