ViewNodesCache = require('vtree/view_nodes_cache')

describe 'ViewNodesCache', ->

  beforeEach ->
    @viewNodesCache = new ViewNodesCache

  describe 'Initial state of cache', ->

    describe '.show', ->
      it 'returns empty hash by default', ->
        nodesHash = @viewNodesCache.show()
        expect(nodesHash).to.be.an 'object'
        expect(nodesHash).to.be.eql {}

    describe '.showRootNodes', ->
      it 'returns empty list by default', ->
        rootNodesList = @viewNodesCache.showRootNodes()
        expect(rootNodesList).to.be.an 'array'
        expect(rootNodesList).to.be.eql []

  describe 'Cache management actions', ->

    beforeEach ->
      @node = id: 1, whatever: 'content'
      @secondNode = id: 2, whatever: 'more content'

    describe '.add', ->
      it 'adds node to nodes hash', ->
        @viewNodesCache.add(@node)
        expect(@viewNodesCache.show()).to.be.eql {1: @node}

        @viewNodesCache.add(@secondNode)
        expect(@viewNodesCache.show()).to.be.eql {1: @node, 2: @secondNode}

    describe '.addAsRoot', ->
      it 'adds node to root nodes list', ->
        @viewNodesCache.addAsRoot(@node)
        expect(@viewNodesCache.showRootNodes()).to.be.eql [@node]

        @viewNodesCache.addAsRoot(@secondNode)
        expect(@viewNodesCache.showRootNodes()).to.be.eql [@node, @secondNode]

    describe '.getById', ->
      it "returns node by it's index", ->
        @viewNodesCache.add(@node)

        returnedNode = @viewNodesCache.getById(@node.id)
        expect(returnedNode).to.be.equal(@node)

    describe '.removeById', ->
      it 'removes node from nodes hash by provided id', ->
        @viewNodesCache.add(@node)
        @viewNodesCache.add(@secondNode)
        @viewNodesCache.removeById(2)

        nodesHash = @viewNodesCache.show()
        expect(nodesHash).to.be.eql {1: @node}

      it 'removes node from root nodes list by provided id', ->
        @viewNodesCache.addAsRoot(@node)
        @viewNodesCache.addAsRoot(@secondNode)
        @viewNodesCache.removeById(1)

        rootNodesList = @viewNodesCache.showRootNodes()
        expect(rootNodesList).to.be.eql [@secondNode]

    describe '.clear', ->
      it 'clears nodes hash', ->
        @viewNodesCache.add(@node)
        @viewNodesCache.add(@secondNode)
        @viewNodesCache.clear()

        nodesHash = @viewNodesCache.show()
        expect(nodesHash).to.be.an 'object'
        expect(nodesHash).to.be.eql {}

      it 'clears root nodes list', ->
        @viewNodesCache.addAsRoot(@node)
        @viewNodesCache.addAsRoot(@secondNode)
        @viewNodesCache.clear()

        rootNodesList = @viewNodesCache.showRootNodes()
        expect(rootNodesList).to.be.an 'array'
        expect(rootNodesList).to.be.eql []
