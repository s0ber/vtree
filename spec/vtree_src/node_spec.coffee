Node = modula.require('vtree/node')
Hooks = class
  init: ->
  activate: ->
  unload: ->

describe 'Node', ->

  before ->
    sinon.spy(Node::, 'init')
    sinon.spy(Node::, 'activate')
    sinon.spy(Node::, 'unload')
    sinon.spy(Node::, 'setAsActivated')
    sinon.spy(Node::, 'setAsRemoved')

  beforeEach ->
    @$el = $('div')
    @$secondEl = $('div')
    @$thirdEl = $('div')
    @$fourthEl = $('div')

    @node = new Node(@$el, null)
    @secondNode = new Node(@$secondEl)
    @thirdNode = new Node(@$thirdEl)
    @fourthNode = new Node(@$fourthEl)

  describe '.constructor', ->
    it 'has uniq id', ->
      ids = [@node.id, @secondNode.id, @thirdNode.id]
      expect(_.uniq(ids)).to.have.length 3

    it 'has reference to provided Hooks instance if provided', ->
      hooks = new Hooks
      node = new Node(@$el, hooks)
      expect(node.hooks).to.be.equal hooks

    it 'has reference to new empty Hooks instance if not hooks object provided', ->
      node = new Node(@$el)
      expect(node.hooks.constructor).to.match(/Hooks/)

    it 'has reference to provided jquery dom element', ->
      expect(@node.$el).to.be.equal @$el
      expect(@node.el).to.be.equal @$el[0]

    it 'has null reference for @parent', ->
      expect(@node.parent).to.be.null

    it 'has empty list reference for @children', ->
      expect(@node.children).to.be.an 'array'
      expect(@node.children).to.be.eql []

    it 'calls .init method', ->
      expect(@node.init).to.be.called

  describe '.setParent', ->
    it 'sets provided Node instance as @parent', ->
      @node.setParent(@secondNode)
      expect(@node.parent).to.be.equal @secondNode

  describe '.prependChild', ->
    it 'prepends provided Node instance to @children array', ->
      @node.prependChild(@secondNode)
      expect(@node.children).to.be.eql [@secondNode]
      @node.prependChild(@fourthNode)
      expect(@node.children).to.be.eql [@fourthNode, @secondNode]

  describe '.appendChild', ->
    it 'appends provided Node instance to @children array', ->
      @node.appendChild(@secondNode)
      expect(@node.children).to.be.eql [@secondNode]
      @node.appendChild(@fourthNode)
      expect(@node.children).to.be.eql [@secondNode, @fourthNode]

  describe '.removeChild', ->
    it 'removes provided child from @children', ->
      @secondNode.setParent(@node)
      @fourthNode.setParent(@node)

      @node.appendChild(@secondNode)
      @node.appendChild(@fourthNode)

      @node.removeChild(@secondNode)
      expect(@node.children).to.be.eql [@fourthNode]

    it 'does nothing if provided child is not in @children', ->
      @secondNode.setParent(@node)
      @fourthNode.setParent(@node)

      @node.appendChild(@secondNode)
      @node.appendChild(@fourthNode)

      @node.removeChild(@thirdNode)
      expect(@node.children).to.be.eql [@secondNode, @fourthNode]

  describe 'Initialization behavior', ->

    beforeEach ->
      @hooks = sinon.createStubInstance(Hooks)
      @node = new Node(@$el, @hooks)

    describe '.init', ->
      it 'calls @hooks.init method', ->
        @node.init()
        expect(@hooks.init).to.be.called.once

      it 'calls @hooks.init with current node instance as first argument', ->
        @node.init()
        expect(@hooks.init.lastCall.args[0]).to.be.equal @node

  describe 'Activation behavior', ->

    beforeEach ->
      @hooks = sinon.createStubInstance(Hooks)
      @node = new Node(@$el, @hooks)

    describe '.activate', ->
      it 'calls @hooks.activate method', ->
        @node.activate()
        expect(@hooks.activate).to.be.called.once

      it 'calls @hooks.activate with current node instance as first argument', ->
        @node.activate()
        expect(@hooks.activate.lastCall.args[0]).to.be.equal @node

      it 'sets node as activated', ->
        @node.activate()
        expect(@node.isActivated()).to.be.true

      it 'does nothing if node is already activated', ->
        @node.activate()
        initSetAsActivatedCallsCount = @node.setAsActivated.callCount

        @node.activate()
        expect(@node.setAsActivated.callCount).to.be.eql initSetAsActivatedCallsCount

  describe 'Unload behavior', ->

    beforeEach ->
      @hooks = sinon.createStubInstance(Hooks)
      @node = new Node(@$el, @hooks)

    describe '.unload', ->
      it 'calls @hooks.unload method', ->
        @node.unload()

        expect(@hooks.unload).to.be.called.once

      it 'calls callbacks with current node instance as first argument', ->
        @node.unload()
        expect(@hooks.unload.lastCall.args[0]).to.be.equal @node

      it 'sets node as not activated', ->
        @node.activate()
        @node.unload()
        expect(@node.isActivated()).to.be.false

  describe 'Remove behavior', ->

    describe '.remove', ->
      it 'sets node as removed', ->
        @node.remove()
        expect(@node.isRemoved()).to.be.true

      it 'unloads node only if node is activated', ->
        initUnloadCallsCount = @node.unload.callCount

        @node.remove()
        expect(@node.unload.callCount).to.be.eql(initUnloadCallsCount)

        @secondNode.activate()
        @secondNode.remove()
        expect(@secondNode.unload.callCount).to.be.eql(initUnloadCallsCount + 1)

      it 'does nothing if node is already removed', ->
        @node.activate()
        @node.remove()

        initSetAsRemovedCallsCount = @node.setAsRemoved.callCount

        @node.remove()
        expect(@node.setAsRemoved.callCount).to.be.eql initSetAsRemovedCallsCount
