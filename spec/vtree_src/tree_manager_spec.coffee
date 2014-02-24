TreeManager = require('vtree/tree_manager')

describe 'TreeManager', ->

  $render = (name) ->
    $(window.__html__["spec/fixtures/#{name}.html"])


  describe 'ViewNode callbacks', ->
    before ->
      sinon.spy(TreeManager::, 'initViewHooks')

    it 'initializes hooks for view nodes when creating instance', ->
      @treeManager = new TreeManager
      expect(@treeManager.initViewHooks).to.be.calledOnce

    beforeEach ->
      @$el = $('<div />')

    describe '.initViewHooks', ->
      it 'saves new ViewHooks object in @viewHooks', ->
        @treeManager = new TreeManager
        expect(@treeManager.viewHooks.constructor).to.match(/ViewHooks/)

      it 'adds @addViewNodeIdToElData init hook', ->
        sinon.spy(TreeManager::, 'addViewNodeIdToElData')
        @treeManager = new TreeManager
        viewNode = new @treeManager.ViewNode(@$el, @treeManager.viewHooks)
        expect(@treeManager.addViewNodeIdToElData).to.be.calledOnce

      it 'adds @addRemoveEventHandlerToEl init hook', ->
        sinon.spy(TreeManager::, 'addRemoveEventHandlerToEl')
        @treeManager = new TreeManager
        viewNode = new @treeManager.ViewNode(@$el, @treeManager.viewHooks)
        expect(@treeManager.addRemoveEventHandlerToEl).to.be.calledOnce

      it 'adds @initView activation hook', ->
        sinon.spy(TreeManager::, 'initView')
        @treeManager = new TreeManager
        viewNode = new @treeManager.ViewNode(@$el, @treeManager.viewHooks)
        viewNode.activate()
        expect(@treeManager.initView).to.be.calledOnce

      it 'adds @unloadView unload hook', ->
        sinon.spy(TreeManager::, 'unloadView')
        @treeManager = new TreeManager
        viewNode = new @treeManager.ViewNode(@$el, @treeManager.viewHooks)
        viewNode.unload()
        expect(@treeManager.unloadView).to.be.calledOnce

    describe '.addViewNodeIdToElData', ->
      it "adds viewNodeId to node's $element", ->
        $el = $('<div />')
        viewNode = new @treeManager.ViewNode($el)
        @treeManager.addViewNodeIdToElData(viewNode)

        expect($el.data('view-node-id')).to.be.eql viewNode.id

    describe '.addRemoveEventHandlerToEl', ->
      it "adds viewNodeId to node's $element", ->
        $el = $('<div />')
        viewNode = new @treeManager.ViewNode($el, @treeManager.viewHooks)
        sinon.spy(@treeManager, 'removeNode')
        viewNode.$el.remove()
        expect(@treeManager.removeNode).to.be.calledOnce

    describe '.initView', ->
      it 'initializes ViewWrapper instance', ->
        $el = $('<div />')
        viewNode = new @treeManager.ViewNode($el)
        @treeManager.initView(viewNode)

        expect(viewNode.viewWrapper.constructor).to.match(/ViewWrapper/)

    describe '.unloadView', ->
      it 'unloads ViewWrapper instance', ->
        viewNode = {}
        viewNode.viewWrapper = {unload: sinon.spy()}
        @treeManager.unloadView(viewNode)
        expect(viewNode.viewWrapper.unload).to.be.calledOnce

  describe 'Constructor and tree building behavior', ->
    beforeEach ->
      @options = {appSelector: '[data-app]', viewSelector: '[data-view]'}
      @treeManager = new TreeManager(@options)

    describe '.constructor', ->
      it 'saves provided options in @options', ->
        expect(@treeManager.options).to.be.equal @options
        expect(@treeManager.options).to.have.property 'appSelector'
        expect(@treeManager.options).to.have.property 'viewSelector'

      it 'sets reference to ViewNode constructor in @ViewNode', ->
        expect(@treeManager.ViewNode).to.match(/ViewNode/)

      it 'sets reference to ViewWrapper constructor in @ViewWrapper', ->
        expect(@treeManager.ViewWrapper).to.match(/ViewWrapper/)

      it 'creates NodesCache instance in @nodesCache', ->
        expect(@treeManager.nodesCache.constructor).to.match(/NodesCache/)

      it 'has empty @initialNodes list', ->
        expect(@treeManager.initialNodes).to.be.an('array')
        expect(@treeManager.initialNodes).to.be.eql []

    describe '.createTree', ->
      it 'creates viewNodes for initial dom state', ->
        sinon.spy(@treeManager, 'setInitialNodes')
        @treeManager.createTree()
        expect(@treeManager.setInitialNodes).to.be.calledOnce

      it 'sets parents for initial viewNodes', ->
        sinon.spy(@treeManager, 'setParentsForInitialNodes')
        @treeManager.createTree()
        expect(@treeManager.setParentsForInitialNodes).to.be.calledOnce

      it 'sets children for initial viewNodes', ->
        sinon.spy(@treeManager, 'setChildrenForInitialNodes')
        @treeManager.createTree()
        expect(@treeManager.setChildrenForInitialNodes).to.be.calledOnce

      it 'activates initial viewNodes', ->
        sinon.spy(@treeManager, 'activateInitialNodes')
        @treeManager.createTree()
        expect(@treeManager.activateInitialNodes).to.be.calledOnce


    describe 'Tree building behavior', ->
      beforeEach ->
        @$els = $render('nodes_with_data_view')

        $('body').empty()
        $('body').append(@$els)

      describe '.setInitialNodes', ->
        it 'creates list of elements for specified "app" and "view" selectors and initializes viewNodes for them', ->
          sinon.spy(@treeManager, 'ViewNode')
          @treeManager.setInitialNodes()
          expect(@treeManager.ViewNode.callCount).to.be.eql 4

        it 'has viewNodes pointed to corresponding dom elements in @initialNodes list', ->
          $els = $('body').find(@treeManager.viewSelector())
          expectedElsArray = $els.toArray()

          @treeManager.setInitialNodes()
          initialNodesEls = @treeManager.initialNodes.map('el')
          expect(initialNodesEls).to.be.eql expectedElsArray

        it 'provides @viewHooks to viewNodes constructor', ->
          @treeManager.setInitialNodes()
          firstViewNode = @treeManager.initialNodes[0]
          expect(firstViewNode.viewHooks).to.be.equal @treeManager.viewHooks

        it 'saves viewNodes to NodesCache', ->
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

          appNodeId = $app.data('view-node-id')
          view1NodeId = $view1.data('view-node-id')
          view2NodeId = $view2.data('view-node-id')
          view3NodeId = $view3.data('view-node-id')

          @appNode   = @treeManager.nodesCache.getById(appNodeId)
          @view1Node = @treeManager.nodesCache.getById(view1NodeId)
          @view2Node = @treeManager.nodesCache.getById(view2NodeId)
          @view3Node = @treeManager.nodesCache.getById(view3NodeId)

        describe '.setParentsForNodes', ->
          beforeEach ->
            @treeManager.setParentsForNodes(@nodes)

          it 'looks for closest view dom element and sets it as parent for provided viewNodes', ->
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
            sinon.spy(@appNode, 'activate')
            sinon.spy(@view1Node, 'activate')
            sinon.spy(@view2Node, 'activate')
            sinon.spy(@view3Node, 'activate')

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
          it 'activates root view nodes in initial viewNodes list', ->
            sinon.spy(@treeManager, 'activateRootNodes')
            initialNodes = @treeManager.initialNodes

            @treeManager.setParentsForNodes(@nodes)
            @treeManager.setChildrenForNodes(@nodes)
            @treeManager.activateInitialNodes(@nodes)

            expect(@treeManager.activateRootNodes).to.be.calledOnce
            expect(@treeManager.activateRootNodes.lastCall.args[0]).to.be.equal initialNodes

        describe '.activateRootNodes', ->
          it 'searches for root viewNodes in provided viewNodes list and activates them', ->
            @treeManager.setParentsForNodes(@nodes)
            @treeManager.setChildrenForNodes(@nodes)
            @treeManager.activateRootNodes(@nodes)
            expect(@appNode.isActivated()).to.be.true

        describe '.removeNode', ->
          beforeEach ->
            @treeManager.setParentsForNodes(@nodes)
            @treeManager.setChildrenForNodes(@nodes)

          it 'does nothing if viewNode is already removed', ->
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
            it 'being called whenever dom element with viewNode being removed from DOM', ->
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

          it "recursively removes provided viewNode's children", ->
            expect(@view1Node.remove).to.be.calledOnce
            expect(@view2Node.remove).to.be.calledOnce
            expect(@view3Node.remove).to.be.calledOnce

          it 'removes children viewNodes in proper order', ->
            expect(@view1Node.remove).to.be.calledBefore(@view2Node.remove)
            expect(@view3Node.remove).to.be.calledBefore(@view2Node.remove)

          it 'removes children viewNodes from nodes cache', ->
            expect(@treeManager.nodesCache.getById(@view1Node.id)).to.be.undefined
            expect(@treeManager.nodesCache.getById(@view2Node.id)).to.be.undefined
            expect(@treeManager.nodesCache.getById(@view3Node.id)).to.be.undefined

      describe 'ViewNode refreshing behavior', ->
        beforeEach ->
          @treeManager.createTree()
          @$app = $('#app1')
          $view1 = $('#view1')
          $view2 = $('#view2')
          $view3 = $('#view3')

          @$newEls = $render('nodes_for_refresh')

          appNodeId = @$app.data('view-node-id')
          view1NodeId = $view1.data('view-node-id')
          view2NodeId = $view2.data('view-node-id')
          view3NodeId = $view3.data('view-node-id')

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
              id = $('#' + el).data('view-node-id')
              @[el + 'Node'] = @treeManager.nodesCache.getById(id)
              @newNodesList.push(@[el + 'Node'])

          it 'has viewNodes initialized for new view elements', ->
            $els = @$newEls.wrap('<div />').parent().find(@treeManager.viewSelector())
            expectedElsArray = $els.toArray()
            newElsArray = expectedElsArray.map((el) =>
              id = $(el).data('view-node-id')
              @treeManager.nodesCache.getById(id).el
            )

            expect(newElsArray).to.be.eql expectedElsArray

          it 'sets correct parents for new viewNodes', ->
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

          it 'sets correct children for new viewNodes', ->
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

          it 'activates new viewNodes', ->
            for node in @newNodesList
              expect(node.isActivated()).to.be.true
