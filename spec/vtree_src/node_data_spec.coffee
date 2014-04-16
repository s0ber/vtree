NodeData = modula.require('vtree/node_data')

describe 'NodeData', ->

  beforeEach ->
    @options =
      isApplicationLayout: true
      isApplicationPart: false
      isComponentPart: false
      applicationId: 1

      nodeName: 'TestView'
      applicationName: 'TestApp'
      componentName: null

      nodeNameUnderscored: 'test_view'
      applicationNameUnderscored: 'test_app'
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