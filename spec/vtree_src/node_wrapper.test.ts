import $ from 'jquery'
import NodeWrapper from '../../src/vtree_src/node_wrapper'
import Configuration from '../../src/configuration'
import Hooks from '../../src/vtree_src/hooks'
import TreeManager from '../../src/vtree_src/tree_manager'
import Node from '../../src/vtree_src/node'
import NodeData from '../../src/vtree_src/node_data'

import { nodesForRefresh } from '../fixtures/nodes_for_refresh'
import { nodesWithDataView } from '../fixtures/nodes_with_data_view'

describe('NodeWrapper', () => {
  let launcherHooks: Hooks<(nodeData: NodeData) => void>

  beforeAll(() => {
    launcherHooks = new Hooks()
    launcherHooks.init = jest.fn()
    launcherHooks.unload = jest.fn()
  })

  describe('Basic methods', () => {
    let config: Configuration
    let $el: JQuery
    let node: Node
    let nodeWrapper: NodeWrapper

    beforeEach(() => {
      config = new Configuration()
      $el = $('<div />')
      node = new Node($el)
      nodeWrapper = new NodeWrapper(node, config, launcherHooks)
    })

    describe('.constructor', () => {
      it('saves reference to provided view node in @node', () => {
        expect(nodeWrapper.node).toBe(node)
      })

      it('saves reference to node.$el in @$el', () => {
        expect(nodeWrapper.$el).toBe(node.$el)
      })

      it('saves reference to node.el in @el', () => {
        expect(nodeWrapper.el).toBe(node.el)
      })

      it('identifies view', () => {
        jest.spyOn(NodeWrapper.prototype, 'identifyNodeAttributes')
        const node = new Node($el)
        const nodeWrapper = new NodeWrapper(node, config, launcherHooks)
        expect(nodeWrapper.identifyNodeAttributes).toHaveBeenCalledOnce()
      })

      it('initializes new Vtree node', () => {
        jest.spyOn(NodeWrapper.prototype, 'initNodeDataObject')
        const node = new Node($el)
        const nodeWrapper = new NodeWrapper(node, config, launcherHooks)
        expect(nodeWrapper.initNodeDataObject).toHaveBeenCalledOnce()
      })
    })

    describe('.initNodeDataObject', () => {
      it('calls Hooks init hooks', () => {
        expect(launcherHooks.init).toHaveBeenCalledOnce()
      })

      it('provides nodeData object to init call', () => {
        expect(launcherHooks.init).toHaveBeenCalledWith(expect.any(NodeData))
      })
    })

    describe('.unload', () => {
      it('calls Hooks unload hooks', () => {
        nodeWrapper.unload()
        expect(launcherHooks.unload).toHaveBeenCalledOnce()
      })

      it('provides nodeData object to init call', () => {
        nodeWrapper.unload()
        expect(launcherHooks.unload).toHaveBeenCalledWith(expect.any(NodeData))
      })

      it('deletes reference to nodeData object', () => {
        nodeWrapper.unload()
        expect(nodeWrapper.nodeData).toBeUndefined()
      })

      it('deletes reference to node object', () => {
        nodeWrapper.unload()
        expect(nodeWrapper.node).toBeUndefined()
      })
    })
  })

  describe('View initialization', () => {
    let nodes: Record<string, Node>
    let nodesData: Record<string, NodeData>

    const prepareFixtureData = () => {
      const $els = $(nodesWithDataView)
      const $newEls = $(nodesForRefresh)

      $('body').empty().append($els)
      $('#component1').append($newEls)

      const config = new Configuration()
      const treeManager = new TreeManager(config, new Hooks())
      treeManager.setInitialNodes()
      treeManager.setParentsForInitialNodes()
      treeManager.setChildrenForInitialNodes()

      // order matters here
      for (let view of 'component1 view1 view2 view3 view4 view5 view6 view7 component2 view8 view9'.split(' ')) {
        const id = $('#' + view).data('vtree-node-id')
        nodes[view] = treeManager.nodesCache.getById(id)
        nodes[view].activate()
      }
    }

    beforeEach(() => {
      nodes = {}
      nodesData = {}
      prepareFixtureData()
    })

    describe('.isComponentIndex', () => it('checks if node should initialize a component index', () => {
      expect(nodes['component1'].nodeWrapper.isComponentIndex).toBe(true)
      expect(nodes['view1'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['view2'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['view3'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['view4'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['view5'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['view6'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['view7'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['component2'].nodeWrapper.isComponentIndex).toBe(true)
      expect(nodes['view8'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['view9'].nodeWrapper.isComponentIndex).toBe(false)
    }))

    describe('.isStandAlone', () => it('checks if node is a stand alone node and not a part of a component', () => {
      expect(nodes['component1'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view1'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view2'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view3'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view4'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view5'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view6'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view7'].nodeWrapper.isStandAlone).toBe(true)
      expect(nodes['component2'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view8'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view9'].nodeWrapper.isStandAlone).toBe(true)
    }))

    describe('.identifyNodeAttributes', () => {
      it('identifies current node namespace name', () => {
        expect(nodes['component1'].nodeWrapper.namespaceName).toBe('component_namespace')
        expect(nodes['view1'].nodeWrapper.namespaceName).toBe('component_namespace')
        expect(nodes['view2'].nodeWrapper.namespaceName).toBe('component_namespace')
        expect(nodes['view3'].nodeWrapper.namespaceName).toBe('component_namespace')
        expect(nodes['view4'].nodeWrapper.namespaceName).toBe('component_namespace')
        expect(nodes['view5'].nodeWrapper.namespaceName).toBe('component_namespace')
        expect(nodes['view6'].nodeWrapper.namespaceName).toBe('component_namespace')
        expect(nodes['view7'].nodeWrapper.namespaceName).toBe('test_namespace')
        expect(nodes['component2'].nodeWrapper.namespaceName).toBe('component_namespace')
        expect(nodes['view8'].nodeWrapper.namespaceName).toBe('component_namespace')
        expect(nodes['view9'].nodeWrapper.namespaceName).toBe('test_namespace')
      })

      it('identifies current node view name', () => {
        expect(nodes['component1'].nodeWrapper.nodeName).toBe('index')
        expect(nodes['view1'].nodeWrapper.nodeName).toBe('test_view1')
        expect(nodes['view2'].nodeWrapper.nodeName).toBe('test_view2')
        expect(nodes['view3'].nodeWrapper.nodeName).toBe('test_view3')
        expect(nodes['view4'].nodeWrapper.nodeName).toBe('test_view4')
        expect(nodes['view5'].nodeWrapper.nodeName).toBe('test_view5')
        expect(nodes['view6'].nodeWrapper.nodeName).toBe('test_view6')
        expect(nodes['view7'].nodeWrapper.nodeName).toBe('test_view7')
        expect(nodes['component2'].nodeWrapper.nodeName).toBe('index')
        expect(nodes['view8'].nodeWrapper.nodeName).toBe('test_view8')
        expect(nodes['view9'].nodeWrapper.nodeName).toBe('test_view9')
      })
    })

    describe('.isComponentIndex', () => it('checks if node should initialize a component index', () => {
      expect(nodes['component1'].nodeWrapper.isComponentIndex).toBe(true)
      expect(nodes['view1'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['view2'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['view3'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['view4'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['view5'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['view6'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['view7'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['component2'].nodeWrapper.isComponentIndex).toBe(true)
      expect(nodes['view8'].nodeWrapper.isComponentIndex).toBe(false)
      expect(nodes['view9'].nodeWrapper.isComponentIndex).toBe(false)
    }))

    describe('.componentIndexNode', () => {
      describe('node is a component index node', () => it('returns itself', () => {
        expect(nodes['component1'].nodeWrapper.componentIndexNode).toBe(undefined)
        expect(nodes['component2'].nodeWrapper.componentIndexNode).toBe(undefined)
      }))

      describe('node is stand alone', () => {
        it('returns undefined', () => {
          expect(nodes['view7'].nodeWrapper.componentIndexNode).toBe(undefined)
          expect(nodes['view9'].nodeWrapper.componentIndexNode).toBe(undefined)
        })
      })

      describe('node is a part of a component', () => it("provides reference to node's component index node", () => {
        expect(nodes['view1'].nodeWrapper.componentIndexNode).toBe(nodes['component1'])
        expect(nodes['view2'].nodeWrapper.componentIndexNode).toBe(nodes['component1'])
        expect(nodes['view3'].nodeWrapper.componentIndexNode).toBe(nodes['component1'])
        expect(nodes['view4'].nodeWrapper.componentIndexNode).toBe(nodes['component1'])
        expect(nodes['view5'].nodeWrapper.componentIndexNode).toBe(nodes['component1'])
        expect(nodes['view6'].nodeWrapper.componentIndexNode).toBe(nodes['component1'])
        expect(nodes['view8'].nodeWrapper.componentIndexNode).toBe(nodes['component2'])
      }))
    })

    describe('.isStandAlone', () => it('checks if node is stand alone and not a part of a component', () => {
      expect(nodes['component1'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view1'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view2'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view3'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view4'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view5'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view6'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view7'].nodeWrapper.isStandAlone).toBe(true)
      expect(nodes['component2'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view8'].nodeWrapper.isStandAlone).toBe(false)
      expect(nodes['view9'].nodeWrapper.isStandAlone).toBe(true)
    }))

    describe('.initNodeData', () => {
      let component1Id: number
      let component2Id: number

      beforeEach(() => {
        component1Id = nodes['component1'].nodeWrapper.nodeData.componentId
        component2Id = nodes['component2'].nodeWrapper.nodeData.componentId

        nodesData['component1'] = nodes['component1'].nodeWrapper.nodeData
        nodesData['view1'] = nodes['view1'].nodeWrapper.nodeData
        nodesData['view2'] = nodes['view2'].nodeWrapper.nodeData
        nodesData['view3'] = nodes['view3'].nodeWrapper.nodeData
        nodesData['view4'] = nodes['view4'].nodeWrapper.nodeData
        nodesData['view5'] = nodes['view5'].nodeWrapper.nodeData
        nodesData['view6'] = nodes['view6'].nodeWrapper.nodeData
        nodesData['view7'] = nodes['view7'].nodeWrapper.nodeData
        nodesData['component2'] = nodes['component2'].nodeWrapper.nodeData
        nodesData['view8'] = nodes['view8'].nodeWrapper.nodeData
        nodesData['view9'] = nodes['view9'].nodeWrapper.nodeData
      })

      it('returns NodeData object based on current state of NodeWrapper', () => {
        let $el = $('<div />')
        let node = new Node($el)
        let config = new Configuration()
        let nodeWrapper = new NodeWrapper(node, config, launcherHooks)
        const object = nodeWrapper.initNodeData()
        expect(object).toBeInstanceOf(NodeData)
      })

      it('sets correct data to all NodeData objects', () => {
        expect(nodesData['component1']).toHaveProperty('el', nodes['component1'].el)
        expect(nodesData['component1']).toHaveProperty('$el', nodes['component1'].$el)
        expect(nodesData['component1']).toHaveProperty('isComponentIndex', true)
        expect(nodesData['component1']).toHaveProperty('isComponentPart', true)
        expect(nodesData['component1']).toHaveProperty('isStandAlone', false)
        expect(nodesData['component1']).toHaveProperty('componentId', component1Id)
        expect(nodesData['component1']).toHaveProperty('componentIndexNode', undefined)
        expect(nodesData['component1']).toHaveProperty('nodeName', 'Index')
        expect(nodesData['component1']).toHaveProperty('nodeNameUnderscored', 'index')
        expect(nodesData['component1']).toHaveProperty('componentName', 'TestComponent')
        expect(nodesData['component1']).toHaveProperty('componentNameUnderscored', 'test_component')
        expect(nodesData['component1']).toHaveProperty('namespaceName', 'ComponentNamespace')
        expect(nodesData['component1']).toHaveProperty('namespaceNameUnderscored', 'component_namespace')

        expect(nodesData['view1']).toHaveProperty('el', nodes['view1'].el)
        expect(nodesData['view1']).toHaveProperty('$el', nodes['view1'].$el)
        expect(nodesData['view1']).toHaveProperty('isComponentIndex', false)
        expect(nodesData['view1']).toHaveProperty('isComponentPart', true)
        expect(nodesData['view1']).toHaveProperty('isStandAlone', false)
        expect(nodesData['view1']).toHaveProperty('componentId', component1Id)
        expect(nodesData['view1']).toHaveProperty('componentIndexNode', nodesData['component1'])
        expect(nodesData['view1']).toHaveProperty('nodeName', 'TestView1')
        expect(nodesData['view1']).toHaveProperty('nodeNameUnderscored', 'test_view1')
        expect(nodesData['view1']).toHaveProperty('componentName', 'TestComponent')
        expect(nodesData['view1']).toHaveProperty('componentNameUnderscored', 'test_component')
        expect(nodesData['view1']).toHaveProperty('namespaceName', 'ComponentNamespace')
        expect(nodesData['view1']).toHaveProperty('namespaceNameUnderscored', 'component_namespace')

        expect(nodesData['view2']).toHaveProperty('el', nodes['view2'].el)
        expect(nodesData['view2']).toHaveProperty('$el', nodes['view2'].$el)
        expect(nodesData['view2']).toHaveProperty('isComponentIndex', false)
        expect(nodesData['view2']).toHaveProperty('isComponentPart', true)
        expect(nodesData['view2']).toHaveProperty('isStandAlone', false)
        expect(nodesData['view2']).toHaveProperty('componentId', component1Id)
        expect(nodesData['view2']).toHaveProperty('componentIndexNode', nodesData['component1'])
        expect(nodesData['view2']).toHaveProperty('nodeName', 'TestView2')
        expect(nodesData['view2']).toHaveProperty('nodeNameUnderscored', 'test_view2')
        expect(nodesData['view2']).toHaveProperty('componentName', 'TestComponent')
        expect(nodesData['view2']).toHaveProperty('componentNameUnderscored', 'test_component')
        expect(nodesData['view2']).toHaveProperty('namespaceName', 'ComponentNamespace')
        expect(nodesData['view2']).toHaveProperty('namespaceNameUnderscored', 'component_namespace')

        expect(nodesData['view3']).toHaveProperty('el', nodes['view3'].el)
        expect(nodesData['view3']).toHaveProperty('$el', nodes['view3'].$el)
        expect(nodesData['view3']).toHaveProperty('isComponentIndex', false)
        expect(nodesData['view3']).toHaveProperty('isComponentPart', true)
        expect(nodesData['view3']).toHaveProperty('isStandAlone', false)
        expect(nodesData['view3']).toHaveProperty('componentId', component1Id)
        expect(nodesData['view3']).toHaveProperty('componentIndexNode', nodesData['component1'])
        expect(nodesData['view3']).toHaveProperty('nodeName', 'TestView3')
        expect(nodesData['view3']).toHaveProperty('nodeNameUnderscored', 'test_view3')
        expect(nodesData['view3']).toHaveProperty('componentName', 'TestComponent')
        expect(nodesData['view3']).toHaveProperty('componentNameUnderscored', 'test_component')
        expect(nodesData['view3']).toHaveProperty('namespaceName', 'ComponentNamespace')
        expect(nodesData['view3']).toHaveProperty('namespaceNameUnderscored', 'component_namespace')

        expect(nodesData['view4']).toHaveProperty('el', nodes['view4'].el)
        expect(nodesData['view4']).toHaveProperty('$el', nodes['view4'].$el)
        expect(nodesData['view4']).toHaveProperty('isComponentIndex', false)
        expect(nodesData['view4']).toHaveProperty('isComponentPart', true)
        expect(nodesData['view4']).toHaveProperty('isStandAlone', false)
        expect(nodesData['view4']).toHaveProperty('componentId', component1Id)
        expect(nodesData['view4']).toHaveProperty('componentIndexNode', nodesData['component1'])
        expect(nodesData['view4']).toHaveProperty('nodeName', 'TestView4')
        expect(nodesData['view4']).toHaveProperty('nodeNameUnderscored', 'test_view4')
        expect(nodesData['view4']).toHaveProperty('componentName', 'TestComponent')
        expect(nodesData['view4']).toHaveProperty('componentNameUnderscored', 'test_component')
        expect(nodesData['view4']).toHaveProperty('namespaceName', 'ComponentNamespace')
        expect(nodesData['view4']).toHaveProperty('namespaceNameUnderscored', 'component_namespace')

        expect(nodesData['view5']).toHaveProperty('el', nodes['view5'].el)
        expect(nodesData['view5']).toHaveProperty('$el', nodes['view5'].$el)
        expect(nodesData['view5']).toHaveProperty('isComponentIndex', false)
        expect(nodesData['view5']).toHaveProperty('isComponentPart', true)
        expect(nodesData['view5']).toHaveProperty('isStandAlone', false)
        expect(nodesData['view5']).toHaveProperty('componentId', component1Id)
        expect(nodesData['view5']).toHaveProperty('componentIndexNode', nodesData['component1'])
        expect(nodesData['view5']).toHaveProperty('nodeName', 'TestView5')
        expect(nodesData['view5']).toHaveProperty('nodeNameUnderscored', 'test_view5')
        expect(nodesData['view5']).toHaveProperty('componentName', 'TestComponent')
        expect(nodesData['view5']).toHaveProperty('componentNameUnderscored', 'test_component')
        expect(nodesData['view5']).toHaveProperty('namespaceName', 'ComponentNamespace')
        expect(nodesData['view5']).toHaveProperty('namespaceNameUnderscored', 'component_namespace')

        expect(nodesData['view6']).toHaveProperty('el', nodes['view6'].el)
        expect(nodesData['view6']).toHaveProperty('$el', nodes['view6'].$el)
        expect(nodesData['view6']).toHaveProperty('isComponentIndex', false)
        expect(nodesData['view6']).toHaveProperty('isComponentPart', true)
        expect(nodesData['view6']).toHaveProperty('isStandAlone', false)
        expect(nodesData['view6']).toHaveProperty('componentId', component1Id)
        expect(nodesData['view6']).toHaveProperty('componentIndexNode', nodesData['component1'])
        expect(nodesData['view6']).toHaveProperty('nodeName', 'TestView6')
        expect(nodesData['view6']).toHaveProperty('nodeNameUnderscored', 'test_view6')
        expect(nodesData['view6']).toHaveProperty('componentName', 'TestComponent')
        expect(nodesData['view6']).toHaveProperty('componentNameUnderscored', 'test_component')
        expect(nodesData['view6']).toHaveProperty('namespaceName', 'ComponentNamespace')
        expect(nodesData['view6']).toHaveProperty('namespaceNameUnderscored', 'component_namespace')

        expect(nodesData['view7']).toHaveProperty('el', nodes['view7'].el)
        expect(nodesData['view7']).toHaveProperty('$el', nodes['view7'].$el)
        expect(nodesData['view7']).toHaveProperty('isComponentIndex', false)
        expect(nodesData['view7']).toHaveProperty('isComponentPart', false)
        expect(nodesData['view7']).toHaveProperty('isStandAlone', true)
        expect(nodesData['view7']).toHaveProperty('componentId', null)
        expect(nodesData['view7']).toHaveProperty('componentIndexNode', undefined)
        expect(nodesData['view7']).toHaveProperty('nodeName', 'TestView7')
        expect(nodesData['view7']).toHaveProperty('nodeNameUnderscored', 'test_view7')
        expect(nodesData['view7']).toHaveProperty('componentName', undefined)
        expect(nodesData['view7']).toHaveProperty('componentNameUnderscored', undefined)
        expect(nodesData['view7']).toHaveProperty('namespaceName', 'TestNamespace')
        expect(nodesData['view7']).toHaveProperty('namespaceNameUnderscored', 'test_namespace')

        expect(nodesData['component2']).toHaveProperty('el', nodes['component2'].el)
        expect(nodesData['component2']).toHaveProperty('$el', nodes['component2'].$el)
        expect(nodesData['component2']).toHaveProperty('isComponentIndex', true)
        expect(nodesData['component2']).toHaveProperty('isComponentPart', true)
        expect(nodesData['component2']).toHaveProperty('isStandAlone', false)
        expect(nodesData['component2']).toHaveProperty('componentId', component2Id)
        expect(nodesData['component2']).toHaveProperty('componentIndexNode', undefined)
        expect(nodesData['component2']).toHaveProperty('nodeName', 'Index')
        expect(nodesData['component2']).toHaveProperty('nodeNameUnderscored', 'index')
        expect(nodesData['component2']).toHaveProperty('componentName', 'TestComponent2')
        expect(nodesData['component2']).toHaveProperty('componentNameUnderscored', 'test_component2')
        expect(nodesData['component2']).toHaveProperty('namespaceName', 'ComponentNamespace')
        expect(nodesData['component2']).toHaveProperty('namespaceNameUnderscored', 'component_namespace')

        expect(nodesData['view8']).toHaveProperty('el', nodes['view8'].el)
        expect(nodesData['view8']).toHaveProperty('$el', nodes['view8'].$el)
        expect(nodesData['view8']).toHaveProperty('isComponentIndex', false)
        expect(nodesData['view8']).toHaveProperty('isComponentPart', true)
        expect(nodesData['view8']).toHaveProperty('isStandAlone', false)
        expect(nodesData['view8']).toHaveProperty('componentId', component2Id)
        expect(nodesData['view8']).toHaveProperty('componentIndexNode', nodesData['component2'])
        expect(nodesData['view8']).toHaveProperty('nodeName', 'TestView8')
        expect(nodesData['view8']).toHaveProperty('nodeNameUnderscored', 'test_view8')
        expect(nodesData['view8']).toHaveProperty('componentName', 'TestComponent2')
        expect(nodesData['view8']).toHaveProperty('componentNameUnderscored', 'test_component2')
        expect(nodesData['view8']).toHaveProperty('namespaceName', 'ComponentNamespace')
        expect(nodesData['view8']).toHaveProperty('namespaceNameUnderscored', 'component_namespace')

        expect(nodesData['view9']).toHaveProperty('el', nodes['view9'].el)
        expect(nodesData['view9']).toHaveProperty('$el', nodes['view9'].$el)
        expect(nodesData['view9']).toHaveProperty('isComponentIndex', false)
        expect(nodesData['view9']).toHaveProperty('isComponentPart', false)
        expect(nodesData['view9']).toHaveProperty('isStandAlone', true)
        expect(nodesData['view9']).toHaveProperty('componentId', null)
        expect(nodesData['view9']).toHaveProperty('componentIndexNode', undefined)
        expect(nodesData['view9']).toHaveProperty('nodeName', 'TestView9')
        expect(nodesData['view9']).toHaveProperty('nodeNameUnderscored', 'test_view9')
        expect(nodesData['view9']).toHaveProperty('componentName', undefined)
        expect(nodesData['view9']).toHaveProperty('componentNameUnderscored', undefined)
        expect(nodesData['view9']).toHaveProperty('namespaceName', 'TestNamespace')
        expect(nodesData['view9']).toHaveProperty('namespaceNameUnderscored', 'test_namespace')
      })
    })
  })
})
