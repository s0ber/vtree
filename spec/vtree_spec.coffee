Vtree = require('vtree')
VtreeLauncher =
  launch: sinon.spy()
  createViewsTree: sinon.spy()

describe 'Vtree', ->

  before ->
    Vtree._launcher = (-> VtreeLauncher)

  describe '.initNodes', ->
    it "calls VtreeLauncher's launch and createViewsTree functions", ->
      Vtree.initNodes()
      expect(VtreeLauncher.launch).to.be.calledOnce
      expect(VtreeLauncher.createViewsTree).to.be.calledOnce

  describe '.getInitCallbacks', ->
    it 'returns empty list by default', ->
      expect(Vtree.getInitCallbacks()).to.be.eql []

  describe '.onNodeInit', ->
    it 'adds initialization callback to onInit callbacks', ->
      callback = ->
      secondCallback = ->
      Vtree.onNodeInit(callback)
      expect(Vtree.getInitCallbacks()).to.be.eql [callback]
      Vtree.onNodeInit(secondCallback)
      expect(Vtree.getInitCallbacks()).to.be.eql [callback, secondCallback]

  describe '.getUnloadCallbacks', ->
    it 'returns empty list by default', ->
      expect(Vtree.getUnloadCallbacks()).to.be.eql []

  describe '.onNodeUnload', ->
    it 'adds unload callback to onUnload callbacks', ->
      callback = ->
      secondCallback = ->
      Vtree.onNodeUnload(callback)
      expect(Vtree.getUnloadCallbacks()).to.be.eql [callback]
      Vtree.onNodeUnload(secondCallback)
      expect(Vtree.getUnloadCallbacks()).to.be.eql [callback, secondCallback]
