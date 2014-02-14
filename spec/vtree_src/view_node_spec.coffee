ViewNode = require('vtree/view_node')
ViewHooks = require('vtree/view_hooks')

describe 'ViewNode', ->

  before ->
    sinon.spy(ViewNode::, 'init')
    sinon.spy(ViewNode::, 'activate')
    sinon.spy(ViewNode::, 'unload')
    sinon.spy(ViewNode::, 'setAsActivated')
    sinon.spy(ViewNode::, 'setAsRemoved')

  beforeEach ->
    @options = {option: 'value'}
    @$el = $('div')
    @$secondEl = $('div')
    @$thirdEl = $('div')
    @$fourthEl = $('div')

    @viewNode = new ViewNode(@$el, null, @options)
    @secondViewNode = new ViewNode(@$secondEl)
    @thirdViewNode = new ViewNode(@$thirdEl)
    @fourthViewNode = new ViewNode(@$fourthEl)

  describe '.constructor', ->
    it 'saves provided options in @options', ->
      expect(@viewNode.options).to.be.equal @options

    it 'saves reference to empty object in @options if no options provided', ->
      expect(@secondViewNode.options).to.be.eql {}

    it 'has uniq id', ->
      ids = [@viewNode.id, @secondViewNode.id, @thirdViewNode.id]
      expect(ids.unique()).to.have.length 3

    it 'has reference to provided ViewHooks instance if provided', ->
      viewHooks = new ViewHooks
      viewNode = new ViewNode(@$el, viewHooks)
      expect(viewNode.viewHooks).to.be.equal viewHooks

    it 'has reference to new empty ViewHooks instance if not viewHooks provided', ->
      viewNode = new ViewNode(@$el)
      expect(viewNode.viewHooks).to.be.instanceOf(ViewHooks)

    it 'has reference to provided jquery dom element', ->
      expect(@viewNode.$el).to.be.equal @$el
      expect(@viewNode.el).to.be.equal @$el[0]

    it 'has null reference for @parent', ->
      expect(@viewNode.parent).to.be.null

    it 'has empty list reference for @children', ->
      expect(@viewNode.children).to.be.an('array')
      expect(@viewNode.children).to.be.eql []

    it 'calls .init method', ->
      expect(@viewNode.init).to.be.called

  describe '.setParent', ->
    it 'sets provided ViewNode instance as @parent', ->
      @viewNode.setParent(@secondViewNode)
      expect(@viewNode.parent).to.be.equal @secondViewNode

  describe '.setChildren', ->
    it 'creates list of provided viewNodes array, which parent is current node and saves them as @children', ->
      @secondViewNode.setParent(@viewNode)
      @fourthViewNode.setParent(@viewNode)

      @viewNode.setChildren([@secondViewNode, @thirdViewNode, @fourthViewNode])
      expect(@viewNode.children).to.be.eql [@secondViewNode, @fourthViewNode]

  describe '.removeChild', ->
    it 'removes provided child from @children', ->
      @secondViewNode.setParent(@viewNode)
      @fourthViewNode.setParent(@viewNode)

      @viewNode.setChildren([@secondViewNode, @fourthViewNode])
      @viewNode.removeChild(@secondViewNode)
      expect(@viewNode.children).to.be.eql [@fourthViewNode]

    it 'does nothing if provided child is not in @children', ->
      @secondViewNode.setParent(@viewNode)
      @fourthViewNode.setParent(@viewNode)

      @viewNode.setChildren([@secondViewNode, @fourthViewNode])
      @viewNode.removeChild(@thirdViewNode)
      expect(@viewNode.children).to.be.eql [@secondViewNode, @fourthViewNode]

  describe 'Initialization behavior', ->

    beforeEach ->
      @viewHooks = new ViewHooks
      sinon.spy(@viewHooks, 'init')

      @viewNode = new ViewNode(@$el, @viewHooks)

    describe '.init', ->
      it 'calls @viewHooks.init method', ->
        @viewNode.init()
        expect(@viewHooks.init).to.be.called.once

      it 'calls @viewHooks.init with current viewNode instance as first argument', ->
        @viewNode.init()
        expect(@viewHooks.init.lastCall.args[0]).to.be.equal @viewNode

  describe 'Activation behavior', ->

    beforeEach ->
      @viewHooks = new ViewHooks
      sinon.spy(@viewHooks, 'activate')

      @viewNode = new ViewNode(@$el, @viewHooks)

    describe '.activate', ->
      it 'calls @viewHooks.activate method', ->
        @viewNode.activate()
        expect(@viewHooks.activate).to.be.called.once

      it 'calls @viewHooks.activate with current viewNode instance as first argument', ->
        @viewNode.activate()
        expect(@viewHooks.activate.lastCall.args[0]).to.be.equal @viewNode

      it 'sets viewNode as activated', ->
        @viewNode.activate()
        expect(@viewNode.isActivated()).to.be.true

      it 'does nothing if viewNode is already activated', ->
        @viewNode.activate()
        initSetAsActivatedCallsCount = @viewNode.setAsActivated.callCount

        @viewNode.activate()
        expect(@viewNode.setAsActivated.callCount).to.be.eql initSetAsActivatedCallsCount

  describe 'Unload behavior', ->

    beforeEach ->
      @viewHooks = new ViewHooks
      sinon.spy(@viewHooks, 'unload')

      @viewNode = new ViewNode(@$el, @viewHooks)

    describe '.unload', ->
      it 'calls @viewHooks.unload method', ->
        @viewNode.unload()

        expect(@viewHooks.unload).to.be.called.once

      it 'calls callbacks with current viewNode instance as first argument', ->
        @viewNode.unload()
        expect(@viewHooks.unload.lastCall.args[0]).to.be.equal @viewNode

      it 'sets viewNode as not activated', ->
        @viewNode.activate()
        @viewNode.unload()
        expect(@viewNode.isActivated()).to.be.false

  describe 'Remove behavior', ->

    describe '.remove', ->
      it 'sets viewNode as removed', ->
        @viewNode.remove()
        expect(@viewNode.isRemoved()).to.be.true

      it 'unloads viewNode only if viewNode is activated', ->
        initUnloadCallsCount = @viewNode.unload.callCount

        @viewNode.remove()
        expect(@viewNode.unload.callCount).to.be.eql(initUnloadCallsCount)

        @secondViewNode.activate()
        @secondViewNode.remove()
        expect(@secondViewNode.unload.callCount).to.be.eql(initUnloadCallsCount + 1)

      it 'does nothing if viewNode is already removed', ->
        @viewNode.activate()
        @viewNode.remove()

        initSetAsRemovedCallsCount = @viewNode.setAsRemoved.callCount

        @viewNode.remove()
        expect(@viewNode.setAsRemoved.callCount).to.be.eql initSetAsRemovedCallsCount
