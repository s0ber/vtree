module.exports = function (grunt) {
  grunt.initConfig({
    karma: {
      options: {
        basePath: '',
        frameworks: ['mocha', 'sinon-chai'],
        files: [
          { pattern: 'spec/fixtures/*.html',
            included: true },

          'bower_components/jquery/dist/jquery.js',
          'bower_components/modula/lib/modula.js',
          'bower_components/sugar/release/sugar-full.development.js',
          'bower_components/underscore/underscore.js',

          'src/vtree_src/view_nodes_cache.coffee',
          'src/vtree_src/hooks.coffee',
          'src/vtree_src/view_node.coffee',
          'src/vtree_src/view_wrapper.coffee',
          'src/vtree_src/tree_manager.coffee',
          'src/vtree_src/launcher.coffee',
          'src/vtree.coffee',

          'spec/**/*_spec.coffee'
        ],
        exclude: [],
        reporters: ['progress'],
        port: 9876,
        colors: true,
        autoWatch: true,
        browsers: ['PhantomJS'],
        captureTimeout: 60000,
        singleRun: false,
        coffeePreprocessor: {
          options: {
            bare: false
          }
        }
      },
      dev: {
        reporters: ['dots']
      },
      release: {
        singleRun: true
      },
      ci: {
        singleRun: true,
        browsers: ['PhantomJS']
      }
    }
  });

  grunt.loadNpmTasks('grunt-karma');
};
