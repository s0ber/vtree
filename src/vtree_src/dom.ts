import addToAsyncQueue from 'async_fn'
import $ from 'jquery'

export default class DOM {
  static html($el: JQuery, html: string) {
    $el.children().each((_i, child) => { $(child).remove() })
    $el.html(html)
    $el.trigger('refresh')
  }

  static append($parentEl: JQuery, $el: JQuery) {
    $parentEl.append($el)
    $parentEl.trigger('refresh')
  }

  static prepend($parentEl: JQuery, $el: JQuery) {
    $parentEl.prepend($el)
    $parentEl.trigger('refresh')
  }

  static before($el: JQuery, $inserterdEl: JQuery) {
    $el.before($inserterdEl)
    $el.parent().trigger('refresh')
  }

  static after($el: JQuery, $inserterdEl: JQuery) {
    $el.after($inserterdEl)
    $el.parent().trigger('refresh')
  }

  static remove($el: JQuery) {
    $el.remove()
  }

  static htmlAsync($el: JQuery, html: string) {
    addToAsyncQueue(() =>
      new Promise<void>(resolve => {
        requestAnimationFrame(() => {
          $el.children().each((_i, child) => { $(child).remove() })
          $el.html(html)
          $el.trigger('refresh')
          resolve()
        })
      }))
  }

  static appendAsync($parentEl: JQuery, $el: JQuery) {
    addToAsyncQueue(() =>
      new Promise<void>(resolve => {
        requestAnimationFrame(() => {
          $parentEl.append($el)
          $parentEl.trigger('refresh')
          resolve()
        })
      }))
  }

  static prependAsync($parentEl: JQuery, $el: JQuery) {
    addToAsyncQueue(() =>
      new Promise<void>(resolve => {
        requestAnimationFrame(() => {
          $parentEl.prepend($el)
          $parentEl.trigger('refresh')
          resolve()
        })
      }))
  }

  static beforeAsync($el: JQuery, $inserterdEl: JQuery) {
    addToAsyncQueue(() =>
      new Promise<void>(resolve => {
        requestAnimationFrame(() => {
          $el.before($inserterdEl)
          $el.parent().trigger('refresh')
          resolve()
        })
      }))
  }

  static afterAsync($el: JQuery, $inserterdEl: JQuery) {
    addToAsyncQueue(() =>
      new Promise<void>(resolve => {
        requestAnimationFrame(() => {
          $el.after($inserterdEl)
          $el.parent().trigger('refresh')
          resolve()
        })
    }))
  }
}
