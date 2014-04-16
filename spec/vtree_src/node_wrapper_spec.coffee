NodeWrapper = modula.require('vtree/node_wrapper')
Node = class
  $el: $('')
  el: ''

describe 'NodeWrapper', ->

  $render = (name) ->
    $(window.__html__["spec/fixtures/#{name}.html"])

  before ->
    sinon.spy(NodeWrapper::_hooks(), 'init')
    sinon.spy(NodeWrapper::_hooks(), 'unload')

  after ->
    NodeWrapper::_hooks().init.restore()
    NodeWrapper::_hooks().unload.restore()

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
        sinon.spy(NodeWrapper::, 'identifyNodeAttributes')
        node = new Node(@$el)
        nodeWrapper = new NodeWrapper(node)
        expect(nodeWrapper.identifyNodeAttributes).to.be.calledOnce

      it 'initializes new Vtree node', ->
        sinon.spy(NodeWrapper::, 'initNodeDataObject')
        node = new Node(@$el)
        nodeWrapper = new NodeWrapper(node)
        expect(nodeWrapper.initNodeDataObject).to.be.calledOnce

    describe '.initNodeDataObject', ->
      it 'calls Hooks init hooks', ->
        initialCallCount = @nodeWrapper._hooks().init.callCount
        @nodeWrapper.initNodeDataObject()
        expect(@nodeWrapper._hooks().init.callCount).to.be.eql(initialCallCount + 1)

      it 'provides nodeData object to init call', ->
        object = @nodeWrapper._hooks().init.lastCall.args[0]
        expect(object.constructor).to.match(/NodeData/)

    describe '.unload', ->
      it 'calls Hooks unload hooks', ->
        initialCallCount = @nodeWrapper._hooks().unload.callCount
        @nodeWrapper.unload()
        expect(@nodeWrapper._hooks().unload.callCount).to.be.eql(initialCallCount + 1)

      it 'provides nodeData object to init call', ->
        @nodeWrapper.unload()
        object = @nodeWrapper._hooks().unload.lastCall.args[0]
        expect(object.constructor).to.match(/NodeData/)

      it 'deletes reference to nodeData object', ->
        @nodeWrapper.unload()
        expect(@nodeWrapper.nodeData).to.be.undefined

      it 'deletes reference to node object', ->
        @nodeWrapper.unload()
        expect(@nodeWrapper.node).to.be.undefined

  describe 'View initialization', ->

    prepareFixtureData = ->
      TreeManager = modula.require('vtree/tree_manager')
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

    beforeEach ->
      prepareFixtureData.apply(@)

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

    describe '.identifyNodeAttributes', ->
      it 'identifies current node layout name', ->
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

      it 'identifies current node layout id', ->
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

      it 'identifies current node component name', ->
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

      it 'identifies current node view name', ->
        expect(@appNode.nodeWrapper.nodeName).to.be.eql 'layout'
        expect(@view1Node.nodeWrapper.nodeName).to.be.eql 'test_view1'
        expect(@view2Node.nodeWrapper.nodeName).to.be.eql 'test_view2'
        expect(@view3Node.nodeWrapper.nodeName).to.be.eql 'test_view3'
        expect(@view4Node.nodeWrapper.nodeName).to.be.eql 'test_view4'
        expect(@view5Node.nodeWrapper.nodeName).to.be.eql 'test_view5'
        expect(@view6Node.nodeWrapper.nodeName).to.be.eql 'test_view6'
        expect(@view7Node.nodeWrapper.nodeName).to.be.eql 'test_view7'
        expect(@app2Node.nodeWrapper.nodeName).to.be.eql 'layout'
        expect(@view8Node.nodeWrapper.nodeName).to.be.eql 'test_view8'
        expect(@view9Node.nodeWrapper.nodeName).to.be.eql 'test_view9'

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

    describe '.initNodeData', ->
      beforeEach ->
        @app1LayoutId = @appNode.nodeWrapper.layoutId
        @app2LayoutId = @app2Node.nodeWrapper.layoutId

        @appNodeData = @appNode.nodeWrapper.nodeData
        @view1NodeData = @view1Node.nodeWrapper.nodeData
        @view2NodeData = @view2Node.nodeWrapper.nodeData
        @view3NodeData = @view3Node.nodeWrapper.nodeData
        @view4NodeData = @view4Node.nodeWrapper.nodeData
        @view5NodeData = @view5Node.nodeWrapper.nodeData
        @view6NodeData = @view6Node.nodeWrapper.nodeData
        @view7NodeData = @view7Node.nodeWrapper.nodeData
        @app2NodeData = @app2Node.nodeWrapper.nodeData
        @view8NodeData = @view8Node.nodeWrapper.nodeData
        @view9NodeData = @view9Node.nodeWrapper.nodeData

      it 'returns NodeData object based on current state of NodeWrapper', ->
        object = @nodeWrapper.initNodeData()
        expect(object.constructor).to.match(/NodeData/)

      it 'sets correct data to all NodeData objects', ->
        expect(@appNodeData).to.have.property('el', @appNode.el)
        expect(@appNodeData).to.have.property('$el', @appNode.$el)
        expect(@appNodeData).to.have.property('isApplicationLayout', true)
        expect(@appNodeData).to.have.property('isApplicationPart', true)
        expect(@appNodeData).to.have.property('isComponentPart', false)
        expect(@appNodeData).to.have.property('applicationId', @app1LayoutId)
        expect(@appNodeData).to.have.property('nodeName', 'layout')
        expect(@appNodeData).to.have.property('applicationName', 'TestApp')
        expect(@appNodeData).to.have.property('applicationNameUnderscored', 'test_app')
        expect(@appNodeData).to.have.property('componentName', null)
        expect(@appNodeData).to.have.property('componentNameUnderscored', null)

        expect(@view1NodeData).to.have.property('el', @view1Node.el)
        expect(@view1NodeData).to.have.property('$el', @view1Node.$el)
        expect(@view1NodeData).to.have.property('isApplicationLayout', false)
        expect(@view1NodeData).to.have.property('isApplicationPart', true)
        expect(@view1NodeData).to.have.property('isComponentPart', false)
        expect(@view1NodeData).to.have.property('applicationId', @app1LayoutId)
        expect(@view1NodeData).to.have.property('nodeName', 'test_view1')
        expect(@view1NodeData).to.have.property('applicationName', 'TestApp')
        expect(@view1NodeData).to.have.property('applicationNameUnderscored', 'test_app')
        expect(@view1NodeData).to.have.property('componentName', null)
        expect(@view1NodeData).to.have.property('componentNameUnderscored', null)

        expect(@view2NodeData).to.have.property('el', @view2Node.el)
        expect(@view2NodeData).to.have.property('$el', @view2Node.$el)
        expect(@view2NodeData).to.have.property('isApplicationLayout', false)
        expect(@view2NodeData).to.have.property('isApplicationPart', true)
        expect(@view2NodeData).to.have.property('isComponentPart', false)
        expect(@view2NodeData).to.have.property('applicationId', @app1LayoutId)
        expect(@view2NodeData).to.have.property('nodeName', 'test_view2')
        expect(@view2NodeData).to.have.property('applicationName', 'TestApp')
        expect(@view2NodeData).to.have.property('applicationNameUnderscored', 'test_app')
        expect(@view2NodeData).to.have.property('componentName', null)
        expect(@view2NodeData).to.have.property('componentNameUnderscored', null)

        expect(@view3NodeData).to.have.property('el', @view3Node.el)
        expect(@view3NodeData).to.have.property('$el', @view3Node.$el)
        expect(@view3NodeData).to.have.property('isApplicationLayout', false)
        expect(@view3NodeData).to.have.property('isApplicationPart', true)
        expect(@view3NodeData).to.have.property('isComponentPart', false)
        expect(@view3NodeData).to.have.property('applicationId', @app1LayoutId)
        expect(@view3NodeData).to.have.property('nodeName', 'test_view3')
        expect(@view3NodeData).to.have.property('applicationName', 'TestApp')
        expect(@view3NodeData).to.have.property('applicationNameUnderscored', 'test_app')
        expect(@view3NodeData).to.have.property('componentName', null)
        expect(@view3NodeData).to.have.property('componentNameUnderscored', null)

        expect(@view4NodeData).to.have.property('el', @view4Node.el)
        expect(@view4NodeData).to.have.property('$el', @view4Node.$el)
        expect(@view4NodeData).to.have.property('isApplicationLayout', false)
        expect(@view4NodeData).to.have.property('isApplicationPart', true)
        expect(@view4NodeData).to.have.property('isComponentPart', false)
        expect(@view4NodeData).to.have.property('applicationId', @app1LayoutId)
        expect(@view4NodeData).to.have.property('nodeName', 'test_view4')
        expect(@view4NodeData).to.have.property('applicationName', 'TestApp')
        expect(@view4NodeData).to.have.property('applicationNameUnderscored', 'test_app')
        expect(@view4NodeData).to.have.property('componentName', null)
        expect(@view4NodeData).to.have.property('componentNameUnderscored', null)

        expect(@view5NodeData).to.have.property('el', @view5Node.el)
        expect(@view5NodeData).to.have.property('$el', @view5Node.$el)
        expect(@view5NodeData).to.have.property('isApplicationLayout', false)
        expect(@view5NodeData).to.have.property('isApplicationPart', true)
        expect(@view5NodeData).to.have.property('isComponentPart', false)
        expect(@view5NodeData).to.have.property('applicationId', @app1LayoutId)
        expect(@view5NodeData).to.have.property('nodeName', 'test_view5')
        expect(@view5NodeData).to.have.property('applicationName', 'TestApp')
        expect(@view5NodeData).to.have.property('applicationNameUnderscored', 'test_app')
        expect(@view5NodeData).to.have.property('componentName', null)
        expect(@view5NodeData).to.have.property('componentNameUnderscored', null)

        expect(@view6NodeData).to.have.property('el', @view6Node.el)
        expect(@view6NodeData).to.have.property('$el', @view6Node.$el)
        expect(@view6NodeData).to.have.property('isApplicationLayout', false)
        expect(@view6NodeData).to.have.property('isApplicationPart', true)
        expect(@view6NodeData).to.have.property('isComponentPart', false)
        expect(@view6NodeData).to.have.property('applicationId', @app1LayoutId)
        expect(@view6NodeData).to.have.property('nodeName', 'test_view6')
        expect(@view6NodeData).to.have.property('applicationName', 'TestApp')
        expect(@view6NodeData).to.have.property('applicationNameUnderscored', 'test_app')
        expect(@view6NodeData).to.have.property('componentName', null)
        expect(@view6NodeData).to.have.property('componentNameUnderscored', null)

        expect(@view7NodeData).to.have.property('el', @view7Node.el)
        expect(@view7NodeData).to.have.property('$el', @view7Node.$el)
        expect(@view7NodeData).to.have.property('isApplicationLayout', false)
        expect(@view7NodeData).to.have.property('isApplicationPart', false)
        expect(@view7NodeData).to.have.property('isComponentPart', true)
        expect(@view7NodeData).to.have.property('applicationId', null)
        expect(@view7NodeData).to.have.property('nodeName', 'test_view7')
        expect(@view7NodeData).to.have.property('applicationName', null)
        expect(@view7NodeData).to.have.property('applicationNameUnderscored', null)
        expect(@view7NodeData).to.have.property('componentName', 'TestComponent')
        expect(@view7NodeData).to.have.property('componentNameUnderscored', 'test_component')

        expect(@app2NodeData).to.have.property('el', @app2Node.el)
        expect(@app2NodeData).to.have.property('$el', @app2Node.$el)
        expect(@app2NodeData).to.have.property('isApplicationLayout', true)
        expect(@app2NodeData).to.have.property('isApplicationPart', true)
        expect(@app2NodeData).to.have.property('isComponentPart', false)
        expect(@app2NodeData).to.have.property('applicationId', @app2LayoutId)
        expect(@app2NodeData).to.have.property('nodeName', 'layout')
        expect(@app2NodeData).to.have.property('applicationName', 'TestApp2')
        expect(@app2NodeData).to.have.property('applicationNameUnderscored', 'test_app2')
        expect(@app2NodeData).to.have.property('componentName', null)
        expect(@app2NodeData).to.have.property('componentNameUnderscored', null)

        expect(@view8NodeData).to.have.property('el', @view8Node.el)
        expect(@view8NodeData).to.have.property('$el', @view8Node.$el)
        expect(@view8NodeData).to.have.property('isApplicationLayout', false)
        expect(@view8NodeData).to.have.property('isApplicationPart', true)
        expect(@view8NodeData).to.have.property('isComponentPart', false)
        expect(@view8NodeData).to.have.property('applicationId', @app2LayoutId)
        expect(@view8NodeData).to.have.property('nodeName', 'test_view8')
        expect(@view8NodeData).to.have.property('applicationName', 'TestApp2')
        expect(@view8NodeData).to.have.property('applicationNameUnderscored', 'test_app2')
        expect(@view8NodeData).to.have.property('componentName', null)
        expect(@view8NodeData).to.have.property('componentNameUnderscored', null)

        expect(@view9NodeData).to.have.property('el', @view9Node.el)
        expect(@view9NodeData).to.have.property('$el', @view9Node.$el)
        expect(@view9NodeData).to.have.property('isApplicationLayout', false)
        expect(@view9NodeData).to.have.property('isApplicationPart', false)
        expect(@view9NodeData).to.have.property('isComponentPart', true)
        expect(@view9NodeData).to.have.property('applicationId', null)
        expect(@view9NodeData).to.have.property('nodeName', 'test_view9')
        expect(@view9NodeData).to.have.property('applicationName', null)
        expect(@view9NodeData).to.have.property('applicationNameUnderscored', null)
        expect(@view9NodeData).to.have.property('componentName', 'TestComponent')
        expect(@view9NodeData).to.have.property('componentNameUnderscored', 'test_component')
