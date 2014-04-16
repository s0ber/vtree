class DOM

  @html: ($el, html) ->
    $el.html(html)
    $el.trigger('refresh')

  @append: ($parentEl, $el) ->
    $parentEl.append($el)
    $parentEl.trigger('refresh')

  @prepend: ($parentEl, $el) ->
    $parentEl.prepend($el)
    $parentEl.trigger('refresh')

  @before: ($el, $inserterdEl) ->
    return if $el[0] is document.body
    $el.before($inserterdEl)
    $el.parent().trigger('refresh')

  @after: ($el, $inserterdEl) ->
    return if $el[0] is document.body
    $el.after($inserterdEl)
    $el.parent().trigger('refresh')

  @remove: ($el) ->
    $el.remove()

modula.export('vtree/dom', DOM)
window.Vtree.DOM = DOM
