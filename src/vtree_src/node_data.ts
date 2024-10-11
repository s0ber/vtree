export interface Data {
  el: HTMLElement
  $el: JQuery

  isComponentIndex: boolean
  isComponentPart: boolean
  isStandAlone: boolean
  componentId?: number

  componentIndexNode?: NodeData

  nodeName: string
  componentName: string
  namespaceName: string

  nodeNameUnderscored: string
  componentNameUnderscored: string
  namespaceNameUnderscored: string
}

export default class NodeData implements Data {
  el: HTMLElement
  $el: JQuery

  isComponentIndex: boolean
  isComponentPart: boolean
  isStandAlone: boolean
  componentId: number

  componentIndexNode?: NodeData

  nodeName: string
  componentName: string
  namespaceName: string

  nodeNameUnderscored: string
  componentNameUnderscored: string
  namespaceNameUnderscored: string

  data: Record<string, any>

  constructor(options: Data) {
    for (let key in options) {
      const value = options[key]
      this[key] = value
    }
    this.data = {}
  }

  setData(name: string, value: any) {
    this.data[name] = value
  }

  getData(name: string) {
    return this.data[name]
  }
}
