export default class Configuration {
  viewSelector = '[data-view]'
  componentSelector = '[data-component]'
  selector = '[data-component], [data-view]'
  namespacePattern = /(.+)#(.+)/

  isComponentIndex($el: JQuery) {
    return $el.data('component') !== null && $el.data('component') !== undefined
  }

  nodeUnderscoredName($el: JQuery): string {
    return this.isComponentIndex($el)
      ? $el.data('component')
      : $el.data('view') || ''
  }

  isStandAlone($el: JQuery) {
    return !this.isComponentIndex($el) && this.namespacePattern.test(this.nodeUnderscoredName($el))
  }

  extractStandAloneNodeData($el: JQuery) {
    const [__, namespaceName, nodeName] = this.nodeUnderscoredName($el).match(this.namespacePattern)
    return [namespaceName, nodeName]
  }

  extractComponentIndexNodeData($el: JQuery) {
    const [__, namespaceName, componentName] = this.nodeUnderscoredName($el).match(this.namespacePattern)
    return [namespaceName, componentName]
  }
}
