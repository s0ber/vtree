Vtree = require 'src/vtree'
$ = require 'jquery'
nodesForRefresh = require('./fixtures/nodes_for_refresh')
nodesWithDataView = require('./fixtures/nodes_with_data_view')

ERROR_MESSAGE = "You can't start initializing new nodes"

describe 'Initializing nodes while other nodes initializing', ->
  beforeEach ->
    Vtree.hooks()._reset()
    $('body').html(nodesWithDataView)

  after ->
    Vtree.hooks()._reset()

  context 'not trying to modify DOM in the middle of initial nodes initialization', ->
    beforeEach ->
      Vtree.onNodeInit (node) ->

    it 'does not throw Vtree error', ->
      expect(->
        Vtree.initNodes()
      ).not.to.throw(ERROR_MESSAGE)

  context 'trying to modify DOM in the middle of initial nodes initialization', ->
    beforeEach ->
      Vtree.onNodeInit (node) ->
        Vtree.DOM.html($('#component1'), nodesForRefresh) if node.nodeName is 'TestView2'

    it 'throws Vtree error', ->
      expect(->
        Vtree.initNodes()
      ).to.throw(ERROR_MESSAGE)

  context 'trying to asynchronously modify DOM in the middle of initial nodes initialization', ->
    beforeEach ->
      Vtree.onNodeInit (node) ->
        Vtree.DOM.htmlAsync($('#component1'), nodesForRefresh) if node.nodeName is 'TestView2'

    it 'does not throw Vtree error', ->
      expect(->
        Vtree.initNodes()
      ).not.to.throw(ERROR_MESSAGE)

  context 'not trying to modify DOM in the middle of subsequent nodes initialization', ->
    beforeEach ->
      Vtree.onNodeInit (node) ->

    it 'does not throw Vtree error', ->
      expect(->
        Vtree.initNodes()
        Vtree.DOM.html($('#component1'), nodesForRefresh)
      ).not.to.throw(ERROR_MESSAGE)

  context 'trying to modify DOM in the middle of subsequent nodes initialization', ->
    beforeEach ->
      Vtree.onNodeInit (node) ->
        Vtree.DOM.html($('#component2'), '<div>TEST HTML</div>') if node.nodeName is 'TestView7'

    it 'throws Vtree error', ->
      expect(->
        Vtree.initNodes()
        Vtree.DOM.html($('#component1'), nodesForRefresh)
      ).to.throw(ERROR_MESSAGE)

  context 'trying to asynchronously modify DOM in the middle of subsequent nodes initialization', ->
    beforeEach ->
      Vtree.onNodeInit (node) ->
        Vtree.DOM.htmlAsync($('#component2'), '<div>TEST HTML</div>') if node.nodeName is 'TestView7'

    it 'does not throw Vtree error', ->
      expect(->
        Vtree.initNodes()
        Vtree.DOM.html($('#component1'), nodesForRefresh)
      ).not.to.throw(ERROR_MESSAGE)
