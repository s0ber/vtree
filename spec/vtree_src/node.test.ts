import $ from 'jquery'
import Node from '../../src/vtree_src/node'
import Hooks from '../../src/vtree_src/hooks'

type NodeHooks = Hooks<(node: Node) => void>

describe('Node', () => {
  let $el: JQuery
  let $secondEl: JQuery
  let $thirdEl: JQuery
  let $fourthEl: JQuery

  let node: Node
  let secondNode: Node
  let thirdNode: Node
  let fourthNode: Node

  beforeEach(() => {
    $el = $('div')
    $secondEl = $('div')
    $thirdEl = $('div')
    $fourthEl = $('div')

    node = new Node($el)
    secondNode = new Node($secondEl)
    thirdNode = new Node($thirdEl)
    fourthNode = new Node($fourthEl)
  })

  describe('.constructor', () => {
    it('has uniq id', () => {
      const ids = [node.id, secondNode.id, thirdNode.id]
      const uniqIds = ids.filter((value, index, array) => array.indexOf(value) === index)

      expect(uniqIds).toHaveLength(3)
    })

    it('has reference to provided Hooks instance if provided', () => {
      const hooks = new Hooks()
      const node = new Node($el, hooks)
      expect(node.hooks).toEqual(hooks)
    })

    it('has reference to provided jquery dom element', () => {
      expect(node.$el).toEqual($el)
      expect(node.el).toEqual($el[0])
  })

    it('has null reference for @parent', () => {
      expect(node.parent).toBe(undefined)
    })

    it('has empty list reference for @children', () => {
      expect(node.children).toEqual([])
  })

    it('calls .init method', () => {
      jest.spyOn(Node.prototype, 'init')
      node = new Node($el)

      expect(node.init).toHaveBeenCalledOnce()
    })
  })

  describe('.setParent', () => {
    it('sets provided Node instance as @parent', () => {
      node.setParent(secondNode)
      expect(node.parent).toEqual(secondNode)
    })
  })

  describe('.prependChild', () => {
    it('prepends provided Node instance to @children array', () => {
      node.prependChild(secondNode)
      expect(node.children).toEqual([secondNode])
      node.prependChild(fourthNode)
      expect(node.children).toEqual([fourthNode, secondNode])
    })
  })

  describe('.appendChild', () => {
    it('appends provided Node instance to @children array', () => {
      node.appendChild(secondNode)
      expect(node.children).toEqual([secondNode])
      node.appendChild(fourthNode)
      expect(node.children).toEqual([secondNode, fourthNode])
  })
})

  describe('.removeChild', () => {
    it('removes provided child from @children', () => {
      secondNode.setParent(node)
      fourthNode.setParent(node)

      node.appendChild(secondNode)
      node.appendChild(fourthNode)

      node.removeChild(secondNode)
      expect(node.children).toEqual([fourthNode])
    })

    it('does nothing if provided child is not in @children', () => {
      secondNode.setParent(node)
      fourthNode.setParent(node)

      node.appendChild(secondNode)
      node.appendChild(fourthNode)

      node.removeChild(thirdNode)
      expect(node.children).toEqual([secondNode, fourthNode])
  })
})

  describe('Initialization behavior', () => {
    let hooks: NodeHooks

    beforeEach(() => {
      hooks = new Hooks()
      hooks.init = jest.fn()
      node = new Node($el, hooks)
    })

    describe('.init', () => {
      it('calls @hooks.init method', () => {
        expect(hooks.init).toHaveBeenCalledOnce()
      })

      it('calls @hooks.init with current node instance as first argument', () => {
        expect(hooks.init).toHaveBeenCalledWith(node)
      })
    })
  })

  describe('Activation behavior', () => {
    let hooks: NodeHooks

    beforeEach(() => {
      hooks = new Hooks()
      hooks.activate = jest.fn()

      node = new Node($el, hooks)
    })

    describe('.activate', () => {
      it('calls @hooks.activate method', () => {
        node.activate()
        expect(hooks.activate).toHaveBeenCalledOnce()
      })

      it('calls @hooks.activate with current node instance as first argument', () => {
        node.activate()
        expect(hooks.activate).toHaveBeenCalledWith(node)
      })

      it('sets node as activated', () => {
        node.activate()
        expect(node.isActivated).toBe(true)
      })

      it('does nothing if node is already activated', () => {
        node.activate()
        node.activate()
        expect(hooks.activate).toHaveBeenCalledTimes(1)
      })
    })
  })

  describe('Unload behavior', () => {
    let hooks: NodeHooks

    beforeEach(() => {
      hooks = new Hooks()
      hooks.unload = jest.fn()

      node = new Node($el, hooks)
    })

    describe('.unload', () => {
      it('calls @hooks.unload method', () => {
        node.unload()
        expect(hooks.unload).toHaveBeenCalledOnce()
      })

      it('calls callbacks with current node instance as first argument', () => {
        node.unload()
        expect(hooks.unload).toHaveBeenCalledWith(node)
      })

      it('sets node as not activated', () => {
        node.activate()
        node.unload()
        expect(node.isActivated).toBe(false)
      })
    })
  })

  describe('Remove behavior', () => describe('.remove', () => {
    let hooks: NodeHooks

    beforeEach(() => {
      hooks = new Hooks()
      hooks.unload = jest.fn()

      node = new Node($el, hooks)
      secondNode = new Node($secondEl, hooks)
    })

    it('sets node as removed', () => {
      node.remove()
      expect(node.isRemoved).toBe(true)
    })

    it('unloads node only if node is activated', () => {
      node.remove()
      expect(hooks.unload).not.toHaveBeenCalled()

      secondNode.activate()
      secondNode.remove()
      expect(hooks.unload).toHaveBeenCalledWith(secondNode)
    })

    it('does nothing if node is already removed', () => {
      node.activate()
      node.remove()
      node.remove()
      expect(hooks.unload).toHaveReturnedTimes(1)
    })
  }))
})
