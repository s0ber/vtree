import $ from 'jquery'
import VtreeNodesCache from '../../src/vtree_src/vtree_nodes_cache'
import Node from '../../src/vtree_src/node'

describe('VtreeNodesCache', () => {
  let nodesCache: VtreeNodesCache

  beforeEach(() => {
    nodesCache = new VtreeNodesCache
  })

  describe('Initial state of cache', () => {
    describe('.show', () => {
      it('returns empty hash by default', () => {
        const nodesHash = nodesCache.show()
        expect(nodesHash).toEqual({})
      })
    })

    describe('.showRootNodes', () => it('returns empty list by default', () => {
      const rootNodesList = nodesCache.showRootNodes()
      expect(rootNodesList).toEqual([])
    }))
  })

  describe('Cache management actions', () => {
    let node: Node
    let secondNode: Node

    beforeEach(() => {
      node = new Node($('div'))
      secondNode = new Node($('div'))
    })

    describe('.add', () => {
      it('adds node to nodes hash', () => {
        nodesCache.add(node)
        expect(nodesCache.show()).toEqual({[node.id]: node})

        nodesCache.add(secondNode)
        expect(nodesCache.show()).toEqual({[node.id]: node, [secondNode.id]: secondNode})
      })
    })

    describe('.addAsRoot', () => {
      it('adds node to root nodes list', () => {
        nodesCache.add(node)
        nodesCache.addAsRoot(node)
        expect(nodesCache.showRootNodes()).toEqual([node])

        nodesCache.add(secondNode)
        nodesCache.addAsRoot(secondNode)
        expect(nodesCache.showRootNodes()).toEqual([node, secondNode])
      })
    })

    describe('.getById', () => {
      it("returns node by it's index", () => {
        nodesCache.add(node)

        const returnedNode = nodesCache.getById(node.id)
        expect(returnedNode).toEqual(node)
      })
    })

    describe('.removeById', () => {
      it('removes node from nodes hash by provided id', () => {
        nodesCache.add(node)
        nodesCache.add(secondNode)
        nodesCache.removeById(secondNode.id)

        const nodesHash = nodesCache.show()
        expect(nodesHash).toEqual({ [node.id]: node })
      })

      it('removes node from root nodes list by provided id', () => {
        nodesCache.add(node)
        nodesCache.add(secondNode)

        nodesCache.addAsRoot(node)
        nodesCache.addAsRoot(secondNode)
        nodesCache.removeById(node.id)

        const rootNodesList = nodesCache.showRootNodes()
        expect(rootNodesList).toEqual([secondNode])
      })
    })

    describe('.clear', () => {
      it('clears nodes hash', () => {
        nodesCache.add(node)
        nodesCache.add(secondNode)
        nodesCache.clear()

        const nodesHash = nodesCache.show()
        expect(nodesHash).toEqual({})
      })

      it('clears root nodes list', () => {
        nodesCache.add(node)
        nodesCache.add(secondNode)
        nodesCache.addAsRoot(node)
        nodesCache.addAsRoot(secondNode)

        nodesCache.clear()

        const rootNodesList = nodesCache.showRootNodes()
        expect(rootNodesList).toEqual([])
      })
    })
  })
})
