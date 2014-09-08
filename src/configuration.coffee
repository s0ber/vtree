class Configuration

  viewSelector: '[data-view]'
  componentSelector: '[data-component]'
  selector: '[data-component], [data-view]'
  standAlonePattern: /(.+)#(.+)/

  isComponentIndex: ($el) ->
    $el.data('component')?

  layoutUnderscoredName: ($el) ->
    $el.data('component')

  nodeUnderscoredName: ($el) ->
    if @isComponentIndex($el) then 'layout' else $el.data('view') || ''

  isStandAlone: ($el) ->
    @standAlonePattern.test @nodeUnderscoredName($el)

  extractComponentData: ($el) ->
    [__, componentName, viewName] = @nodeUnderscoredName($el).match @standAlonePattern
    [componentName, viewName]

modula.export('vtree/configuration', Configuration)
