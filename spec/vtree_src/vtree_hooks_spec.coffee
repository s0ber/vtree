VtreeHooks = require('vtree/vtree_hooks')

describe 'VtreeHooks', ->

  beforeEach ->
    @hooks = new VtreeHooks()
    @callback = sinon.spy()
    @secondCallback = sinon.spy()
    @thirdCallback = sinon.spy()

  describe 'Initialization behavior', ->

    describe '.onInit', ->
      it 'saves reference to provided callback inside @onInitCallbacks()', ->
        @hooks.onInit(@callback)
        @hooks.onInit(@secondCallback)
        @hooks.onInit(@thirdCallback)

        expect(@hooks.onInitCallbacks()).to.be.eql [@callback, @secondCallback, @thirdCallback]

    describe '.init', ->
      it 'calls @onInitCallbacks() callbacks one by one', ->
        @hooks.onInit(@callback)
        @hooks.onInit(@secondCallback)
        @hooks.onInit(@thirdCallback)
        @hooks.init()

        expect(@callback).to.be.called.once
        expect(@secondCallback).to.be.called.once
        expect(@callback).to.be.calledBefore(@secondCallback)
        expect(@secondCallback).to.be.calledBefore(@thirdCallback)

      it 'calls @onInitCallbacks() callbacks with provided arguments', ->
        arg1 = 'argument 1'
        arg2 = 'argument 2'

        @hooks.onInit(@callback)
        @hooks.onInit(@secondCallback)
        @hooks.init(arg1, arg2)

        expect(@callback.lastCall.args).to.be.eql [arg1, arg2]
        expect(@secondCallback.lastCall.args).to.be.eql [arg1, arg2]

  describe 'Activation behavior', ->

    describe '.onActivation', ->
      it 'saves reference to provided callback inside @onActivationCallbacks()', ->
        @hooks.onActivation(@callback)
        @hooks.onActivation(@secondCallback)
        @hooks.onActivation(@thirdCallback)

        expect(@hooks.onActivationCallbacks()).to.be.eql [@callback, @secondCallback, @thirdCallback]

    describe '.activate', ->
      it 'calls @onActivationCallbacks() callbacks one by one', ->
        @hooks.onActivation(@callback)
        @hooks.onActivation(@secondCallback)
        @hooks.onActivation(@thirdCallback)
        @hooks.activate()

        expect(@callback).to.be.called.once
        expect(@secondCallback).to.be.called.once
        expect(@callback).to.be.calledBefore(@secondCallback)
        expect(@secondCallback).to.be.calledBefore(@thirdCallback)

      it 'calls @onActivationCallbacks() callbacks with provided arguments', ->
        arg1 = 'argument 1'
        arg2 = 'argument 2'

        @hooks.onActivation(@callback)
        @hooks.onActivation(@secondCallback)
        @hooks.activate(arg1, arg2)

        expect(@callback.lastCall.args).to.be.eql [arg1, arg2]
        expect(@secondCallback.lastCall.args).to.be.eql [arg1, arg2]

  describe 'Unload behavior', ->

    describe '.onUnload', ->
      it 'saves reference to provided callback inside @onUnloadCallbacks()', ->
        @hooks.onUnload(@callback)
        @hooks.onUnload(@secondCallback)
        @hooks.onUnload(@thirdCallback)

        expect(@hooks.onUnloadCallbacks()).to.be.eql [@callback, @secondCallback, @thirdCallback]

    describe '.unload', ->
      it 'calls @onUnloadCallbacks() callbacks one by one', ->
        @hooks.onUnload(@callback)
        @hooks.onUnload(@secondCallback)
        @hooks.onUnload(@thirdCallback)
        @hooks.unload()

        expect(@callback).to.be.called.once
        expect(@secondCallback).to.be.called.once
        expect(@callback).to.be.calledBefore(@secondCallback)
        expect(@secondCallback).to.be.calledBefore(@thirdCallback)

      it 'calls @onUnloadCallbacks() callbacks with provided arguments', ->
        arg1 = 'argument 1'
        arg2 = 'argument 2'

        @hooks.onUnload(@callback)
        @hooks.onUnload(@secondCallback)
        @hooks.unload(arg1, arg2)

        expect(@callback.lastCall.args).to.be.eql [arg1, arg2]
        expect(@secondCallback.lastCall.args).to.be.eql [arg1, arg2]
