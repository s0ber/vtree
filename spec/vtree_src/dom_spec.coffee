$ = require 'jquery'
Vtree = require('src/vtree')
DOM = require('src/vtree_src/dom')
nodesForRefresh = require('../fixtures/nodes_for_refresh')
nodesWithDataView = require('../fixtures/nodes_with_data_view')

describe 'DOM', ->

  beforeEach ->
    @$els = $(nodesWithDataView())
    @$newEls = $(nodesForRefresh())

  describe '.html', ->
    beforeEach ->
      @$el = @$els.find('#view3')
      @html = @$newEls.wrap('<div/>').parent().html()

      sinon.spy(@$el, 'trigger')
      DOM.html(@$el, @html)

    it 'sets html to element', ->
      expect(@$el.html()).to.be.eql @html

    it 'triggers refresh event on $el', ->
      expect(@$el.trigger).to.be.calledOnce
      expect(@$el.trigger.args[0][0]).to.be.eql 'refresh'

  describe '.append', ->
    beforeEach ->
      @$parentEl = @$els
      @$el = @$newEls
      sinon.spy(@$parentEl, 'trigger')

      DOM.append(@$parentEl, @$el)

    it 'appends $el to $parentEl', ->
      expect(@$parentEl.children().last()[0]).to.be.eql @$el[0]

    it 'triggers refresh event on $parentEl', ->
      expect(@$parentEl.trigger).to.be.calledOnce
      expect(@$parentEl.trigger.args[0][0]).to.be.eql 'refresh'

  describe '.prepend', ->
    beforeEach ->
      @$parentEl = @$els
      @$el = @$newEls
      sinon.spy(@$parentEl, 'trigger')

      DOM.prepend(@$parentEl, @$el)

    it 'prepends $el to $parentEl', ->
      expect(@$parentEl.children()[0]).to.be.eql @$el[0]

    it 'triggers refresh event on $parentEl', ->
      expect(@$parentEl.trigger).to.be.calledOnce
      expect(@$parentEl.trigger.args[0][0]).to.be.eql 'refresh'

  describe '.before', ->
    beforeEach ->
      @$el = @$els.find('#view3')
      @$insertedEl = @$newEls

      @$parentEl = @$el.parent()
      @spyFn = sinon.spy()
      @$parentEl.on('refresh', @spyFn)

      DOM.before(@$el, @$insertedEl)

    it 'inserts $insertedEl before $el', ->
      expect(@$el.prev()[0]).to.be.eql @$insertedEl[0]

    it 'triggers refresh event on $parentEl', ->
      expect(@spyFn).to.be.calledOnce

  describe '.after', ->
    beforeEach ->
      @$el = @$els.find('#view3')
      @$insertedEl = @$newEls

      @$parentEl = @$el.parent()
      @spyFn = sinon.spy()
      @$parentEl.on('refresh', @spyFn)

      DOM.after(@$el, @$insertedEl)

    it 'inserts $insertedEl after $el', ->
      expect(@$el.next()[0]).to.be.eql @$insertedEl[0]

    it 'triggers refresh event on $parentEl', ->
      expect(@spyFn).to.be.calledOnce

  describe '.remove', ->
    it 'removes element from DOM', ->
      $el = @$els.find('#view3')
      DOM.remove($el)
      expect(@$els.find('#view3').length).to.be.equal 0

  describe 'Async DOM modifying', ->

    before ->
      $els = $(nodesWithDataView())
      $newEls = $(nodesForRefresh())

      $('body').empty().append($els)

      @dfd = new $.Deferred()
      @firstTestFn = sinon.spy()
      @secondTestFn = sinon.spy()

      @Vtree = Vtree
      @Vtree.hooks()._reset()

      @Vtree.onNodeInit (node) =>
        # update DOM when first view is initializing
        if node.isComponentIndex and node.componentName is 'TestComponent'
          @Vtree.DOM.appendAsync($('#component1'), $newEls)
        else if node.nodeName is 'TestView3'
          @firstTestFn()
        else if node.nodeName is 'TestView9'
          @secondTestFn()
          @dfd.resolve()

    after ->
      @Vtree.hooks()._reset()

    it 'modifies DOM asynchrounously', ->
      @Vtree.initNodesAsync()
      @dfd.done =>
        expect(@firstTestFn).to.be.calledOnce
        expect(@secondTestFn).to.be.calledOnce
        expect(@firstTestFn).to.be.calledBefore @secondTestFn

