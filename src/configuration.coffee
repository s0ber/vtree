class Configuration

  viewSelector: '[data-view]'
  compoentnSelector: '[data-component]'
  selector: '[data-component], [data-view]'
  componentPattern: /(.+)#(.+)/

  isLayout: ($el) ->
    $el.data('component')?

  layoutUnderscoredName: ($el) ->
    $el.data('component')

  nodeUnderscoredName: ($el) ->
    if @isLayout($el) then 'layout' else $el.data('view') || ''

  hasComponent: ($el) ->
    @componentPattern.test @nodeUnderscoredName($el)

  extractComponentData: ($el) ->
    [__, componentName, viewName] = @nodeUnderscoredName($el).match @componentPattern
    [componentName, viewName]

modula.export('vtree/configuration', Configuration)
