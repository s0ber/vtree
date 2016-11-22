VtreeNodesCache = require('src/vtree_src/vtree_nodes_cache')

describe 'VtreeNodesCache', ->

  beforeEach ->
    @nodesCache = new VtreeNodesCache

  describe 'Initial state of cache', ->

    describe '.show', ->
      it 'returns empty hash by default', ->
        nodesHash = @nodesCache.show()
        expect(nodesHash).to.be.an 'object'
        expect(nodesHash).to.be.eql {}

    describe '.showRootNodes', ->
      it 'returns empty list by default', ->
        rootNodesList = @nodesCache.showRootNodes()
        expect(rootNodesList).to.be.an 'array'
        expect(rootNodesList).to.be.eql []

  describe 'Cache management actions', ->

    beforeEach ->
      @node = id: 1, whatever: 'content'
      @secondNode = id: 2, whatever: 'more content'

    describe '.add', ->
      it 'adds node to nodes hash', ->
        @nodesCache.add(@node)
        expect(@nodesCache.show()).to.be.eql {1: @node}

        @nodesCache.add(@secondNode)
        expect(@nodesCache.show()).to.be.eql {1: @node, 2: @secondNode}

    describe '.addAsRoot', ->
      it 'adds node to root nodes list', ->
        @nodesCache.add(@node)
        @nodesCache.addAsRoot(@node)
        expect(@nodesCache.showRootNodes()).to.be.eql [@node]

        @nodesCache.add(@secondNode)
        @nodesCache.addAsRoot(@secondNode)
        expect(@nodesCache.showRootNodes()).to.be.eql [@node, @secondNode]

    describe '.getById', ->
      it "returns node by it's index", ->
        @nodesCache.add(@node)

        returnedNode = @nodesCache.getById(@node.id)
        expect(returnedNode).to.be.equal(@node)

    describe '.removeById', ->
      it 'removes node from nodes hash by provided id', ->
        @nodesCache.add(@node)
        @nodesCache.add(@secondNode)
        @nodesCache.removeById(2)

        nodesHash = @nodesCache.show()
        expect(nodesHash).to.be.eql {1: @node}

      it 'removes node from root nodes list by provided id', ->
        @nodesCache.add(@node)
        @nodesCache.add(@secondNode)

        @nodesCache.addAsRoot(@node)
        @nodesCache.addAsRoot(@secondNode)
        @nodesCache.removeById(1)

        rootNodesList = @nodesCache.showRootNodes()
        expect(rootNodesList).to.be.eql [@secondNode]

    describe '.clear', ->
      it 'clears nodes hash', ->
        @nodesCache.add(@node)
        @nodesCache.add(@secondNode)
        @nodesCache.clear()

        nodesHash = @nodesCache.show()
        expect(nodesHash).to.be.an 'object'
        expect(nodesHash).to.be.eql {}

      it 'clears root nodes list', ->
        @nodesCache.add(@node)
        @nodesCache.add(@secondNode)
        @nodesCache.addAsRoot(@node)
        @nodesCache.addAsRoot(@secondNode)

        @nodesCache.clear()

        rootNodesList = @nodesCache.showRootNodes()
        expect(rootNodesList).to.be.an 'array'
        expect(rootNodesList).to.be.eql []
