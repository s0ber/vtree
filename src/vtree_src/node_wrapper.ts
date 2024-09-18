import NodeData from './node_data'
import type Node from './node'
import type Hooks from './hooks'
import type Configuration from '../configuration'

let componentId = 0
let SECRET_KEY = 'semarf'

export default class NodeWrapper {
  $el: JQuery
  el: HTMLElement
  namespaceName: string
  nodeName: string
  nodeData: NodeData

  isStandAlone: boolean
  isComponentIndex: boolean
  componentIndexNode?: Node
  private nodeUnderscoredName: string
  private component: {
    namespace: string
    node: Node
    id: number
    name: string
  }

  constructor(public node: Node, public config: Configuration, public hooks: Hooks) {
    this.$el = this.node.$el
    this.el = this.node.el

    this.isStandAlone = this.config.isStandAlone(this.$el)
    this.isComponentIndex = this.config.isComponentIndex(this.$el)
    this.nodeUnderscoredName = this.config.nodeUnderscoredName(this.$el)

    this.component = this.initComponent()
    this.componentIndexNode = this.isStandAlone || this.isComponentIndex
      ? undefined
      : this.component.node

    if (this.isComponentIndex) componentId++

    this.identifyNodeAttributes()
    this.initNodeDataObject()
  }

  initComponent() {
    if (this.isComponentIndex) {
      const [namespaceName, componentName] = this.config.extractComponentIndexNodeData(this.$el)
      return { namespace: namespaceName, name: componentName, id: componentId, node: this.node }
    } else if (this.node.parent !== undefined) {
      return this.node.parent.nodeWrapper.component
    } else {
      return { namespace: SECRET_KEY, name: SECRET_KEY, id: 0, node: this.node }
    }
  }

  identifyNodeAttributes() {
    if (this.isStandAlone) {
      const [namespaceName, nodeName] = this.config.extractStandAloneNodeData(this.$el)
      this.namespaceName = namespaceName
      this.nodeName = nodeName
    } else {
      this.namespaceName = this.component.namespace
      this.nodeName = this.isComponentIndex ? 'index' : this.nodeUnderscoredName
    }
  }

  initNodeDataObject() {
    this.nodeData = this.initNodeData()
    this.hooks.init(this.nodeData)
  }

  initNodeData() {
    const namespaceNameUnderscored = this.namespaceName
    const namespaceName = this._camelize(this.namespaceName)

    let componentName: string
    let componentNameUnderscored: string

    if (!this.isStandAlone) {
      componentNameUnderscored = this.component.name
      componentName = this._camelize(componentNameUnderscored)
    }

    return new NodeData({
      el: this.el,
      $el: this.$el,
      isStandAlone: this.isStandAlone,
      isComponentIndex: this.isComponentIndex,
      isComponentPart: !this.isStandAlone,
      componentId: this.isStandAlone ? null : this.component.id,
      componentIndexNode: this.componentIndexNode?.nodeWrapper?.nodeData,
      nodeName: this._camelize(this.nodeName),
      nodeNameUnderscored: this.nodeName,

      componentName,
      componentNameUnderscored,
      namespaceName,
      namespaceNameUnderscored
    })
  }

  unload() {
    this.hooks.unload(this.nodeData)
    delete this.nodeData
    delete this.node
  }

  private _camelize(s: string) {
    return s.replace(/(?:^|[-_])(\w)/g, (_, c) => c ? c.toUpperCase() : '')
  }
}
