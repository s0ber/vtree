class ViewHooks

  onInit: (callback) ->
    @onInitCallbacks().push(callback)

  onInitCallbacks: ->
    @_onInitCallbacks ||= []

  init: (args...) ->
    callback(args...) for callback in @onInitCallbacks()


  onActivation: (callback) ->
    @onActivationCallbacks().push(callback)

  onActivationCallbacks: ->
    @_onActivationCallbacks ||= []

  activate: (args...) ->
    callback(args...) for callback in @onActivationCallbacks()


  onUnload: (callback) ->
    @onUnloadCallbacks().push(callback)

  onUnloadCallbacks: ->
    @_onUnloadCallbacks ||= []

  unload: (args...) ->
    callback(args...) for callback in @onUnloadCallbacks()

modula.export('vtree/view_hooks', ViewHooks)
