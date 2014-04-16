class Configuration
  viewSelector: '[data-view]'
  appPelector: '[data-app]'
  selector: '[data-app], [data-view]'

  componentPattern: /(.+)#(.+)/

  isLayout: ($el) ->
    $el.data('app')?

  layoutUnderscoredName: ($el) ->
    $el.data('app')

  viewUnderscoredName: ($el) ->
    if @isLayout($el) then 'layout' else $el.data('view') || ''

  hasComponent: ($el) ->
    @componentPattern.test @viewUnderscoredName($el)

  extractComponentData: ($el) ->
    [__, componentName, viewName] = @viewUnderscoredName($el).match @componentPattern
    [componentName, viewName]


modula.export('vtree/configuration', Configuration)
