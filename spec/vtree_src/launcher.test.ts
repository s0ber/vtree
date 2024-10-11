import $ from 'jquery'
import Launcher from '../../src/vtree_src/launcher'
import type TreeManager from '../../src/vtree_src/tree_manager'
import Configuration from '../../src/configuration'

import { nodesWithDataView } from '../fixtures/nodes_with_data_view'

describe('Launcher', () => {
  let launcher: Launcher
  let config: Configuration

  beforeEach(() => {
    launcher = new Launcher()
    config = new Configuration()
  })

  describe('.initRemoveEvent', () => {
    it('creates custom jquery event, which being triggered when element being removed from DOM', () => {
      launcher = new Launcher()
      launcher.initRemoveEvent()

      const fnSpy = jest.fn()
      const $el = $('<div />')
      const $el2 = $('<div />')

      $('body').append($el).append($el2)
      $el.on('remove', fnSpy)
      $el2.on('remove', fnSpy)
      $el.remove()
      $el2.remove()

      expect(fnSpy).toHaveBeenCalledTimes(2)
    })
  })

  describe('.launch', () => {
    it('initializes TreeManager instance', () => {
      launcher.launch(config)
      expect(launcher.treeManager.config).toBe(config)
      expect(launcher.treeManager.launcherHooks).toBe(launcher.hooks)
    })

    it('initializes custom jquery remove event', () => {
      jest.spyOn(launcher, 'initRemoveEvent')
      launcher.launch(config)

      expect(launcher.initRemoveEvent).toHaveBeenCalledOnce()
    })

    it('initializes custom jquery refresh event', () => {
      jest.spyOn(launcher, 'initRefreshEvent')
      launcher.launch(config)

      expect(launcher.initRefreshEvent).toHaveBeenCalledOnce()
      expect(launcher.initRefreshEvent).toHaveBeenCalledWith(config)
    })
  })

  describe('.createViewsTree', () => {
    it('creates view tree with help of @treeManager', () => {
      launcher = new Launcher()
      launcher.launch(config)

      jest.spyOn(launcher.treeManager, 'createTree')
      launcher.createViewsTree()

      expect(launcher.treeManager.createTree).toHaveBeenCalledOnce()
    })
  })

  describe('.initRefreshEvent', () => {
    it('creates custom jquery refresh event', () => {
      launcher = new Launcher()

      launcher.initRefreshEvent(config)
      expect(launcher.isRefreshEventInitialized).toBe(true)
    })

    describe('Custom jquery refresh event', () => {
      let treeManager: TreeManager

      beforeEach(() => {
        launcher.launch(config)
        treeManager = launcher.treeManager

        $('body').empty().append($(nodesWithDataView))
        treeManager.createTree()
        jest.spyOn(treeManager, 'refresh')
      })

      it("calls tree manager's refresh event", () => {
        const $el = $('body').find('#component1')
        $el.trigger('refresh')
        expect(treeManager.refresh).toHaveBeenCalledOnce()
      })

      it('looks for closest element with initialized node', () => {
        const $elWithoutView = $('body').find('#no_view')
        const $closestWithView = $('body').find('#component1')
        $elWithoutView.trigger('refresh')

        expect(treeManager.refresh).toHaveBeenCalledWith(expect.objectContaining({
          el: $closestWithView[0]
        }))
      })

      it('refreshes element if it has node', () => {
        const $el = $('body').find('#view2')
        $el.trigger('refresh')

        expect(treeManager.refresh).toHaveBeenCalledWith(expect.objectContaining({ el: $el[0] }))
      })
    })
  })
})
