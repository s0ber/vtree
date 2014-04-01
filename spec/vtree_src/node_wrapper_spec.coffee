NodeWrapper = require('vtree/node_wrapper')
Node = class
  $el: $('')
  el: ''
Hooks = class
  init: ->
  unload: ->

describe 'NodeWrapper', ->

  $render = (name) ->
    $(window.__html__["spec/fixtures/#{name}.html"])

  before ->
    hooks = sinon.createStubInstance(Hooks)
    NodeWrapper::_hooks = (-> hooks)

  describe 'Basic methods', ->
    beforeEach ->
      @$el = $('<div />')
      @node = new Node(@$el)
      @nodeWrapper = new NodeWrapper(@node)

    describe '.constructor', ->

      it 'saves reference to provided view node in @node', ->
        expect(@nodeWrapper.node).to.be.equal @node

      it 'saves reference to node.$el in @$el', ->
        expect(@nodeWrapper.$el).to.be.equal @node.$el

      it 'saves reference to node.el in @el', ->
        expect(@nodeWrapper.el).to.be.equal @node.el

      it 'identifies view', ->
        sinon.spy(NodeWrapper::, 'identifyView')
        node = new Node(@$el)
        nodeWrapper = new NodeWrapper(node)
        expect(nodeWrapper.identifyView).to.be.calledOnce

      it 'initializes view', ->
        sinon.spy(NodeWrapper::, 'initView')
        node = new Node(@$el)
        nodeWrapper = new NodeWrapper(node)
        expect(nodeWrapper.initView).to.be.calledOnce

      it 'initializes new Vtree node', ->
        sinon.spy(NodeWrapper::, 'initVtreeNode')
        node = new Node(@$el)
        nodeWrapper = new NodeWrapper(node)
        expect(nodeWrapper.initVtreeNode).to.be.calledOnce

    describe '.initVtreeNode', ->
      it 'calls Hooks init hooks', ->
        initialCallCount = @nodeWrapper._hooks().init.callCount
        @nodeWrapper.initVtreeNode()
        expect(@nodeWrapper._hooks().init.callCount).to.be.eql(initialCallCount + 1)

      it 'provides node object to init call', ->
        object = @nodeWrapper._hooks().init.lastCall.args[0]
        expect(object.constructor).to.match(/VtreeNode/)

    describe '.createNode', ->
      it 'returns Node object based on current state of NodeWrapper', ->
        object = @nodeWrapper.createNode()
        expect(object.constructor).to.match(/VtreeNode/)

  describe 'View initialization', ->

    prepareFixtureComponents = ->
      window.TestAppComponent =
        LayoutView: sinon.spy()
        TestView1View: sinon.spy()
        TestView2View: sinon.spy()
        TestView3View: sinon.spy()
        TestView4View: sinon.spy()
        TestView5View: sinon.spy()
        TestView6View: sinon.spy()
      window.TestApp2Component =
        LayoutView: sinon.spy()
        TestView8View: sinon.spy()
      window.TestComponentComponent =
        TestView7View: sinon.spy()
        TestView9View: sinon.spy()

    prepareFixtureData = ->
      TreeManager = require('vtree/tree_manager')
      $els = $render('nodes_with_data_view')
      $newEls = $render('nodes_for_refresh')

      $('body').empty().append($els)
      $('#app1').append($newEls)

      treeManager = new TreeManager
      treeManager.setInitialNodes()
      treeManager.setParentsForInitialNodes()
      treeManager.setChildrenForInitialNodes()

      appNodeId = $('#app1').data('vtree-node-id')
      @appNode = treeManager.nodesCache.getById(appNodeId)
      @appNode.activate()

      # order matters here
      for view in 'view1 view2 view3 view4 view5 view6 view7 app2 view8 view9'.split(' ')
        id = $('#' + view).data('vtree-node-id')
        @["#{view}Node"] = treeManager.nodesCache.getById(id)
        @["#{view}Node"].activate()

    before ->
      prepareFixtureComponents.apply(@)

    beforeEach ->
      prepareFixtureData.apply(@)

    describe '.initView', ->
      sharedViewConstructors = ->
        expect(TestAppComponent.LayoutView).to.be.calledOnce
        expect(TestAppComponent.TestView1View).to.be.calledOnce
        expect(TestAppComponent.TestView2View).to.be.calledOnce
        expect(TestAppComponent.TestView3View).to.be.calledOnce
        expect(TestAppComponent.TestView4View).to.be.calledOnce
        expect(TestAppComponent.TestView5View).to.be.calledOnce
        expect(TestAppComponent.TestView6View).to.be.calledOnce

        expect(TestApp2Component.LayoutView).to.be.calledOnce
        expect(TestApp2Component.TestView8View).to.be.calledOnce

        expect(TestComponentComponent.TestView7View).to.be.calledOnce
        expect(TestComponentComponent.TestView9View).to.be.calledOnce

      it 'should initialize view depending on component and name', ->
        sharedViewConstructors.call(@)

    describe '.isLayout', ->
      it 'checks if node should initialize a layout view', ->
        expect(@appNode.nodeWrapper.isLayout()).to.be.true
        expect(@view1Node.nodeWrapper.isLayout()).to.be.false
        expect(@view2Node.nodeWrapper.isLayout()).to.be.false
        expect(@view3Node.nodeWrapper.isLayout()).to.be.false
        expect(@view4Node.nodeWrapper.isLayout()).to.be.false
        expect(@view5Node.nodeWrapper.isLayout()).to.be.false
        expect(@view6Node.nodeWrapper.isLayout()).to.be.false
        expect(@view7Node.nodeWrapper.isLayout()).to.be.false
        expect(@app2Node.nodeWrapper.isLayout()).to.be.true
        expect(@view8Node.nodeWrapper.isLayout()).to.be.false
        expect(@view9Node.nodeWrapper.isLayout()).to.be.false

    describe '.hasComponent', ->
      it 'checks if component name is specified manually', ->
        expect(@appNode.nodeWrapper.hasComponent()).to.be.false
        expect(@view1Node.nodeWrapper.hasComponent()).to.be.false
        expect(@view2Node.nodeWrapper.hasComponent()).to.be.false
        expect(@view3Node.nodeWrapper.hasComponent()).to.be.false
        expect(@view4Node.nodeWrapper.hasComponent()).to.be.false
        expect(@view5Node.nodeWrapper.hasComponent()).to.be.false
        expect(@view6Node.nodeWrapper.hasComponent()).to.be.false
        expect(@view7Node.nodeWrapper.hasComponent()).to.be.true
        expect(@app2Node.nodeWrapper.hasComponent()).to.be.false
        expect(@view8Node.nodeWrapper.hasComponent()).to.be.false
        expect(@view9Node.nodeWrapper.hasComponent()).to.be.true

    describe '.identifyView', ->
      it 'identifies current view layout name', ->
        expect(@appNode.nodeWrapper.layoutName).to.be.eql 'test_app'
        expect(@view1Node.nodeWrapper.layoutName).to.be.eql 'test_app'
        expect(@view2Node.nodeWrapper.layoutName).to.be.eql 'test_app'
        expect(@view3Node.nodeWrapper.layoutName).to.be.eql 'test_app'
        expect(@view4Node.nodeWrapper.layoutName).to.be.eql 'test_app'
        expect(@view5Node.nodeWrapper.layoutName).to.be.eql 'test_app'
        expect(@view6Node.nodeWrapper.layoutName).to.be.eql 'test_app'
        expect(@view7Node.nodeWrapper.layoutName).to.be.eql 'test_app'
        expect(@app2Node.nodeWrapper.layoutName).to.be.eql 'test_app2'
        expect(@view8Node.nodeWrapper.layoutName).to.be.eql 'test_app2'
        expect(@view9Node.nodeWrapper.layoutName).to.be.eql 'test_app2'

      it 'identifies current view layout id', ->
        app1LayoutId = @appNode.nodeWrapper.layoutId
        expect(@appNode.nodeWrapper.layoutId).to.be.eql app1LayoutId
        expect(@view1Node.nodeWrapper.layoutId).to.be.eql app1LayoutId
        expect(@view2Node.nodeWrapper.layoutId).to.be.eql app1LayoutId
        expect(@view3Node.nodeWrapper.layoutId).to.be.eql app1LayoutId
        expect(@view4Node.nodeWrapper.layoutId).to.be.eql app1LayoutId
        expect(@view5Node.nodeWrapper.layoutId).to.be.eql app1LayoutId
        expect(@view6Node.nodeWrapper.layoutId).to.be.eql app1LayoutId
        expect(@view7Node.nodeWrapper.layoutId).to.be.eql app1LayoutId

        app2LayoutId = @app2Node.nodeWrapper.layoutId
        expect(@app2Node.nodeWrapper.layoutId).to.be.eql app2LayoutId
        expect(@view8Node.nodeWrapper.layoutId).to.be.eql app2LayoutId
        expect(@view9Node.nodeWrapper.layoutId).to.be.eql app2LayoutId

      it 'identifies current view component name', ->
        expect(@appNode.nodeWrapper.componentName).to.be.eql 'test_app'
        expect(@view1Node.nodeWrapper.componentName).to.be.eql 'test_app'
        expect(@view2Node.nodeWrapper.componentName).to.be.eql 'test_app'
        expect(@view3Node.nodeWrapper.componentName).to.be.eql 'test_app'
        expect(@view4Node.nodeWrapper.componentName).to.be.eql 'test_app'
        expect(@view5Node.nodeWrapper.componentName).to.be.eql 'test_app'
        expect(@view6Node.nodeWrapper.componentName).to.be.eql 'test_app'
        expect(@view7Node.nodeWrapper.componentName).to.be.eql 'test_component'
        expect(@app2Node.nodeWrapper.componentName).to.be.eql 'test_app2'
        expect(@view8Node.nodeWrapper.componentName).to.be.eql 'test_app2'
        expect(@view9Node.nodeWrapper.componentName).to.be.eql 'test_component'

      it 'identifies current view class name', ->
        expect(@appNode.nodeWrapper.viewClassName).to.be.eql 'LayoutView'
        expect(@view1Node.nodeWrapper.viewClassName).to.be.eql 'TestView1View'
        expect(@view2Node.nodeWrapper.viewClassName).to.be.eql 'TestView2View'
        expect(@view3Node.nodeWrapper.viewClassName).to.be.eql 'TestView3View'
        expect(@view4Node.nodeWrapper.viewClassName).to.be.eql 'TestView4View'
        expect(@view5Node.nodeWrapper.viewClassName).to.be.eql 'TestView5View'
        expect(@view6Node.nodeWrapper.viewClassName).to.be.eql 'TestView6View'
        expect(@view7Node.nodeWrapper.viewClassName).to.be.eql 'TestView7View'
        expect(@app2Node.nodeWrapper.viewClassName).to.be.eql 'LayoutView'
        expect(@view8Node.nodeWrapper.viewClassName).to.be.eql 'TestView8View'
        expect(@view9Node.nodeWrapper.viewClassName).to.be.eql 'TestView9View'

      it 'identifies current view component name', ->
        expect(@appNode.nodeWrapper.componentClassName).to.be.eql 'TestAppComponent'
        expect(@view1Node.nodeWrapper.componentClassName).to.be.eql 'TestAppComponent'
        expect(@view2Node.nodeWrapper.componentClassName).to.be.eql 'TestAppComponent'
        expect(@view3Node.nodeWrapper.componentClassName).to.be.eql 'TestAppComponent'
        expect(@view4Node.nodeWrapper.componentClassName).to.be.eql 'TestAppComponent'
        expect(@view5Node.nodeWrapper.componentClassName).to.be.eql 'TestAppComponent'
        expect(@view6Node.nodeWrapper.componentClassName).to.be.eql 'TestAppComponent'
        expect(@view7Node.nodeWrapper.componentClassName).to.be.eql 'TestComponentComponent'
        expect(@app2Node.nodeWrapper.componentClassName).to.be.eql 'TestApp2Component'
        expect(@view8Node.nodeWrapper.componentClassName).to.be.eql 'TestApp2Component'
        expect(@view9Node.nodeWrapper.componentClassName).to.be.eql 'TestComponentComponent'
