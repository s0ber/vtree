NodeWrapper = require('src/vtree_src/node_wrapper')
nodesForRefresh = require('../fixtures/nodes_for_refresh')
nodesWithDataView = require('../fixtures/nodes_with_data_view')
Configuration = require('src/configuration')
Hooks = require('src/vtree_src/hooks')
TreeManager = require('src/vtree_src/tree_manager')

Node = class
  $el: $('')
  el: ''

describe 'NodeWrapper', ->

  before ->
    @launcherHooks = new Hooks()
    sinon.spy(@launcherHooks, 'init')
    sinon.spy(@launcherHooks, 'unload')

  describe 'Basic methods', ->
    beforeEach ->
      @config = new Configuration()
      @$el = $('<div />')
      @hooks = new Hooks()
      @node = new Node(@$el)
      @nodeWrapper = new NodeWrapper(@node, @config, @launcherHooks)

    describe '.constructor', ->
      it 'saves reference to provided view node in @node', ->
        expect(@nodeWrapper.node).to.be.equal @node

      it 'saves reference to node.$el in @$el', ->
        expect(@nodeWrapper.$el).to.be.equal @node.$el

      it 'saves reference to node.el in @el', ->
        expect(@nodeWrapper.el).to.be.equal @node.el

      it 'identifies view', ->
        sinon.spy(NodeWrapper::, 'identifyNodeAttributes')
        node = new Node(@$el)
        nodeWrapper = new NodeWrapper(node, @config, @launcherHooks)
        expect(nodeWrapper.identifyNodeAttributes).to.be.calledOnce

      it 'initializes new Vtree node', ->
        sinon.spy(NodeWrapper::, 'initNodeDataObject')
        node = new Node(@$el)
        nodeWrapper = new NodeWrapper(node, @config, @launcherHooks)
        expect(nodeWrapper.initNodeDataObject).to.be.calledOnce

    describe '.initNodeDataObject', ->
      it 'calls Hooks init hooks', ->
        initialCallCount = @launcherHooks.init.callCount
        @nodeWrapper.initNodeDataObject()
        expect(@launcherHooks.init.callCount).to.be.eql(initialCallCount + 1)

      it 'provides nodeData object to init call', ->
        object = @launcherHooks.init.lastCall.args[0]
        expect(object.constructor).to.match(/NodeData/)

    describe '.unload', ->
      it 'calls Hooks unload hooks', ->
        initialCallCount = @launcherHooks.unload.callCount
        @nodeWrapper.unload()
        expect(@launcherHooks.unload.callCount).to.be.eql(initialCallCount + 1)

      it 'provides nodeData object to init call', ->
        @nodeWrapper.unload()
        object = @launcherHooks.unload.lastCall.args[0]
        expect(object.constructor).to.match(/NodeData/)

      it 'deletes reference to nodeData object', ->
        @nodeWrapper.unload()
        expect(@nodeWrapper.nodeData).to.be.undefined

      it 'deletes reference to node object', ->
        @nodeWrapper.unload()
        expect(@nodeWrapper.node).to.be.undefined

  describe 'View initialization', ->

    prepareFixtureData = ->
      $els = $(nodesWithDataView())
      $newEls = $(nodesForRefresh())

      $('body').empty().append($els)
      $('#component1').append($newEls)

      config = new Configuration()
      treeManager = new TreeManager(config, new Hooks())
      treeManager.setInitialNodes()
      treeManager.setParentsForInitialNodes()
      treeManager.setChildrenForInitialNodes()

      componentNodeId = $('#component1').data('vtree-node-id')
      @component1Node = treeManager.nodesCache.getById(componentNodeId)
      @component1Node.activate()

      # order matters here
      for view in 'view1 view2 view3 view4 view5 view6 view7 component2 view8 view9'.split(' ')
        id = $('#' + view).data('vtree-node-id')
        @["#{view}Node"] = treeManager.nodesCache.getById(id)
        @["#{view}Node"].activate()

    beforeEach ->
      prepareFixtureData.apply(@)

    describe '.isComponentIndex', ->
      it 'checks if node should initialize a component index', ->
        expect(@component1Node.nodeWrapper.isComponentIndex()).to.be.true
        expect(@view1Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view2Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view3Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view4Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view5Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view6Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view7Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@component2Node.nodeWrapper.isComponentIndex()).to.be.true
        expect(@view8Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view9Node.nodeWrapper.isComponentIndex()).to.be.false

    describe '.isStandAlone', ->
      it 'checks if node is a stand alone node and not a part of a component', ->
        expect(@component1Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view1Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view2Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view3Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view4Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view5Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view6Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view7Node.nodeWrapper.isStandAlone()).to.be.true
        expect(@component2Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view8Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view9Node.nodeWrapper.isStandAlone()).to.be.true

    describe '.identifyNodeAttributes', ->
      it 'identifies current node namespace name', ->
        expect(@component1Node.nodeWrapper.namespaceName).to.be.eql 'component_namespace'
        expect(@view1Node.nodeWrapper.namespaceName).to.be.eql 'component_namespace'
        expect(@view2Node.nodeWrapper.namespaceName).to.be.eql 'component_namespace'
        expect(@view3Node.nodeWrapper.namespaceName).to.be.eql 'component_namespace'
        expect(@view4Node.nodeWrapper.namespaceName).to.be.eql 'component_namespace'
        expect(@view5Node.nodeWrapper.namespaceName).to.be.eql 'component_namespace'
        expect(@view6Node.nodeWrapper.namespaceName).to.be.eql 'component_namespace'
        expect(@view7Node.nodeWrapper.namespaceName).to.be.eql 'test_namespace'
        expect(@component2Node.nodeWrapper.namespaceName).to.be.eql 'component_namespace'
        expect(@view8Node.nodeWrapper.namespaceName).to.be.eql 'component_namespace'
        expect(@view9Node.nodeWrapper.namespaceName).to.be.eql 'test_namespace'

      it 'identifies current node view name', ->
        expect(@component1Node.nodeWrapper.nodeName).to.be.eql 'index'
        expect(@view1Node.nodeWrapper.nodeName).to.be.eql 'test_view1'
        expect(@view2Node.nodeWrapper.nodeName).to.be.eql 'test_view2'
        expect(@view3Node.nodeWrapper.nodeName).to.be.eql 'test_view3'
        expect(@view4Node.nodeWrapper.nodeName).to.be.eql 'test_view4'
        expect(@view5Node.nodeWrapper.nodeName).to.be.eql 'test_view5'
        expect(@view6Node.nodeWrapper.nodeName).to.be.eql 'test_view6'
        expect(@view7Node.nodeWrapper.nodeName).to.be.eql 'test_view7'
        expect(@component2Node.nodeWrapper.nodeName).to.be.eql 'index'
        expect(@view8Node.nodeWrapper.nodeName).to.be.eql 'test_view8'
        expect(@view9Node.nodeWrapper.nodeName).to.be.eql 'test_view9'

    describe '.isComponentIndex', ->
      it 'checks if node should initialize a component index', ->
        expect(@component1Node.nodeWrapper.isComponentIndex()).to.be.true
        expect(@view1Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view2Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view3Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view4Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view5Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view6Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view7Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@component2Node.nodeWrapper.isComponentIndex()).to.be.true
        expect(@view8Node.nodeWrapper.isComponentIndex()).to.be.false
        expect(@view9Node.nodeWrapper.isComponentIndex()).to.be.false

    describe '.componentIndexNode', ->
      context 'node is a component index node', ->
        it 'returns itself', ->
          expect(@component1Node.nodeWrapper.componentIndexNode()).to.be.null
          expect(@component2Node.nodeWrapper.componentIndexNode()).to.be.null

      context 'node is stand alone', ->
        it 'returns null', ->
          expect(@view7Node.nodeWrapper.componentIndexNode()).to.be.null
          expect(@view9Node.nodeWrapper.componentIndexNode()).to.be.null

      context 'node is a part of a component', ->
        it "provides reference to node's component index node", ->
          expect(@view1Node.nodeWrapper.componentIndexNode()).to.be.equal @component1Node
          expect(@view2Node.nodeWrapper.componentIndexNode()).to.be.equal @component1Node
          expect(@view3Node.nodeWrapper.componentIndexNode()).to.be.equal @component1Node
          expect(@view4Node.nodeWrapper.componentIndexNode()).to.be.equal @component1Node
          expect(@view5Node.nodeWrapper.componentIndexNode()).to.be.equal @component1Node
          expect(@view6Node.nodeWrapper.componentIndexNode()).to.be.equal @component1Node
          expect(@view8Node.nodeWrapper.componentIndexNode()).to.be.equal @component2Node

    describe '.isStandAlone', ->
      it 'checks if node is stand alone and not a part of a component', ->
        expect(@component1Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view1Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view2Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view3Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view4Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view5Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view6Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view7Node.nodeWrapper.isStandAlone()).to.be.true
        expect(@component2Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view8Node.nodeWrapper.isStandAlone()).to.be.false
        expect(@view9Node.nodeWrapper.isStandAlone()).to.be.true

    describe '.initNodeData', ->
      beforeEach ->
        @component1Id = @component1Node.nodeWrapper.nodeData.componentId
        @component2Id = @component2Node.nodeWrapper.nodeData.componentId

        @component1NodeData = @component1Node.nodeWrapper.nodeData
        @view1NodeData = @view1Node.nodeWrapper.nodeData
        @view2NodeData = @view2Node.nodeWrapper.nodeData
        @view3NodeData = @view3Node.nodeWrapper.nodeData
        @view4NodeData = @view4Node.nodeWrapper.nodeData
        @view5NodeData = @view5Node.nodeWrapper.nodeData
        @view6NodeData = @view6Node.nodeWrapper.nodeData
        @view7NodeData = @view7Node.nodeWrapper.nodeData
        @component2NodeData = @component2Node.nodeWrapper.nodeData
        @view8NodeData = @view8Node.nodeWrapper.nodeData
        @view9NodeData = @view9Node.nodeWrapper.nodeData

      it 'returns NodeData object based on current state of NodeWrapper', ->
        @$el = $('<div />')
        @node = new Node(@$el)
        @config = new Configuration()
        @nodeWrapper = new NodeWrapper(@node, @config, @launcherHooks)
        object = @nodeWrapper.initNodeData()
        expect(object.constructor).to.match(/NodeData/)

      it 'sets correct data to all NodeData objects', ->
        expect(@component1NodeData).to.have.property('el', @component1Node.el)
        expect(@component1NodeData).to.have.property('$el', @component1Node.$el)
        expect(@component1NodeData).to.have.property('isComponentIndex', true)
        expect(@component1NodeData).to.have.property('isComponentPart', true)
        expect(@component1NodeData).to.have.property('isStandAlone', false)
        expect(@component1NodeData).to.have.property('componentId', @component1Id)
        expect(@component1NodeData).to.have.property('componentIndexNode', null)
        expect(@component1NodeData).to.have.property('nodeName', 'Index')
        expect(@component1NodeData).to.have.property('nodeNameUnderscored', 'index')
        expect(@component1NodeData).to.have.property('componentName', 'TestComponent')
        expect(@component1NodeData).to.have.property('componentNameUnderscored', 'test_component')
        expect(@component1NodeData).to.have.property('namespaceName', 'ComponentNamespace')
        expect(@component1NodeData).to.have.property('namespaceNameUnderscored', 'component_namespace')

        expect(@view1NodeData).to.have.property('el', @view1Node.el)
        expect(@view1NodeData).to.have.property('$el', @view1Node.$el)
        expect(@view1NodeData).to.have.property('isComponentIndex', false)
        expect(@view1NodeData).to.have.property('isComponentPart', true)
        expect(@view1NodeData).to.have.property('isStandAlone', false)
        expect(@view1NodeData).to.have.property('componentId', @component1Id)
        expect(@view1NodeData).to.have.property('componentIndexNode', @component1NodeData)
        expect(@view1NodeData).to.have.property('nodeName', 'TestView1')
        expect(@view1NodeData).to.have.property('nodeNameUnderscored', 'test_view1')
        expect(@view1NodeData).to.have.property('componentName', 'TestComponent')
        expect(@view1NodeData).to.have.property('componentNameUnderscored', 'test_component')
        expect(@view1NodeData).to.have.property('namespaceName', 'ComponentNamespace')
        expect(@view1NodeData).to.have.property('namespaceNameUnderscored', 'component_namespace')

        expect(@view2NodeData).to.have.property('el', @view2Node.el)
        expect(@view2NodeData).to.have.property('$el', @view2Node.$el)
        expect(@view2NodeData).to.have.property('isComponentIndex', false)
        expect(@view2NodeData).to.have.property('isComponentPart', true)
        expect(@view2NodeData).to.have.property('isStandAlone', false)
        expect(@view2NodeData).to.have.property('componentId', @component1Id)
        expect(@view2NodeData).to.have.property('componentIndexNode', @component1NodeData)
        expect(@view2NodeData).to.have.property('nodeName', 'TestView2')
        expect(@view2NodeData).to.have.property('nodeNameUnderscored', 'test_view2')
        expect(@view2NodeData).to.have.property('componentName', 'TestComponent')
        expect(@view2NodeData).to.have.property('componentNameUnderscored', 'test_component')
        expect(@view2NodeData).to.have.property('namespaceName', 'ComponentNamespace')
        expect(@view2NodeData).to.have.property('namespaceNameUnderscored', 'component_namespace')

        expect(@view3NodeData).to.have.property('el', @view3Node.el)
        expect(@view3NodeData).to.have.property('$el', @view3Node.$el)
        expect(@view3NodeData).to.have.property('isComponentIndex', false)
        expect(@view3NodeData).to.have.property('isComponentPart', true)
        expect(@view3NodeData).to.have.property('isStandAlone', false)
        expect(@view3NodeData).to.have.property('componentId', @component1Id)
        expect(@view3NodeData).to.have.property('componentIndexNode', @component1NodeData)
        expect(@view3NodeData).to.have.property('nodeName', 'TestView3')
        expect(@view3NodeData).to.have.property('nodeNameUnderscored', 'test_view3')
        expect(@view3NodeData).to.have.property('componentName', 'TestComponent')
        expect(@view3NodeData).to.have.property('componentNameUnderscored', 'test_component')
        expect(@view3NodeData).to.have.property('namespaceName', 'ComponentNamespace')
        expect(@view3NodeData).to.have.property('namespaceNameUnderscored', 'component_namespace')

        expect(@view4NodeData).to.have.property('el', @view4Node.el)
        expect(@view4NodeData).to.have.property('$el', @view4Node.$el)
        expect(@view4NodeData).to.have.property('isComponentIndex', false)
        expect(@view4NodeData).to.have.property('isComponentPart', true)
        expect(@view4NodeData).to.have.property('isStandAlone', false)
        expect(@view4NodeData).to.have.property('componentId', @component1Id)
        expect(@view4NodeData).to.have.property('componentIndexNode', @component1NodeData)
        expect(@view4NodeData).to.have.property('nodeName', 'TestView4')
        expect(@view4NodeData).to.have.property('nodeNameUnderscored', 'test_view4')
        expect(@view4NodeData).to.have.property('componentName', 'TestComponent')
        expect(@view4NodeData).to.have.property('componentNameUnderscored', 'test_component')
        expect(@view4NodeData).to.have.property('namespaceName', 'ComponentNamespace')
        expect(@view4NodeData).to.have.property('namespaceNameUnderscored', 'component_namespace')

        expect(@view5NodeData).to.have.property('el', @view5Node.el)
        expect(@view5NodeData).to.have.property('$el', @view5Node.$el)
        expect(@view5NodeData).to.have.property('isComponentIndex', false)
        expect(@view5NodeData).to.have.property('isComponentPart', true)
        expect(@view5NodeData).to.have.property('isStandAlone', false)
        expect(@view5NodeData).to.have.property('componentId', @component1Id)
        expect(@view5NodeData).to.have.property('componentIndexNode', @component1NodeData)
        expect(@view5NodeData).to.have.property('nodeName', 'TestView5')
        expect(@view5NodeData).to.have.property('nodeNameUnderscored', 'test_view5')
        expect(@view5NodeData).to.have.property('componentName', 'TestComponent')
        expect(@view5NodeData).to.have.property('componentNameUnderscored', 'test_component')
        expect(@view5NodeData).to.have.property('namespaceName', 'ComponentNamespace')
        expect(@view5NodeData).to.have.property('namespaceNameUnderscored', 'component_namespace')

        expect(@view6NodeData).to.have.property('el', @view6Node.el)
        expect(@view6NodeData).to.have.property('$el', @view6Node.$el)
        expect(@view6NodeData).to.have.property('isComponentIndex', false)
        expect(@view6NodeData).to.have.property('isComponentPart', true)
        expect(@view6NodeData).to.have.property('isStandAlone', false)
        expect(@view6NodeData).to.have.property('componentId', @component1Id)
        expect(@view6NodeData).to.have.property('componentIndexNode', @component1NodeData)
        expect(@view6NodeData).to.have.property('nodeName', 'TestView6')
        expect(@view6NodeData).to.have.property('nodeNameUnderscored', 'test_view6')
        expect(@view6NodeData).to.have.property('componentName', 'TestComponent')
        expect(@view6NodeData).to.have.property('componentNameUnderscored', 'test_component')
        expect(@view6NodeData).to.have.property('namespaceName', 'ComponentNamespace')
        expect(@view6NodeData).to.have.property('namespaceNameUnderscored', 'component_namespace')

        expect(@view7NodeData).to.have.property('el', @view7Node.el)
        expect(@view7NodeData).to.have.property('$el', @view7Node.$el)
        expect(@view7NodeData).to.have.property('isComponentIndex', false)
        expect(@view7NodeData).to.have.property('isComponentPart', false)
        expect(@view7NodeData).to.have.property('isStandAlone', true)
        expect(@view7NodeData).to.have.property('componentId', null)
        expect(@view7NodeData).to.have.property('componentIndexNode', null)
        expect(@view7NodeData).to.have.property('nodeName', 'TestView7')
        expect(@view7NodeData).to.have.property('nodeNameUnderscored', 'test_view7')
        expect(@view7NodeData).to.have.property('componentName', null)
        expect(@view7NodeData).to.have.property('componentNameUnderscored', null)
        expect(@view7NodeData).to.have.property('namespaceName', 'TestNamespace')
        expect(@view7NodeData).to.have.property('namespaceNameUnderscored', 'test_namespace')

        expect(@component2NodeData).to.have.property('el', @component2Node.el)
        expect(@component2NodeData).to.have.property('$el', @component2Node.$el)
        expect(@component2NodeData).to.have.property('isComponentIndex', true)
        expect(@component2NodeData).to.have.property('isComponentPart', true)
        expect(@component2NodeData).to.have.property('isStandAlone', false)
        expect(@component2NodeData).to.have.property('componentId', @component2Id)
        expect(@component2NodeData).to.have.property('componentIndexNode', null)
        expect(@component2NodeData).to.have.property('nodeName', 'Index')
        expect(@component2NodeData).to.have.property('nodeNameUnderscored', 'index')
        expect(@component2NodeData).to.have.property('componentName', 'TestComponent2')
        expect(@component2NodeData).to.have.property('componentNameUnderscored', 'test_component2')
        expect(@component2NodeData).to.have.property('namespaceName', 'ComponentNamespace')
        expect(@component2NodeData).to.have.property('namespaceNameUnderscored', 'component_namespace')

        expect(@view8NodeData).to.have.property('el', @view8Node.el)
        expect(@view8NodeData).to.have.property('$el', @view8Node.$el)
        expect(@view8NodeData).to.have.property('isComponentIndex', false)
        expect(@view8NodeData).to.have.property('isComponentPart', true)
        expect(@view8NodeData).to.have.property('isStandAlone', false)
        expect(@view8NodeData).to.have.property('componentId', @component2Id)
        expect(@view8NodeData).to.have.property('componentIndexNode', @component2NodeData)
        expect(@view8NodeData).to.have.property('nodeName', 'TestView8')
        expect(@view8NodeData).to.have.property('nodeNameUnderscored', 'test_view8')
        expect(@view8NodeData).to.have.property('componentName', 'TestComponent2')
        expect(@view8NodeData).to.have.property('componentNameUnderscored', 'test_component2')
        expect(@view8NodeData).to.have.property('namespaceName', 'ComponentNamespace')
        expect(@view8NodeData).to.have.property('namespaceNameUnderscored', 'component_namespace')

        expect(@view9NodeData).to.have.property('el', @view9Node.el)
        expect(@view9NodeData).to.have.property('$el', @view9Node.$el)
        expect(@view9NodeData).to.have.property('isComponentIndex', false)
        expect(@view9NodeData).to.have.property('isComponentPart', false)
        expect(@view9NodeData).to.have.property('isStandAlone', true)
        expect(@view9NodeData).to.have.property('componentId', null)
        expect(@view9NodeData).to.have.property('componentIndexNode', null)
        expect(@view9NodeData).to.have.property('nodeName', 'TestView9')
        expect(@view9NodeData).to.have.property('nodeNameUnderscored', 'test_view9')
        expect(@view9NodeData).to.have.property('componentName', null)
        expect(@view9NodeData).to.have.property('componentNameUnderscored', null)
        expect(@view9NodeData).to.have.property('namespaceName', 'TestNamespace')
        expect(@view9NodeData).to.have.property('namespaceNameUnderscored', 'test_namespace')
