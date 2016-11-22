Launcher = require 'src/vtree_src/launcher'
nodesWithDataView = require('../fixtures/nodes_with_data_view')
Configuration = require 'src/configuration'

describe 'Launcher', ->
  describe '.initRemoveEvent', ->
    it 'creates custom jquery event, which being triggered when element being removed from DOM', ->
      Launcher.initRemoveEvent()
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
    beforeEach ->
      @config = new Configuration()

    it 'initializes TreeManager instance', ->
      sinon.spy(Launcher, 'initTreeManager')
      Launcher.launch(@config)
      expect(Launcher.initTreeManager).to.be.calledOnce
      expect(Launcher.treeManager.config).to.eq @config
      expect(Launcher.treeManager.launcherHooks).to.eq Launcher.hooks()

    it 'initializes custom jquery remove event', ->
      sinon.spy(Launcher, 'initRemoveEvent')
      Launcher.launch(@config)
      expect(Launcher.initRemoveEvent).to.be.calledOnce

    it 'initializes custom jquery refresh event', ->
      sinon.spy(Launcher, 'initRefreshEvent')
      Launcher.launch(@config)
      expect(Launcher.initRefreshEvent).to.be.calledOnce

  describe '.initTreeManager', ->
    it 'saves reference to new TreeManager instance in @treeManager', ->
      config = new Configuration()
      Launcher.initTreeManager(config)
      expect(Launcher.treeManager.constructor).to.match(/TreeManager/)

  describe '.createViewsTree', ->
    it 'creates view tree with help of @treeManager', ->
      sinon.spy(Launcher.treeManager, 'createTree')
      Launcher.createViewsTree()
      expect(Launcher.treeManager.createTree).to.be.calledOnce

  describe '.initRefreshEvent', ->
    it 'creates custom jquery refresh event', ->
      Launcher.initRefreshEvent()
      expect(Launcher.isRefreshEventInitialized).to.be.true

    describe 'Custom jquery refresh event', ->
      before ->
        Launcher.initRefreshEvent()
        @treeManager = Launcher.treeManager
        sinon.spy(@treeManager, 'refresh')

      beforeEach ->
        $('body').empty().append($(nodesWithDataView()))
        @treeManager.createTree()

      it "calls tree manager's refresh event", ->
        initCallCount = @treeManager.refresh.callCount
        $el = $('body').find('#component1')
        $el.trigger('refresh')
        expect(@treeManager.refresh.callCount).to.be.eql(initCallCount + 1)

      it 'looks for closest element with initialized node', ->
        $elWithoutView = $('body').find('#no_view')
        $closestWithView = $('body').find('#component1')
        $elWithoutView.trigger('refresh')

        node = @treeManager.refresh.lastCall.args[0]
        expect(node.el).to.be.equal $closestWithView[0]

      it 'refreshes element if it has node', ->
        $el = $('body').find('#view2')
        $el.trigger('refresh')

        node = @treeManager.refresh.lastCall.args[0]
        expect(node.el).to.be.equal $el[0]
