Vtree = require('vtree')

describe 'Vtree', ->

  $render = (name) ->
    $(window.__html__["spec/fixtures/#{name}.html"])

  describe '.initRemoveEvent', ->
    it 'creates custom jquery event, which being triggered when element being removed from DOM', ->
      Vtree.initRemoveEvent()
      fnSpy = sinon.spy()
      $el = $('<div />')
      $el2 = $('<div />')

      $('body').append($el).append($el2)
      $el.on('remove', fnSpy)
      $el2.on('remove', fnSpy)
      $el.remove()
      $el2.remove()

      expect(fnSpy).to.be.calledTwice

  describe '.create', ->
    it 'initializes TreeManager instance', ->
      sinon.spy(Vtree, 'initTreeManager')
      Vtree.create()
      expect(Vtree.initTreeManager).to.be.calledOnce

    it 'initializes custom jquery remove event', ->
      sinon.spy(Vtree, 'initRemoveEvent')
      Vtree.create()
      expect(Vtree.initRemoveEvent).to.be.calledOnce

    it 'initializes custom jquery refresh event', ->
      sinon.spy(Vtree, 'initRefreshEvent')
      Vtree.create()
      expect(Vtree.initRefreshEvent).to.be.calledOnce

    it 'creates views tree', ->
      sinon.spy(Vtree, 'createViewsTree')
      Vtree.create()
      expect(Vtree.createViewsTree).to.be.calledOnce

  describe '.initTreeManager', ->
    it 'saves reference to new TreeManager instance in @treeManager', ->
      Vtree.initTreeManager()
      expect(Vtree.treeManager.constructor).to.match(/TreeManager/)

  describe '.createViewsTree', ->
    it 'creates view tree with help of @treeManager', ->
      sinon.spy(Vtree.treeManager, 'createTree')
      Vtree.createViewsTree()
      expect(Vtree.treeManager.createTree).to.be.calledOnce

  describe '.initRefreshEvent', ->
    it 'creates custom jquery refresh event', ->
      Vtree.initRefreshEvent()
      expect(Vtree.isRefreshEventInitialized()).to.be.true

    describe 'Custom jquery refresh event', ->
      before ->
        Vtree.initRefreshEvent()
        @treeManager = Vtree.treeManager
        sinon.spy(@treeManager, 'refresh')

      beforeEach ->
        $('body').empty().append($render('nodes_with_data_view'))
        @treeManager.createTree()

      it "calls tree manager's refresh event", ->
        initCallCount = @treeManager.refresh.callCount
        $el = $('body').find('#app1')
        $el.trigger('refresh')
        expect(@treeManager.refresh.callCount).to.be.eql(initCallCount + 1)

      it 'looks for closest element with initialized viewNode', ->
        $elWithoutView = $('body').find('#no_view')
        $closestWithView = $('body').find('#app1')
        $elWithoutView.trigger('refresh')

        viewNode = @treeManager.refresh.lastCall.args[0]
        expect(viewNode.el).to.be.equal $closestWithView[0]

      it 'refreshes element if it has viewNode', ->
        $el = $('body').find('#view2')
        $el.trigger('refresh')

        viewNode = @treeManager.refresh.lastCall.args[0]
        expect(viewNode.el).to.be.equal $el[0]
