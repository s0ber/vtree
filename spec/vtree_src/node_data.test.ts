import NodeData, { type Data } from '../../src/vtree_src/node_data'
import $ from 'jquery'

describe('NodeData', () => {
  let options: Data
  let nodeData: NodeData

  beforeEach(() => {
    const $el = $('div')

    options = {
      $el,
      el: $el[0],
      isComponentIndex: true,
      isComponentPart: true,
      isStandAlone: false,
      componentId: 1,

      nodeName: 'TestView',
      componentName: 'TestComponent',
      namespaceName: null,

      nodeNameUnderscored: 'test_view',
      componentNameUnderscored: 'test_component',
      namespaceNameUnderscored: null
    }

    nodeData = new NodeData(options)
  })

  describe('.setData', () => it('saves data by given name', () => {
    nodeData.setData('ololo', 'MyData')

    expect(nodeData.getData('ololo')).toBe('MyData')
  }))

  describe('.getData', () => it('shows previously saved data', () => {
    nodeData.setData('ololo', 'MyData')
    expect(nodeData.getData('ololo')).toBe('MyData')
  }))
})
