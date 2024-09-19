import Vtree from '../src/vtree'
import $ from 'jquery'

import { nodesForRefresh } from './fixtures/nodes_for_refresh'
import { nodesWithDataView } from './fixtures/nodes_with_data_view'

const ERROR_MESSAGE = "You can't start initializing new nodes"

describe('Initializing nodes while other nodes initializing', () => {
  beforeEach(() => {
    Vtree.hooks.reset()
    $('body').html(nodesWithDataView)
  })

  afterAll(() => Vtree.hooks.reset())

  describe('not trying to modify DOM in the middle of initial nodes initialization', () => {
    beforeEach(() => {
      Vtree.onNodeInit(() => {})
    })

    it('does not throw Vtree error', () => {
      expect(() => Vtree.initNodes()).not.toThrow(ERROR_MESSAGE)
    })
  })

  describe('trying to modify DOM in the middle of initial nodes initialization', () => {
    beforeEach(() => Vtree.onNodeInit(function(node) {
      if (node.nodeName === 'TestView2') { Vtree.DOM.html($('#component1'), nodesForRefresh) }
    }))

    it('throws Vtree error', () => {
      expect(() => Vtree.initNodes()).toThrow(ERROR_MESSAGE)
    })
  })

  describe('trying to asynchronously modify DOM in the middle of initial nodes initialization', () => {
    beforeEach(() => {
      Vtree.onNodeInit((node) => {
        if (node.nodeName === 'TestView2') Vtree.DOM.htmlAsync($('#component1'), nodesForRefresh)
      })
    })

    it('does not throw Vtree error', () => {
      expect(() => Vtree.initNodes()).not.toThrow(ERROR_MESSAGE)
    })
  })

  describe('not trying to modify DOM in the middle of subsequent nodes initialization', () => {
    beforeEach(() => Vtree.onNodeInit(() => {}))

    it('does not throw Vtree error', () => {
      expect(() => {
        Vtree.initNodes()
        Vtree.DOM.html($('#component1'), nodesForRefresh)
      }).not.toThrow(ERROR_MESSAGE)
    })
  })

  describe('trying to modify DOM in the middle of subsequent nodes initialization', () => {
    beforeEach(() => {
      Vtree.onNodeInit(node => {
        if (node.nodeName === 'TestView7') Vtree.DOM.html($('#component2'), '<div>TEST HTML</div>')
      })
    })

    it('throws Vtree error', () => {
      expect(() => {
        Vtree.initNodes()
        Vtree.DOM.html($('#component1'), nodesForRefresh)
      }).toThrow(ERROR_MESSAGE)
    })
  })

  describe('trying to asynchronously modify DOM in the middle of subsequent nodes initialization', () => {
    beforeEach(() => {
      Vtree.onNodeInit(node => {
        if (node.nodeName === 'TestView7') Vtree.DOM.htmlAsync($('#component2'), '<div>TEST HTML</div>')
      })
    })

    it('does not throw Vtree error', () => {
      expect(() => {
        Vtree.initNodes()
        Vtree.DOM.html($('#component1'), nodesForRefresh)
      }).not.toThrow(ERROR_MESSAGE)
    })
  })
})
