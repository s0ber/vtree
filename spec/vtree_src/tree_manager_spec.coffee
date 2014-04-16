Vtree = modula.require('vtree')
Launcher = modula.require('vtree/launcher')
Node = modula.require('vtree/node')
TreeManager = modula.require('vtree/tree_manager')

describe 'TreeManager', ->

  $render = (name) ->
    $(window.__html__["spec/fixtures/#{name}.html"])


  describe 'Node callbacks', ->
    before ->
      Launcher.initRemoveEvent()
      sinon.spy(TreeManager::, 'initNodeHooks')

    it 'initializes hooks for view nodes when creating instance', ->
      @treeManager = new TreeManager
      expect(@treeManager.initNodeHooks).to.be.calledOnce

    beforeEach ->
      @$el = $('<div />')

    describe '.initNodeHooks', ->
      it 'saves new Hooks object in @hooks', ->
        @treeManager = new TreeManager
        expect(@treeManager.hooks.constructor).to.match(/Hooks/)

      it 'adds @addNodeIdToElData init hook', ->
        sinon.spy(TreeManager::, 'addNodeIdToElData')
        @treeManager = new TreeManager
        node = new Node(@$el, @treeManager.hooks)
        expect(@treeManager.addNodeIdToElData).to.be.calledOnce

      it 'adds @addRemoveEventHandlerToEl init hook', ->
        sinon.spy(TreeManager::, 'addRemoveEventHandlerToEl')
        @treeManager = new TreeManager
        node = new Node(@$el, @treeManager.hooks)
        expect(@treeManager.addRemoveEventHandlerToEl).to.be.calledOnce

      it 'adds @addNodeWrapper activation hook', ->
        sinon.spy(TreeManager::, 'addNodeWrapper')
        @treeManager = new TreeManager
        node = new Node(@$el, @treeManager.hooks)
        node.activate()
        expect(@treeManager.addNodeWrapper).to.be.calledOnce

      it 'adds @unloadView unload hook', ->
        sinon.spy(TreeManager::, 'unloadView')
        @treeManager = new TreeManager
        node = new Node(@$el, @treeManager.hooks)
        node.unload()
        expect(@treeManager.unloadView).to.be.calledOnce

      it 'adds @deleteNodeWrapper unload hook', ->
        sinon.spy(TreeManager::, 'deleteNodeWrapper')
        @treeManager = new TreeManager
        node = new Node(@$el, @treeManager.hooks)
        node.unload()
        expect(@treeManager.deleteNodeWrapper).to.be.calledOnce

    describe '.addNodeIdToElData', ->
      it "adds nodeId to node's $element", ->
        $el = $('<div />')
        node = new Node($el)
        @treeManager.addNodeIdToElData(node)

        expect($el.data('vtree-node-id')).to.be.eql node.id

    describe '.addRemoveEventHandlerToEl', ->
      it "adds calls @treemanager.removeNode with $el node provided", ->
        $el = $('<div />')
        node = new Node($el, @treeManager.hooks)
        sinon.spy(@treeManager, 'removeNode')
        node.$el.remove()
        expect(@treeManager.removeNode).to.be.calledOnce

    describe '.addNodeWrapper', ->
      it 'initializes NodeWrapper instance', ->
        $el = $('<div />')
        node = new Node($el)
        @treeManager.addNodeWrapper(node)

        expect(node.nodeWrapper.constructor).to.match(/NodeWrapper/)

    describe '.unloadView', ->
      it 'unloads NodeWrapper instance', ->
        node = {}
        node.nodeWrapper = {unload: sinon.spy()}
        @treeManager.unloadView(node)
        expect(node.nodeWrapper.unload).to.be.calledOnce

    describe '.deleteNodeWrapper', ->
      it 'deletes NodeWrapper instance from corresponding Node', ->
        node = {nodeWrapper: {}}
        @treeManager.deleteNodeWrapper(node)
        expect(node.nodeWrapper).to.be.undefined

  describe 'Constructor and tree building behavior', ->
    beforeEach ->
      @treeManager = new TreeManager()

    describe '.constructor', ->
      it 'creates NodesCache instance in @nodesCache', ->
        expect(@treeManager.nodesCache.constructor).to.match(/NodesCache/)

      it 'has empty @initialNodes list', ->
        expect(@treeManager.initialNodes).to.be.an('array')
        expect(@treeManager.initialNodes).to.be.eql []

    describe '.createTree', ->
      it 'creates nodes for initial dom state', ->
        sinon.spy(@treeManager, 'setInitialNodes')
        @treeManager.createTree()
        expect(@treeManager.setInitialNodes).to.be.calledOnce

      it 'sets parents for initial nodes', ->
        sinon.spy(@treeManager, 'setParentsForInitialNodes')
        @treeManager.createTree()
        expect(@treeManager.setParentsForInitialNodes).to.be.calledOnce

      it 'sets children for initial nodes', ->
        sinon.spy(@treeManager, 'setChildrenForInitialNodes')
        @treeManager.createTree()
        expect(@treeManager.setChildrenForInitialNodes).to.be.calledOnce

      it 'activates initial nodes', ->
        sinon.spy(@treeManager, 'activateInitialNodes')
        @treeManager.createTree()
        expect(@treeManager.activateInitialNodes).to.be.calledOnce


    describe 'Tree building behavior', ->
      beforeEach ->
        @$els = $render('nodes_with_data_view')

        $('body').empty()
        $('body').append(@$els)

      describe '.setInitialNodes', ->

        it 'initialized Node objects for each element for specified "app" and "view" selectors', ->
          @treeManager.setInitialNodes()

          for node in @treeManager.initialNodes
            expect(node.constructor).to.match /Node/

        it 'has nodes pointed to corresponding dom elements in @initialNodes list', ->
          $els = $('body').find(Vtree.config().selector)
          expectedElsArray = _.toArray($els)

          @treeManager.setInitialNodes()
          initialNodesEls = _.map(@treeManager.initialNodes, (node) -> node.el)
          expect(initialNodesEls).to.be.eql expectedElsArray

        it 'provides @hooks to nodes constructor', ->
          @treeManager.setInitialNodes()
          firstNode = @treeManager.initialNodes[0]
          expect(firstNode.hooks).to.be.equal @treeManager.hooks

        it 'saves nodes to NodesCache', ->
          sinon.spy(@treeManager.nodesCache, 'add')
          @treeManager.setInitialNodes()
          expect(@treeManager.nodesCache.add.callCount).to.be.eql 4

      describe '.setParentsForInitialNodes', ->
        it 'sets parents for initial nodes', ->
          sinon.spy(@treeManager, 'setParentsForNodes')
          @treeManager.setInitialNodes()
          initialNodes = @treeManager.initialNodes

          @treeManager.setParentsForInitialNodes()
          expect(@treeManager.setParentsForNodes).to.be.calledOnce
          expect(@treeManager.setParentsForNodes.lastCall.args[0]).to.be.equal initialNodes

      describe '.setChildrenForInitialNodes', ->
        it 'sets children for initial nodes', ->
          sinon.spy(@treeManager, 'setChildrenForNodes')
          @treeManager.setInitialNodes()
          initialNodes = @treeManager.initialNodes

          @treeManager.setChildrenForInitialNodes()
          expect(@treeManager.setChildrenForNodes.firstCall.args[0]).to.be.equal initialNodes

      describe 'Tree setup and activation', ->
        beforeEach ->
          @treeManager.setInitialNodes()
          @nodes = @treeManager.initialNodes

          $app = $('#app1')
          $view1 = $('#view1')
          $view2 = $('#view2')
          $view3 = $('#view3')

          appNodeId = $app.data('vtree-node-id')
          view1NodeId = $view1.data('vtree-node-id')
          view2NodeId = $view2.data('vtree-node-id')
          view3NodeId = $view3.data('vtree-node-id')

          @appNode = @treeManager.nodesCache.getById(appNodeId)
          @view1Node = @treeManager.nodesCache.getById(view1NodeId)
          @view2Node = @treeManager.nodesCache.getById(view2NodeId)
          @view3Node = @treeManager.nodesCache.getById(view3NodeId)

        describe '.setParentsForNodes', ->
          beforeEach ->
            @treeManager.setParentsForNodes(@nodes)

          it 'looks for closest view dom element and sets it as parent for provided nodes', ->
            expect(@view1Node.parent).to.be.equal @appNode
            expect(@view2Node.parent).to.be.equal @appNode
            expect(@view3Node.parent).to.be.equal @view2Node

          it 'sets null reference to node parent if have no parent', ->
            expect(@appNode.parent).to.be.null

          it 'adds node to cache as root if have no parent', ->
            expect(@treeManager.nodesCache.showRootNodes()).to.be.eql [@appNode]

        describe '.setChildrenForNodes', ->
          beforeEach ->
            @treeManager.setParentsForNodes(@nodes)
            @treeManager.setChildrenForNodes(@nodes)

          it 'sets children for provided nodes', ->
            expect(@appNode.children).to.be.eql [@view1Node, @view2Node]
            expect(@view1Node.children).to.be.eql []
            expect(@view2Node.children).to.be.eql [@view3Node]
            expect(@view3Node.children).to.be.eql []

        describe '.activateNode', ->
          beforeEach ->
            @treeManager.setParentsForNodes(@nodes)
            @treeManager.setChildrenForNodes(@nodes)
            @treeManager.activateNode(@appNode)

          it "recursively activates provided node and it's children nodes", ->
            expect(@appNode.isActivated()).to.be.true
            expect(@view1Node.isActivated()).to.be.true
            expect(@view2Node.isActivated()).to.be.true
            expect(@view3Node.isActivated()).to.be.true

          it 'activates nodes in proper order', ->
            expect(@appNode.activate).to.be.calledBefore(@view1Node.activate)
            expect(@view1Node.activate).to.be.calledBefore(@view2Node.activate)
            expect(@view2Node.activate).to.be.calledBefore(@view3Node.activate)

        describe '.activateInitialNodes', ->
          it 'activates root view nodes in initial nodes list', ->
            sinon.spy(@treeManager, 'activateRootNodes')
            initialNodes = @treeManager.initialNodes

            @treeManager.setParentsForNodes(@nodes)
            @treeManager.setChildrenForNodes(@nodes)
            @treeManager.activateInitialNodes(@nodes)

            expect(@treeManager.activateRootNodes).to.be.calledOnce
            expect(@treeManager.activateRootNodes.lastCall.args[0]).to.be.equal initialNodes

        describe '.activateRootNodes', ->
          it 'searches for root nodes in provided nodes list and activates them', ->
            @treeManager.setParentsForNodes(@nodes)
            @treeManager.setChildrenForNodes(@nodes)
            @treeManager.activateRootNodes(@nodes)
            expect(@appNode.isActivated()).to.be.true

        describe '.removeNode', ->
          beforeEach ->
            @treeManager.setParentsForNodes(@nodes)
            @treeManager.setChildrenForNodes(@nodes)

          it 'does nothing if node is already removed', ->
            sinon.spy(@view3Node, 'remove')
            removeCallsCount = @view3Node.remove.callCount

            @view3Node.remove()
            @treeManager.removeNode(@view3Node)
            expect(@view3Node.remove.callCount).to.be.eql(removeCallsCount + 1)

          it "deattaches node from it's parent", ->
            parent = @view3Node.parent
            expect(parent.children.indexOf(@view3Node) > -1).to.be.true

            @treeManager.removeNode(@view3Node)
            expect(parent.children.indexOf(@view3Node) > -1).to.be.false

          it 'removes provided node', ->
            @treeManager.removeNode(@view3Node)
            expect(@view3Node.isRemoved()).to.be.true

          it 'removes child nodes', ->
            sinon.spy(@treeManager, 'removeChildNodes')
            @treeManager.removeNode(@appNode)

            expect(@treeManager.removeChildNodes).to.be.called
            expect(@treeManager.removeChildNodes.firstCall.args[0]).to.be.eql @appNode

          it 'at first removes child nodes', ->
            sinon.spy(@appNode, 'remove')
            sinon.spy(@view1Node, 'remove')

            @treeManager.removeNode(@appNode)
            expect(@view1Node.remove).to.be.calledBefore(@appNode.remove)

          it 'removes node from nodesCache', ->
            nodeId = @appNode.id
            expect(@treeManager.nodesCache.getById(nodeId)).to.be.equal @appNode

            @treeManager.removeNode(@appNode)
            expect(@treeManager.nodesCache.getById(nodeId)).to.be.undefined

          describe 'OnRemove event handling behavior', ->
            it 'being called whenever dom element with node being removed from DOM', ->
              sinon.spy(@treeManager, 'removeNode')
              $('#app1').remove()
              expect(@treeManager.removeNode.callCount).to.be.eql 4

            it 'being called in proper order', ->
              nodes = [@appNode, @view1Node, @view2Node, @view3Node]
              for node in nodes
                sinon.spy(node, 'remove')

              $('#app1').remove()

              for node in nodes
                expect(node.remove).to.be.calledOnce

              expect(@view3Node.remove).to.be.calledBefore(@view2Node.remove)
              expect(@view1Node.remove).to.be.calledBefore(@view2Node.remove)
              expect(@view1Node.remove).to.be.calledBefore(@appNode.remove)
              expect(@view2Node.remove).to.be.calledBefore(@appNode.remove)

        describe '.removeChildNodes', ->
          beforeEach ->
            @treeManager.setParentsForNodes(@nodes)
            @treeManager.setChildrenForNodes(@nodes)

            sinon.spy(@appNode, 'remove')
            sinon.spy(@view1Node, 'remove')
            sinon.spy(@view2Node, 'remove')
            sinon.spy(@view3Node, 'remove')

            @treeManager.removeChildNodes(@appNode)

          it "recursively removes provided node's children", ->
            expect(@view1Node.remove).to.be.calledOnce
            expect(@view2Node.remove).to.be.calledOnce
            expect(@view3Node.remove).to.be.calledOnce

          it 'removes children nodes in proper order', ->
            expect(@view1Node.remove).to.be.calledBefore(@view2Node.remove)
            expect(@view3Node.remove).to.be.calledBefore(@view2Node.remove)

          it 'removes children nodes from nodes cache', ->
            expect(@treeManager.nodesCache.getById(@view1Node.id)).to.be.undefined
            expect(@treeManager.nodesCache.getById(@view2Node.id)).to.be.undefined
            expect(@treeManager.nodesCache.getById(@view3Node.id)).to.be.undefined

      describe 'Node refreshing behavior', ->
        beforeEach ->
          @treeManager.createTree()
          @$app = $('#app1')
          $view1 = $('#view1')
          $view2 = $('#view2')
          $view3 = $('#view3')

          @$newEls = $render('nodes_for_refresh')

          appNodeId = @$app.data('vtree-node-id')
          view1NodeId = $view1.data('vtree-node-id')
          view2NodeId = $view2.data('vtree-node-id')
          view3NodeId = $view3.data('vtree-node-id')

          @appNode   = @treeManager.nodesCache.getById(appNodeId)
          @view1Node = @treeManager.nodesCache.getById(view1NodeId)
          @view2Node = @treeManager.nodesCache.getById(view2NodeId)
          @view3Node = @treeManager.nodesCache.getById(view3NodeId)

        describe '.refresh', ->
          beforeEach ->
            @$app.append(@$newEls)
            @newNodesList = []
            @treeManager.refresh(@appNode)

            for el in 'app2 view4 view5 view6 view7 view8 view9'.split(' ')
              id = $('#' + el).data('vtree-node-id')
              @[el + 'Node'] = @treeManager.nodesCache.getById(id)
              @newNodesList.push(@[el + 'Node'])

          it 'has nodes initialized for new view elements', ->
            $els = @$newEls.wrap('<div />').parent().find(Vtree.config().selector)
            expectedElsArray = $els.toArray()
            newElsArray = expectedElsArray.map((el) =>
              id = $(el).data('vtree-node-id')
              @treeManager.nodesCache.getById(id).el
            )

            expect(newElsArray).to.be.eql expectedElsArray

          it 'sets correct parents for new nodes', ->
            expect(@view1Node.parent).to.be.equal @appNode
            expect(@view2Node.parent).to.be.equal @appNode
            expect(@view3Node.parent).to.be.equal @view2Node
            expect(@view4Node.parent).to.be.equal @appNode
            expect(@view5Node.parent).to.be.equal @view4Node
            expect(@view6Node.parent).to.be.equal @view5Node
            expect(@view7Node.parent).to.be.equal @view4Node
            expect(@app2Node.parent).to.be.equal @view4Node
            expect(@view8Node.parent).to.be.equal @app2Node
            expect(@view9Node.parent).to.be.equal @app2Node

          it 'sets correct children for new nodes', ->
            expect(@appNode.children).to.be.eql [@view1Node, @view2Node, @view4Node]
            expect(@view1Node.children).to.be.eql []
            expect(@view2Node.children).to.be.eql [@view3Node]
            expect(@view3Node.children).to.be.eql []
            expect(@view4Node.children).to.be.eql [@view5Node, @view7Node, @app2Node]
            expect(@view5Node.children).to.be.eql [@view6Node]
            expect(@view6Node.children).to.be.eql []
            expect(@view7Node.children).to.be.eql []
            expect(@app2Node.children).to.be.eql [@view8Node, @view9Node]
            expect(@view8Node.children).to.be.eql []
            expect(@view9Node.children).to.be.eql []

          it 'activates new nodes', ->
            for node in @newNodesList
              expect(node.isActivated()).to.be.true
