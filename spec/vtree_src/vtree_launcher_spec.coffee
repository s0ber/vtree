VtreeLauncher = require('vtree/vtree_launcher')
ViewHooks = ->

describe 'VtreeLauncher', ->

  $render = (name) ->
    $(window.__html__["spec/fixtures/#{name}.html"])

  describe '.initRemoveEvent', ->
    it 'creates custom jquery event, which being triggered when element being removed from DOM', ->
      VtreeLauncher.initRemoveEvent()
      fnSpy = sinon.spy()
      $el = $('<div />')
      $el2 = $('<div />')

      $('body').append($el).append($el2)
      $el.on('remove', fnSpy)
      $el2.on('remove', fnSpy)
      $el.remove()
      $el2.remove()

      expect(fnSpy).to.be.calledTwice

  describe '.launch', ->
    it 'saves provided ViewHooks object on @options', ->
      viewHooks = sinon.createStubInstance(ViewHooks)
      VtreeLauncher.launch(viewHooks)
      expect(VtreeLauncher.options.vtreeHooks).to.be.eql viewHooks

    it 'initializes TreeManager instance', ->
      sinon.spy(VtreeLauncher, 'initTreeManager')
      VtreeLauncher.launch()
      expect(VtreeLauncher.initTreeManager).to.be.calledOnce

    it 'initializes custom jquery remove event', ->
      sinon.spy(VtreeLauncher, 'initRemoveEvent')
      VtreeLauncher.launch()
      expect(VtreeLauncher.initRemoveEvent).to.be.calledOnce

    it 'initializes custom jquery refresh event', ->
      sinon.spy(VtreeLauncher, 'initRefreshEvent')
      VtreeLauncher.launch()
      expect(VtreeLauncher.initRefreshEvent).to.be.calledOnce

  describe '.initTreeManager', ->
    it 'saves reference to new TreeManager instance in @treeManager', ->
      VtreeLauncher.initTreeManager()
      expect(VtreeLauncher.treeManager.constructor).to.match(/TreeManager/)

  describe '.createViewsTree', ->
    it 'creates view tree with help of @treeManager', ->
      sinon.spy(VtreeLauncher.treeManager, 'createTree')
      VtreeLauncher.createViewsTree()
      expect(VtreeLauncher.treeManager.createTree).to.be.calledOnce

  describe '.initRefreshEvent', ->
    it 'creates custom jquery refresh event', ->
      VtreeLauncher.initRefreshEvent()
      expect(VtreeLauncher.isRefreshEventInitialized()).to.be.true

    describe 'Custom jquery refresh event', ->
      before ->
        VtreeLauncher.initRefreshEvent()
        @treeManager = VtreeLauncher.treeManager
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
