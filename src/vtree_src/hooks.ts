type Callback = (...args: any[]) => void

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

  init(...args: any[]) {
    Array.from(this.onInitCallbacks).map((callback) => callback(...args))
  }

  onActivation(callback: Callback) {
    this.onActivationCallbacks.push(callback)
  }

  activate(...args: any[]) {
    Array.from(this.onActivationCallbacks).map((callback) => callback(...args))
  }

  onUnload(callback: Callback) {
    this.onUnloadCallbacks.push(callback)
  }

  unload(...args: any[]) {
    Array.from(this.onUnloadCallbacks).map((callback) => callback(...args))
  }

  reset() {
    this.onInitCallbacks = []
    this.onActivationCallbacks = []
    this.onUnloadCallbacks = []
  }
}
