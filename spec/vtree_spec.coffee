Configuration = modula.require('vtree/configuration')
Vtree = modula.require('vtree')

Launcher =
  launch: sinon.spy()
  createViewsTree: sinon.spy()

describe 'Vtree', ->

  before ->
    @initialLauncher = Vtree._launcher
    Vtree._launcher = (-> Launcher)

  after ->
    Vtree._launcher = @initialLauncher

  describe '.initNodes', ->
    it "calls Launcher's launch and createViewsTree functions", ->
      Vtree.initNodes()
      expect(Launcher.launch).to.be.calledOnce
      expect(Launcher.createViewsTree).to.be.calledOnce

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

  describe '.configure', ->
    it 'extends configuration data with provided options', ->
      config = new Configuration
      Vtree.config = -> config
      Vtree.configure
        viewSelector: '.test_view_selector'
        appSelector: '.test_app_selector'

      expect(Vtree.config().viewSelector).to.be.equal '.test_view_selector'
      expect(Vtree.config().appSelector).to.be.equal '.test_app_selector'
