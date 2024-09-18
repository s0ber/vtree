import Configuration from './configuration'
import DOM from './vtree_src/dom'
import Launcher from './vtree_src/launcher'
import addToAsyncQueue from 'async_fn'

export default class Vtree {
  static _launcher: Launcher
  static _config: Configuration
  static DOM = DOM

  static initNodes() {
    this.launcher.launch(this.config)
    this.launcher.createViewsTree()
  }

  static initNodesAsync() {
    addToAsyncQueue(() =>
      new Promise<void>(resolve => {
        requestAnimationFrame(() => {
          this.initNodes()
          resolve()
        })
      }))
  }

  static onNodeInit(callback: () => void) {
    return this.hooks.onInit(callback)
  }

  static getInitCallbacks() {
    return this.hooks.onInitCallbacks
  }

  static onNodeUnload(callback: () => void) {
    return this.hooks.onUnload(callback)
  }

  static getUnloadCallbacks() {
    return this.hooks.onUnloadCallbacks
  }

  static configure(options: Partial<Configuration>) {
    for (let key in options) {
      const value = options[key]
      this.config[key] = value
    }
  }

  static get config() {
    return this._config ??= new Configuration()
  }

  static get launcher() {
    return this._launcher ??= new Launcher()
  }

  static get hooks() {
    return this.launcher.hooks
  }
}
