module.exports = function(config) {
  config.set({
    preprocessors: {
      'spec/index.js': ['webpack']
    },
    frameworks: ['mocha', 'sinon-chai'],
    files: ['spec/index.js'],
    reporters: ['mocha'],
    mochaReporter: {
      output: 'autowatch'
    },
    port: 9876,
    colors: true,
    autoWatch: true,
    browsers: ['PhantomJS'],
    plugins: [
      require('karma-webpack'),
      require('karma-mocha'),
      require('karma-sinon-chai'),
      require('karma-phantomjs-launcher'),
      require('karma-mocha-reporter')
    ],
    webpack: require('./webpack.config.js'),
    webpackMiddleware: {
      stats: {
        assets: false,
        chunks: false,
        hash: false,
        timings: false,
        version: false
      }
    }
  })
}
