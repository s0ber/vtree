ViewHooks = require('vtree/view_hooks')

describe 'ViewHooks', ->

  beforeEach ->
    @viewHooks = new ViewHooks()
    @callback = sinon.spy()
    @secondCallback = sinon.spy()
    @thirdCallback = sinon.spy()

  describe 'Initialization behavior', ->

    describe '.onInit', ->
      it 'saves reference to provided callback inside @onInitCallbacks()', ->
        @viewHooks.onInit(@callback)
        @viewHooks.onInit(@secondCallback)
        @viewHooks.onInit(@thirdCallback)

        expect(@viewHooks.onInitCallbacks()).to.be.eql [@callback, @secondCallback, @thirdCallback]

    describe '.init', ->
      it 'calls @onInitCallbacks() callbacks one by one', ->
        @viewHooks.onInit(@callback)
        @viewHooks.onInit(@secondCallback)
        @viewHooks.onInit(@thirdCallback)
        @viewHooks.init()

        expect(@callback).to.be.called.once
        expect(@secondCallback).to.be.called.once
        expect(@callback).to.be.calledBefore(@secondCallback)
        expect(@secondCallback).to.be.calledBefore(@thirdCallback)

      it 'calls @onInitCallbacks() callbacks with provided arguments', ->
        arg1 = 'argument 1'
        arg2 = 'argument 2'

        @viewHooks.onInit(@callback)
        @viewHooks.onInit(@secondCallback)
        @viewHooks.init(arg1, arg2)

        expect(@callback.lastCall.args).to.be.eql [arg1, arg2]
        expect(@secondCallback.lastCall.args).to.be.eql [arg1, arg2]

  describe 'Activation behavior', ->

    describe '.onActivation', ->
      it 'saves reference to provided callback inside @onActivationCallbacks()', ->
        @viewHooks.onActivation(@callback)
        @viewHooks.onActivation(@secondCallback)
        @viewHooks.onActivation(@thirdCallback)

        expect(@viewHooks.onActivationCallbacks()).to.be.eql [@callback, @secondCallback, @thirdCallback]

    describe '.activate', ->
      it 'calls @onActivationCallbacks() callbacks one by one', ->
        @viewHooks.onActivation(@callback)
        @viewHooks.onActivation(@secondCallback)
        @viewHooks.onActivation(@thirdCallback)
        @viewHooks.activate()

        expect(@callback).to.be.called.once
        expect(@secondCallback).to.be.called.once
        expect(@callback).to.be.calledBefore(@secondCallback)
        expect(@secondCallback).to.be.calledBefore(@thirdCallback)

      it 'calls @onActivationCallbacks() callbacks with provided arguments', ->
        arg1 = 'argument 1'
        arg2 = 'argument 2'

        @viewHooks.onActivation(@callback)
        @viewHooks.onActivation(@secondCallback)
        @viewHooks.activate(arg1, arg2)

        expect(@callback.lastCall.args).to.be.eql [arg1, arg2]
        expect(@secondCallback.lastCall.args).to.be.eql [arg1, arg2]

  describe 'Unload behavior', ->

    describe '.onUnload', ->
      it 'saves reference to provided callback inside @onUnloadCallbacks()', ->
        @viewHooks.onUnload(@callback)
        @viewHooks.onUnload(@secondCallback)
        @viewHooks.onUnload(@thirdCallback)

        expect(@viewHooks.onUnloadCallbacks()).to.be.eql [@callback, @secondCallback, @thirdCallback]

    describe '.unload', ->
      it 'calls @onUnloadCallbacks() callbacks one by one', ->
        @viewHooks.onUnload(@callback)
        @viewHooks.onUnload(@secondCallback)
        @viewHooks.onUnload(@thirdCallback)
        @viewHooks.unload()

        expect(@callback).to.be.called.once
        expect(@secondCallback).to.be.called.once
        expect(@callback).to.be.calledBefore(@secondCallback)
        expect(@secondCallback).to.be.calledBefore(@thirdCallback)

      it 'calls @onUnloadCallbacks() callbacks with provided arguments', ->
        arg1 = 'argument 1'
        arg2 = 'argument 2'

        @viewHooks.onUnload(@callback)
        @viewHooks.onUnload(@secondCallback)
        @viewHooks.unload(arg1, arg2)

        expect(@callback.lastCall.args).to.be.eql [arg1, arg2]
        expect(@secondCallback.lastCall.args).to.be.eql [arg1, arg2]
