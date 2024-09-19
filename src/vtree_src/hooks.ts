type Callback = (...args: any[]) => void

export default class Hooks<C extends Callback> {
  onInitCallbacks: C[]
  onActivationCallbacks: C[]
  onUnloadCallbacks: C[]

  constructor() {
    this.onInitCallbacks = []
    this.onActivationCallbacks = []
    this.onUnloadCallbacks = []
  }

  onInit(callback: C) {
    this.onInitCallbacks.push(callback)
  }

  init(...args: any[]) {
    this.onInitCallbacks.forEach(callback => callback(...args))
  }

  onActivation(callback: C) {
    this.onActivationCallbacks.push(callback)
  }

  activate(...args: any[]) {
    this.onActivationCallbacks.forEach(callback => callback(...args))
  }

  onUnload(callback: C) {
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
