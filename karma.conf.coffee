module.exports = (config) ->
  config.set
    preprocessors:
      '**/*.coffee': ['coffee'],
      '**/*.html': ['html2js']
    basePath: ''
    frameworks: ['mocha', 'sinon-chai']
    exclude: []
    reporters: ['progress']
    port: 9876
    colors: true
    autoWatch: true
    browsers: ['PhantomJS']
    captureTimeout: 60000
    singleRun: false

    coffeePreprocessor:
      options: {bare: false}
