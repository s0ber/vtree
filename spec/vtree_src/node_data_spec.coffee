NodeData = modula.require('vtree/node_data')

describe 'NodeData', ->

  beforeEach ->
    @options =
      isComponentIndex: true
      isComponentPart: true
      isStandAlone: false
      componentId: 1

      nodeName: 'TestView'
      componentName: 'TestComponent'
      namespaceName: null

      nodeNameUnderscored: 'test_view'
      componentNameUnderscored: 'test_component'
      componentNameUnderscored: null

    @nodeData = new NodeData(@options)

  describe '.setData', ->
    it 'saves data by given name', ->
      @nodeData.setData('ololo', 'MyData')
      expect(@nodeData.getData('ololo')).to.be.eql 'MyData'

  describe '.getData', ->
    it 'shows previously saved data', ->
      @nodeData.setData('ololo', 'MyData')
      expect(@nodeData.getData('ololo')).to.be.eql 'MyData'
