import $ from 'jquery'
import Launcher from '../../src/vtree_src/launcher'
import Node from '../../src/vtree_src/node'
import TreeManager from '../../src/vtree_src/tree_manager'
import Configuration from '../../src/configuration'
import Hooks from '../../src/vtree_src/hooks'
import NodeWrapper from '../../src/vtree_src/node_wrapper'
import NodesCache from '../../src/vtree_src/vtree_nodes_cache'

import { nodesForRefresh } from '../fixtures/nodes_for_refresh'
import { nodesWithDataView } from '../fixtures/nodes_with_data_view'

describe('TreeManager', () => {
  let launcher: Launcher
  let config: Configuration
  let launcherHooks: Hooks
  let $el: JQuery
  let treeManager: TreeManager

  describe('Node callbacks', () => {
    beforeEach(() => {
      config = new Configuration()
      launcher = new Launcher()
      launcherHooks = launcher.hooks

      launcher.initRemoveEvent()
      $el = $('<div />')
    })

    describe('.initNodeHooks', () => {
      it('saves new Hooks object in @hooks', () => {
        treeManager = new TreeManager(config, launcherHooks)
        expect(treeManager.hooks).toBeInstanceOf(Hooks)
      })

      it('adds @addNodeIdToElData init hook', () => {
        jest.spyOn(TreeManager.prototype, 'addNodeIdToElData')

        treeManager = new TreeManager(config, launcherHooks)
        new Node($el, treeManager.hooks)
        expect(treeManager.addNodeIdToElData).toHaveBeenCalledOnce()
      })

      it('adds @addRemoveEventHandlerToEl init hook', () => {
        jest.spyOn(TreeManager.prototype, 'addRemoveEventHandlerToEl')

        treeManager = new TreeManager(config, launcherHooks)
        new Node($el, treeManager.hooks)
        expect(treeManager.addRemoveEventHandlerToEl).toHaveBeenCalledOnce()
      })

      it('adds @addNodeWrapper activation hook', () => {
        jest.spyOn(TreeManager.prototype, 'addNodeWrapper')

        treeManager = new TreeManager(config, launcherHooks)
        const node = new Node($el, treeManager.hooks)
        node.activate()
        expect(treeManager.addNodeWrapper).toHaveBeenCalledOnce()
      })

      it('adds @unloadNode unload hook', () => {
        jest.spyOn(TreeManager.prototype, 'unloadNode')

        treeManager = new TreeManager(config, launcherHooks)
        const node = new Node($el, treeManager.hooks)
        node.unload()
        expect(treeManager.unloadNode).toHaveBeenCalledOnce()
      })

      it('adds @deleteNodeWrapper unload hook', () => {
        jest.spyOn(TreeManager.prototype, 'deleteNodeWrapper')
        treeManager = new TreeManager(config, launcherHooks)
        const node = new Node($el, treeManager.hooks)
        node.unload()
        expect(treeManager.deleteNodeWrapper).toHaveBeenCalledOnce()
      })
    })

    describe('.addNodeIdToElData', () => {
      it("adds nodeId to node's $element", () => {
        treeManager = new TreeManager(config, launcherHooks)

        const $el = $('<div />')
        const node = new Node($el)
        treeManager.addNodeIdToElData(node)

        expect($el.data('vtree-node-id')).toBe(node.id)
      })
    })

    describe('.addRemoveEventHandlerToEl', () => {
      it('adds calls @treemanager.removeNode with $el node provided', () => {
        treeManager = new TreeManager(config, launcherHooks)

        const $el = $('<div />')
        const node = new Node($el, treeManager.hooks)
        jest.spyOn(treeManager, 'removeNode')
        node.$el.remove()
        expect(treeManager.removeNode).toHaveBeenCalledOnce()
      })
    })

    describe('.addNodeWrapper', () => {
      it('initializes NodeWrapper instance', () => {
        treeManager = new TreeManager(config, launcherHooks)

        const $el = $('<div />')
        const node = new Node($el)
        treeManager.addNodeWrapper(node)

        expect(node.nodeWrapper).toBeInstanceOf(NodeWrapper)
        expect(node.nodeWrapper.hooks).toBe(launcherHooks)
      })
    })

    describe('.unloadNode', () => {
      it('unloads NodeWrapper instance', () => {
        treeManager = new TreeManager(config, launcherHooks)

        const node = new Node($el)
        const hooks = new Hooks()
        node.nodeWrapper = new NodeWrapper(node, config, hooks)
        jest.spyOn(node.nodeWrapper, 'unload')

        treeManager.unloadNode(node)

        expect(node.nodeWrapper.unload).toHaveBeenCalledOnce()
      })
    })

    describe('.deleteNodeWrapper', () => {
      it('deletes NodeWrapper instance from corresponding Node', () => {
        treeManager = new TreeManager(config, launcherHooks)

        const node = new Node($el)
        treeManager.deleteNodeWrapper(node)

        expect(node.nodeWrapper).toBe(undefined)
      })
    })
  })

  describe('Constructor and tree building behavior', () => {
    beforeEach(() => {
      config = new Configuration()
      launcherHooks = launcher.hooks
      treeManager = new TreeManager(config, launcherHooks)
    })

    describe('.constructor', () => {
      it('creates NodesCache instance in @nodesCache', () => {
        expect(treeManager.nodesCache).toBeInstanceOf(NodesCache)
      })

      it('has empty @initialNodes list', () => {
        expect(treeManager.initialNodes).toEqual([])
      })
    })

    describe('.createTree', () => {
      it('creates nodes for initial dom state', () => {
        jest.spyOn(treeManager, 'setInitialNodes')
        treeManager.createTree()
        expect(treeManager.setInitialNodes).toHaveBeenCalledOnce()
      })

      it('sets parents for initial nodes', () => {
        jest.spyOn(treeManager, 'setParentsForInitialNodes')
        treeManager.createTree()
        expect(treeManager.setParentsForInitialNodes).toHaveBeenCalledOnce()
      })

      it('sets children for initial nodes', () => {
        jest.spyOn(treeManager, 'setChildrenForInitialNodes')
        treeManager.createTree()
        expect(treeManager.setChildrenForInitialNodes).toHaveBeenCalledOnce()
      })

      it('activates initial nodes', () => {
        jest.spyOn(treeManager, 'activateInitialNodes')
        treeManager.createTree()
        expect(treeManager.activateInitialNodes).toHaveBeenCalledOnce()
      })
    })

    describe('Tree building behavior', () => {
      beforeEach(() => {
        let $els = $(nodesWithDataView)

        $('body').empty()
        $('body').append($els)
      })

      describe('.setInitialNodes', () => {
        it('initialized Node objects for each element for specified "app" and "view" selectors', () => {
          treeManager.setInitialNodes()

          treeManager.initialNodes.map(node =>
            expect(node).toBeInstanceOf(Node))
        })

        it('has nodes pointed to corresponding dom elements in @initialNodes list', () => {
          const $els = $('body').find(config.selector)

          treeManager.setInitialNodes()
          const initialNodesEls = treeManager.initialNodes.map(node => node.el)
          expect(initialNodesEls).toEqual(Array.from($els))
        })

        it('provides @hooks to nodes constructor', () => {
          treeManager.setInitialNodes()
          const firstNode = treeManager.initialNodes[0]
          expect(firstNode.hooks).toBe(treeManager.hooks)
        })

        it('saves nodes to NodesCache', () => {
          jest.spyOn(treeManager.nodesCache, 'add')
          treeManager.setInitialNodes()
          expect(treeManager.nodesCache.add).toHaveBeenCalledTimes(4)
        })
      })

      describe('.setParentsForInitialNodes', () => {
        it('sets parents for initial nodes', () => {
          jest.spyOn(treeManager, 'setParentsForNodes')
          treeManager.setInitialNodes()
          const { initialNodes } = treeManager

          treeManager.setParentsForInitialNodes()
          expect(treeManager.setParentsForNodes).toHaveBeenCalledOnce()
          expect(treeManager.setParentsForNodes).toHaveBeenCalledWith(initialNodes)
        })
      })

      describe('.setChildrenForInitialNodes', () => it('sets children for initial nodes', () => {
        jest.spyOn(treeManager, 'setChildrenForNodes')
        treeManager.setInitialNodes()
        const { initialNodes } = treeManager

        treeManager.setChildrenForInitialNodes()
        expect(treeManager.setChildrenForNodes).toHaveBeenCalledOnce()
        expect(treeManager.setChildrenForNodes).toHaveBeenCalledWith(initialNodes)
      }))

      describe('Tree setup and activation', () => {
        let nodes: Node[]
        let appNode: Node
        let view1Node: Node
        let view2Node: Node
        let view3Node: Node

        beforeEach(() => {
          treeManager.setInitialNodes()
          nodes = treeManager.initialNodes

          const $component = $('#component1')
          const $view1 = $('#view1')
          const $view2 = $('#view2')
          const $view3 = $('#view3')

          const componentNodeId = $component.data('vtree-node-id')
          const view1NodeId = $view1.data('vtree-node-id')
          const view2NodeId = $view2.data('vtree-node-id')
          const view3NodeId = $view3.data('vtree-node-id')

          appNode = treeManager.nodesCache.getById(componentNodeId)
          view1Node = treeManager.nodesCache.getById(view1NodeId)
          view2Node = treeManager.nodesCache.getById(view2NodeId)
          view3Node = treeManager.nodesCache.getById(view3NodeId)

          jest.spyOn(appNode, 'activate')
          jest.spyOn(view1Node, 'activate')
          jest.spyOn(view2Node, 'activate')
          jest.spyOn(view3Node, 'activate')
        })

        describe('.setParentsForNodes', () => {
          beforeEach(() => {
            treeManager.setParentsForNodes(nodes)
          })

          it('looks for closest view dom element and sets it as parent for provided nodes', () => {
            expect(view1Node.parent).toBe(appNode)
            expect(view2Node.parent).toBe(appNode)
            expect(view3Node.parent).toBe(view2Node)
          })

          it('sets null reference to node parent if have no parent', () => {
            expect(appNode.parent).toBe(undefined)
          })

          it('adds node to cache as root if have no parent', () => {
            expect(treeManager.nodesCache.showRootNodes()).toEqual([appNode])
          })
        })

        describe('.setChildrenForNodes', () => {
          beforeEach(() => {
            treeManager.setParentsForNodes(nodes)
            treeManager.setChildrenForNodes(nodes)
          })

          it('sets children for provided nodes', () => {
            expect(appNode.children).toEqual([view1Node, view2Node])
            expect(view1Node.children).toEqual([])
            expect(view2Node.children).toEqual([view3Node])
            expect(view3Node.children).toEqual([])
        })
      })

        describe('.activateNode', () => {
          beforeEach(() => {
            treeManager.setParentsForNodes(nodes)
            treeManager.setChildrenForNodes(nodes)
            treeManager.activateNode(appNode)
          })

          it("recursively activates provided node and it's children nodes", () => {
            expect(appNode.isActivated).toBe(true)
            expect(view1Node.isActivated).toBe(true)
            expect(view2Node.isActivated).toBe(true)
            expect(view3Node.isActivated).toBe(true)
          })

          it('activates nodes in proper order', () => {
            expect(appNode.activate).toHaveBeenCalledBefore(view1Node.activate as jest.Mock)
            expect(view1Node.activate).toHaveBeenCalledBefore(view2Node.activate as jest.Mock)
            expect(view2Node.activate).toHaveBeenCalledBefore(view3Node.activate as jest.Mock)
          })
        })

        describe('.activateInitialNodes', () => {
          it('activates root view nodes in initial nodes list', () => {
            jest.spyOn(treeManager, 'activateRootNodes')
            jest.spyOn(treeManager, 'activateNode')
            const { initialNodes } = treeManager

            treeManager.setParentsForNodes(nodes)
            treeManager.setChildrenForNodes(nodes)
            treeManager.activateInitialNodes()

            expect(treeManager.activateRootNodes).toHaveBeenCalledOnce()
            for (let node of initialNodes) {
              expect(treeManager.activateNode).toHaveBeenCalledWith(node)
            }
          })
        })

        describe('.activateRootNodes', () => {
          it('searches for root nodes in provided nodes list and activates them', () => {
            treeManager.setParentsForNodes(nodes)
            treeManager.setChildrenForNodes(nodes)
            treeManager.activateRootNodes()
            expect(appNode.isActivated).toBe(true)
          })
        })

        describe('.removeNode', () => {
          beforeEach(() => {
            treeManager.setParentsForNodes(nodes)
            treeManager.setChildrenForNodes(nodes)
          })

          it('does nothing if node is already removed', () => {
            jest.spyOn(view3Node, 'remove')

            view3Node.remove()
            treeManager.removeNode(view3Node)
            expect(view3Node.remove).toHaveBeenCalledOnce()
          })

          it("deattaches node from it's parent", () => {
            const { parent } = view3Node
            expect(parent.children.indexOf(view3Node) > -1).toBe(true)

            treeManager.removeNode(view3Node)
            expect(parent.children.indexOf(view3Node) > -1).toBe(false)
          })

          it('removes provided node', () => {
            treeManager.removeNode(view3Node)
            expect(view3Node.isRemoved).toBe(true)
          })

          it('removes child nodes', () => {
            jest.spyOn(treeManager, 'removeChildNodes')
            treeManager.removeNode(appNode)

            expect(treeManager.removeChildNodes).toHaveBeenCalled()
            expect((treeManager.removeChildNodes as jest.Mock).mock.calls[0][0]).toBe(appNode)
          })

          it('at first removes child nodes', () => {
            jest.spyOn(appNode, 'remove')
            jest.spyOn(view1Node, 'remove')

            treeManager.removeNode(appNode)
            expect(view1Node.remove).toHaveBeenCalledBefore(appNode.remove as jest.Mock)
          })

          it('removes node from nodesCache', () => {
            const nodeId = appNode.id
            expect(treeManager.nodesCache.getById(nodeId)).toBe(appNode)

            treeManager.removeNode(appNode)
            expect(treeManager.nodesCache.getById(nodeId)).toBe(undefined)
          })

          describe('OnRemove event handling behavior', () => {
            it('being called whenever dom element with node being removed from DOM', () => {
              jest.spyOn(treeManager, 'removeNode')
              $('#component1').remove()
              expect(treeManager.removeNode).toHaveReturnedTimes(4)
            })

            it('being called in proper order', () => {
              const nodes = [appNode, view1Node, view2Node, view3Node]
              for (let node of nodes) {
                jest.spyOn(node, 'remove')
              }

              $('#component1').remove()

              for (let node of nodes) {
                expect(node.remove).toHaveBeenCalledOnce()
              }

              expect(view3Node.remove).toHaveBeenCalledBefore(view2Node.remove as jest.Mock)
              expect(view1Node.remove).toHaveBeenCalledBefore(view2Node.remove as jest.Mock)
              expect(view1Node.remove).toHaveBeenCalledBefore(appNode.remove as jest.Mock)
              expect(view2Node.remove).toHaveBeenCalledBefore(appNode.remove as jest.Mock)
            })
          })
        })

        describe('.removeChildNodes', () => {
          beforeEach(() => {
            treeManager.setParentsForNodes(nodes)
            treeManager.setChildrenForNodes(nodes)

            jest.spyOn(appNode, 'remove')
            jest.spyOn(view1Node, 'remove')
            jest.spyOn(view2Node, 'remove')
            jest.spyOn(view3Node, 'remove')

            treeManager.removeChildNodes(appNode)
          })

          it("recursively removes provided node's children", () => {
            expect(view1Node.remove).toHaveBeenCalledOnce()
            expect(view2Node.remove).toHaveBeenCalledOnce()
            expect(view3Node.remove).toHaveBeenCalledOnce()
          })

          it('removes children nodes in proper order', () => {
            expect(view1Node.remove).toHaveBeenCalledBefore(view2Node.remove as jest.Mock)
            expect(view3Node.remove).toHaveBeenCalledBefore(view2Node.remove as jest.Mock)
          })

          it('removes children nodes from nodes cache', () => {
            expect(treeManager.nodesCache.getById(view1Node.id)).toBe(undefined)
            expect(treeManager.nodesCache.getById(view2Node.id)).toBe(undefined)
            expect(treeManager.nodesCache.getById(view3Node.id)).toBe(undefined)
          })
        })
      })

      describe('Node refreshing behavior', () => {
        let $component: JQuery
        let $newEls: JQuery

        let appNode: Node
        let nodes: Record<string, Node>

        beforeEach(() => {
          treeManager.createTree()
          $newEls = $(nodesForRefresh)

          $component = $('#component1')
          const componentNodeId = $component.data('vtree-node-id')
          appNode = treeManager.nodesCache.getById(componentNodeId)
        })

        describe('.refresh', () => {
          let newNodesList: Node[]

          beforeEach(() => {
            $component.append($newEls)
            nodes = {}
            newNodesList = []
            treeManager.refresh(appNode)

            for (let el of 'view1 view2 view3 component2 view4 view5 view6 view7 view8 view9'.split(' ')) {
              const id = $('#' + el).data('vtree-node-id')
              nodes[el] = treeManager.nodesCache.getById(id)
              newNodesList.push(nodes[el])
            }
          })

          it('has nodes initialized for new view elements', () => {
            const $els = $newEls.wrap('<div />').parent().find(config.selector)
            const expectedElsArray = $els.toArray()
            const newElsArray = expectedElsArray.map(el => {
              const id = $(el).data('vtree-node-id')
              return treeManager.nodesCache.getById(id).el
            })

            expect(newElsArray).toEqual(expectedElsArray)
          })

          it('sets correct parents for new nodes', () => {
            expect(nodes['view1'].parent).toBe(appNode)
            expect(nodes['view2'].parent).toBe(appNode)
            expect(nodes['view3'].parent).toBe(nodes['view2'])
            expect(nodes['view4'].parent).toBe(appNode)
            expect(nodes['view5'].parent).toBe(nodes['view4'])
            expect(nodes['view6'].parent).toBe(nodes['view5'])
            expect(nodes['view7'].parent).toBe(nodes['view4'])
            expect(nodes['component2'].parent).toBe(nodes['view4'])
            expect(nodes['view8'].parent).toBe(nodes['component2'])
            expect(nodes['view9'].parent).toBe(nodes['component2'])
          })

          it('sets correct children for new nodes', () => {
            expect(appNode.children).toEqual([nodes['view1'], nodes['view2'], nodes['view4']])
            expect(nodes['view1'].children).toEqual([])
            expect(nodes['view2'].children).toEqual([nodes['view3']])
            expect(nodes['view3'].children).toEqual([])
            expect(nodes['view4'].children).toEqual([nodes['view5'], nodes['view7'], nodes['component2']])
            expect(nodes['view5'].children).toEqual([nodes['view6']])
            expect(nodes['view6'].children).toEqual([])
            expect(nodes['view7'].children).toEqual([])
            expect(nodes['component2'].children).toEqual([nodes['view8'], nodes['view9']])
            expect(nodes['view8'].children).toEqual([])
            expect(nodes['view9'].children).toEqual([])
          })

          it('activates new nodes', () => {
            for (let node of newNodesList) {
              expect(node.isActivated).toBe(true)
            }
          })
        })
      })
    })
  })
})
