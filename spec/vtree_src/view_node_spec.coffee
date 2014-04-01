ViewNode = require('vtree/view_node')
Hooks = class
  init: ->
  activate: ->
  unload: ->

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

    it 'has reference to provided Hooks instance if provided', ->
      hooks = new Hooks
      viewNode = new ViewNode(@$el, hooks)
      expect(viewNode.hooks).to.be.equal hooks

    it 'has reference to new empty Hooks instance if not hooks object provided', ->
      viewNode = new ViewNode(@$el)
      expect(viewNode.hooks.constructor).to.match(/Hooks/)

    it 'has reference to provided jquery dom element', ->
      expect(@viewNode.$el).to.be.equal @$el
      expect(@viewNode.el).to.be.equal @$el[0]

    it 'has null reference for @parent', ->
      expect(@viewNode.parent).to.be.null

    it 'has empty list reference for @children', ->
      expect(@viewNode.children).to.be.an 'array'
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
      @hooks = sinon.createStubInstance(Hooks)
      @viewNode = new ViewNode(@$el, @hooks)

    describe '.init', ->
      it 'calls @hooks.init method', ->
        @viewNode.init()
        expect(@hooks.init).to.be.called.once

      it 'calls @hooks.init with current viewNode instance as first argument', ->
        @viewNode.init()
        expect(@hooks.init.lastCall.args[0]).to.be.equal @viewNode

  describe 'Activation behavior', ->

    beforeEach ->
      @hooks = sinon.createStubInstance(Hooks)
      @viewNode = new ViewNode(@$el, @hooks)

    describe '.activate', ->
      it 'calls @hooks.activate method', ->
        @viewNode.activate()
        expect(@hooks.activate).to.be.called.once

      it 'calls @hooks.activate with current viewNode instance as first argument', ->
        @viewNode.activate()
        expect(@hooks.activate.lastCall.args[0]).to.be.equal @viewNode

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
      @hooks = sinon.createStubInstance(Hooks)
      @viewNode = new ViewNode(@$el, @hooks)

    describe '.unload', ->
      it 'calls @hooks.unload method', ->
        @viewNode.unload()

        expect(@hooks.unload).to.be.called.once

      it 'calls callbacks with current viewNode instance as first argument', ->
        @viewNode.unload()
        expect(@hooks.unload.lastCall.args[0]).to.be.equal @viewNode

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
