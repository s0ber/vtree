import $ from 'jquery'
import Hooks from '../../src/vtree_src/hooks'
import Node from '../../src/vtree_src/node'

describe('Hooks', () => {
  let hooks: Hooks
  let callback: jest.Mock
  let secondCallback: jest.Mock
  let thirdCallback: jest.Mock
  let node: Node

  beforeEach(() => {
    hooks = new Hooks()
    callback = jest.fn()
    secondCallback = jest.fn()
    thirdCallback = jest.fn()
    node = new Node($('div'))
  })

  describe('Initialization behavior', () => {
    describe('.onInit', () => {
      it('saves reference to provided callback inside @onInitCallbacks()', () => {
        hooks.onInit(callback)
        hooks.onInit(secondCallback)
        hooks.onInit(thirdCallback)

        expect(hooks.onInitCallbacks).toEqual([callback, secondCallback, thirdCallback])
      })
    })

    describe('.init', () => {
      it('calls @onInitCallbacks() callbacks one by one', () => {
        hooks.onInit(callback)
        hooks.onInit(secondCallback)
        hooks.onInit(thirdCallback)
        hooks.init(node)

        expect(callback).toHaveBeenCalledOnce()
        expect(secondCallback).toHaveBeenCalledOnce()
        expect(thirdCallback).toHaveBeenCalledOnce()
        expect(callback).toHaveBeenCalledBefore(secondCallback)
        expect(secondCallback).toHaveBeenCalledBefore(thirdCallback)
      })

      it('calls @onInitCallbacks() callbacks with provided arguments', () => {
        hooks.onInit(callback)
        hooks.onInit(secondCallback)
        hooks.init('arg1', 'arg2')

        expect(callback).toHaveBeenCalledWith('arg1', 'arg2')
        expect(secondCallback).toHaveBeenCalledWith('arg1', 'arg2')
    })
  })
})

  describe('Activation behavior', () => {
    describe('.onActivation', () => {
      it('saves reference to provided callback inside @onActivationCallbacks()', () => {
        hooks.onActivation(callback)
        hooks.onActivation(secondCallback)
        hooks.onActivation(thirdCallback)

        expect(hooks.onActivationCallbacks).toEqual([callback, secondCallback, thirdCallback])
      })
    })

    describe('.activate', () => {
      it('calls @onActivationCallbacks() callbacks one by one', () => {
        hooks.onActivation(callback)
        hooks.onActivation(secondCallback)
        hooks.onActivation(thirdCallback)
        hooks.activate(node)

        expect(callback).toHaveBeenCalledOnce()
        expect(secondCallback).toHaveBeenCalledOnce()
        expect(callback).toHaveBeenCalledBefore(secondCallback)
        expect(secondCallback).toHaveBeenCalledBefore(thirdCallback)
      })

      it('calls @onActivationCallbacks() callbacks with provided arguments', () => {
        hooks.onActivation(callback)
        hooks.onActivation(secondCallback)
        hooks.activate('arg1', 'arg2')

        expect(callback).toHaveBeenCalledWith('arg1', 'arg2')
        expect(secondCallback).toHaveBeenCalledWith('arg1', 'arg2')
      })
    })
  })

  describe('Unload behavior', () => {
    describe('.onUnload', () => it('saves reference to provided callback inside @onUnloadCallbacks()', () => {
      hooks.onUnload(callback)
      hooks.onUnload(secondCallback)
      hooks.onUnload(thirdCallback)

      expect(hooks.onUnloadCallbacks).toEqual([callback, secondCallback, thirdCallback])
    }))

    describe('.unload', () => {
      it('calls @onUnloadCallbacks() callbacks one by one', () => {
        hooks.onUnload(callback)
        hooks.onUnload(secondCallback)
        hooks.onUnload(thirdCallback)
        hooks.unload(node)

        expect(callback).toHaveBeenCalledOnce()
        expect(secondCallback).toHaveBeenCalledOnce()
        expect(callback).toHaveBeenCalledBefore(secondCallback)
        expect(secondCallback).toHaveBeenCalledBefore(thirdCallback)
      })

      it('calls @onUnloadCallbacks() callbacks with provided arguments', () => {
        hooks.onUnload(callback)
        hooks.onUnload(secondCallback)
        hooks.unload('arg1', 'arg2')

        expect(callback).toHaveBeenCalledWith('arg1', 'arg2')
        expect(secondCallback).toHaveBeenCalledWith('arg1', 'arg2')
      })
    })
  })
})
