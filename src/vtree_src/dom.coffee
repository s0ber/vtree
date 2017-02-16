{$, AsyncFn} = require '../libs'

module.exports = class DOM

  @html: ($el, html) ->
    $el.children().each (i, child) -> $(child).remove()
    $el.html(html)
    $el.trigger('refresh')

  @append: ($parentEl, $el) ->
    $parentEl.append($el)
    $parentEl.trigger('refresh')

  @prepend: ($parentEl, $el) ->
    $parentEl.prepend($el)
    $parentEl.trigger('refresh')

  @before: ($el, $inserterdEl) ->
    $el.before($inserterdEl)
    $el.parent().trigger('refresh')

  @after: ($el, $inserterdEl) ->
    $el.after($inserterdEl)
    $el.parent().trigger('refresh')

  @remove: ($el) ->
    $el.remove()

  @htmlAsync: ($el, html) ->
    AsyncFn.addToCallQueue ->
      dfd = new $.Deferred()
      AsyncFn.setImmediate ->
        $el.children().each (i, child) -> $(child).remove()
        $el.html(html)
        $el.trigger('refresh')
        dfd.resolve()
      dfd.promise()

  @appendAsync: ($parentEl, $el) ->
    AsyncFn.addToCallQueue ->
      dfd = new $.Deferred()
      AsyncFn.setImmediate ->
        $parentEl.append($el)
        $parentEl.trigger('refresh')
        dfd.resolve()
      dfd.promise()

  @prependAsync: ($parentEl, $el) ->
    AsyncFn.addToCallQueue ->
      dfd = new $.Deferred()
      AsyncFn.setImmediate ->
        $parentEl.prepend($el)
        $parentEl.trigger('refresh')
        dfd.resolve()
      dfd.promise()

  @beforeAsync: ($el, $inserterdEl) ->
    AsyncFn.addToCallQueue ->
      dfd = new $.Deferred()
      AsyncFn.setImmediate ->
        $el.before($inserterdEl)
        $el.parent().trigger('refresh')
        dfd.resolve()
      dfd.promise()

  @afterAsync: ($el, $inserterdEl) ->
    AsyncFn.addToCallQueue ->
      dfd = new $.Deferred()
      AsyncFn.setImmediate ->
        $el.after($inserterdEl)
        $el.parent().trigger('refresh')
        dfd.resolve()
      dfd.promise()
