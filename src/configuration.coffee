class Configuration

  viewSelector: '[data-view]'
  componentSelector: '[data-component]'
  selector: '[data-component], [data-view]'
  namespacePattern: /(.+)#(.+)/

  isComponentIndex: ($el) ->
    $el.data('component')?

  nodeUnderscoredName: ($el) ->
    if @isComponentIndex($el)
      $el.data('component')
    else
      $el.data('view') or ''

  isStandAlone: ($el) ->
    not @isComponentIndex($el) and @namespacePattern.test @nodeUnderscoredName($el)

  extractStandAloneNodeData: ($el) ->
    [__, namespaceName, nodeName] = @nodeUnderscoredName($el).match @namespacePattern
    [namespaceName, nodeName]

  extractComponentIndexNodeData: ($el) ->
    [__, namespaceName, componentName] = @nodeUnderscoredName($el).match @namespacePattern
    [namespaceName, componentName]

modula.export('vtree/configuration', Configuration)
