DOM = modula.require('vtree/dom')

describe 'DOM', ->

  $render = (name) ->
    $(window.__html__["spec/fixtures/#{name}.html"])

  beforeEach ->
    @$els = $render('nodes_with_data_view')
    @$newEls = $render('nodes_for_refresh')

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
