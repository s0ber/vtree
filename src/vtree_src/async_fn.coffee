class AsyncFn

  constructor: (asyncFn) ->
    @fn = asyncFn

  done: (callback) ->
    @callback = callback
    if @isCalled
      @callback()

  call: ->
    return if @isCalled
    @fn().always =>
      @isCalled = true
      @callback() if @callback

  @addToCallQueue: (fn) ->
    asyncFn = new AsyncFn(fn)

    if @currentFn?
      @currentFn.done => asyncFn.call()
    else
      asyncFn.call()

    @currentFn = asyncFn

  @setImmediate = do ->
    head = {}
    tail = head
    ID = Math.random()

    onmessage = (e) ->
      return if e.data isnt ID
      head = head.next
      func = head.func
      delete head.func

      func()

    if window.addEventListener
      window.addEventListener "message", onmessage, false
    else
      window.attachEvent "onmessage", onmessage

    if window.postMessage
      (func) ->
        tail = tail.next = { func }
        window.postMessage(ID, "*")
    else
      (func) ->
        setTimeout(func, 0)

modula.export('vtree/async_fn', AsyncFn)
