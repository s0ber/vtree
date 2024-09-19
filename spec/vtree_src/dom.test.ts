import $ from 'jquery'
import Vtree from '../../src/vtree'
import DOM from '../../src/vtree_src/dom'
import { nodesForRefresh } from '../fixtures/nodes_for_refresh'
import { nodesWithDataView } from '../fixtures/nodes_with_data_view'

describe('DOM', () => {
  let $els: JQuery
  let $newEls: JQuery

  beforeEach(() => {
    $els = $(nodesWithDataView)
    $newEls = $(nodesForRefresh)
  })

  describe('.html', () => {
    let $el: JQuery
    let html: string

    beforeEach(() => {
      $el = $els.find('#view3')
      html = $newEls.wrap('<div/>').parent().html()

      jest.spyOn($el, 'trigger')
      DOM.html($el, html)
    })

    it('sets html to element', () => {
      expect($el.html()).toBe(html)
    })

    it('triggers refresh event on $el', () => {
      expect($el.trigger).toHaveBeenCalledOnce()
      expect($el.trigger).toHaveBeenCalledWith('refresh')
    })
  })

  describe('.append', () => {
    let $parentEl: JQuery
    let $el: JQuery

    beforeEach(() => {
      $parentEl = $els
      $el = $newEls
      jest.spyOn($parentEl, 'trigger')

      DOM.append($parentEl, $el)
    })

    it('appends $el to $parentEl', () => {
      expect($parentEl.children().last()[0]).toBe($el[0])
  })

    it('triggers refresh event on $parentEl', () => {
      expect($parentEl.trigger).toHaveBeenCalledOnce()
      expect($parentEl.trigger).toHaveBeenCalledWith('refresh')
    })
  })

  describe('.prepend', () => {
    let $parentEl: JQuery
    let $el: JQuery

    beforeEach(() => {
      $parentEl = $els
      $el = $newEls

      jest.spyOn($parentEl, 'trigger')
      DOM.prepend($parentEl, $el)
    })

    it('prepends $el to $parentEl', () => {
      expect($parentEl.children()[0]).toBe($el[0])
  })

    it('triggers refresh event on $parentEl', () => {
      expect($parentEl.trigger).toHaveBeenCalledOnce()
      expect($parentEl.trigger).toHaveBeenCalledWith('refresh')
    })
  })

  describe('.before', () => {
    let $el: JQuery
    let $insertedEl: JQuery
    let $parentEl: JQuery
    let spyFn: jest.Mock

    beforeEach(() => {
      $el = $els.find('#view3')
      $insertedEl = $newEls

      $parentEl = $el.parent()
      spyFn = jest.fn()
      $parentEl.on('refresh', spyFn)

      DOM.before($el, $insertedEl)
    })

    it('inserts $insertedEl before $el', () => {
      expect($el.prev()[0]).toBe($insertedEl[0])
  })

    it('triggers refresh event on $parentEl', () => {
      expect(spyFn).toHaveBeenCalledOnce()
    })
  })

  describe('.after', () => {
    let $el: JQuery
    let $insertedEl: JQuery
    let $parentEl: JQuery
    let spyFn: jest.Mock

    beforeEach(() => {
      $el = $els.find('#view3')
      $insertedEl = $newEls

      $parentEl = $el.parent()
      spyFn = jest.fn()
      $parentEl.on('refresh', spyFn)

      DOM.after($el, $insertedEl)
    })

    it('inserts $insertedEl after $el', () => {
      expect($el.next()[0]).toBe($insertedEl[0])
  })

    it('triggers refresh event on $parentEl', () => {
      expect(spyFn).toHaveBeenCalledOnce()
    })
  })

  describe('.remove', () => {
    it('removes element from DOM', () => {
      const $el = $els.find('#view3')
      DOM.remove($el)
      expect($els.find('#view3').length).toBe(0)
    })
  })

  describe('Async DOM modifying', () => {
    let promise: Promise<void>
    let firstTestFn: jest.Mock
    let secondTestFn: jest.Mock

    beforeEach(() => {
      const $els = $(nodesWithDataView)
      const $newEls = $(nodesForRefresh)

      $('body').empty().append($els)

      firstTestFn = jest.fn()
      secondTestFn = jest.fn()

      Vtree.hooks.reset()

      promise = new Promise(resolve => {
        Vtree.onNodeInit(node => {
          // update DOM when first view is initializing
          if (node.isComponentIndex && (node.componentName === 'TestComponent')) {
            Vtree.DOM.appendAsync($('#component1'), $newEls)
          } else if (node.nodeName === 'TestView3') {
            firstTestFn()
          } else if (node.nodeName === 'TestView9') {
            secondTestFn()
            resolve()
          }
        })
      })
    })

    afterEach(() => {
      Vtree.hooks.reset()
    })

    it('modifies DOM asynchrounously', (done) => {
      Vtree.initNodesAsync()
      expect(firstTestFn).not.toHaveBeenCalled()
      expect(secondTestFn).not.toHaveBeenCalled()

      promise.then(() => {
        expect(firstTestFn).toHaveBeenCalledOnce()
        expect(secondTestFn).toHaveBeenCalledOnce()
        expect(firstTestFn).toHaveBeenCalledBefore(secondTestFn)

        done()
      })
    })
  })
})

