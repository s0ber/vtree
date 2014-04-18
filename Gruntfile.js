module.exports = function (grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    karma: {
      options: {
        preprocessors: {
          '**/*.coffee': ['coffee'],
          '**/*.html': ['html2js']
        },
        basePath: '',
        frameworks: ['mocha', 'sinon-chai'],
        files: [
          {pattern: 'spec/fixtures/**/*.html', included: true},

          'bower_components/jquery/dist/jquery.js',
          'bower_components/underscore/underscore.js',

          'src/modula.coffee',
          'src/configuration.coffee',
          'src/vtree.coffee',
          'src/vtree_src/hooks.coffee',
          'src/vtree_src/vtree_nodes_cache.coffee',
          'src/vtree_src/node.coffee',
          'src/vtree_src/node_data.coffee',
          'src/vtree_src/node_wrapper.coffee',
          'src/vtree_src/tree_manager.coffee',
          'src/vtree_src/launcher.coffee',
          'src/vtree_src/dom.coffee',

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
    },

    coffee: {
      compile: {
        files: {
          'build/vtree.js': [
            'src/modula.coffee',
            'src/configuration.coffee',
            'src/vtree.coffee',
            'src/vtree_src/hooks.coffee',
            'src/vtree_src/vtree_nodes_cache.coffee',
            'src/vtree_src/node.coffee',
            'src/vtree_src/node_data.coffee',
            'src/vtree_src/node_wrapper.coffee',
            'src/vtree_src/tree_manager.coffee',
            'src/vtree_src/launcher.coffee',
            'src/vtree_src/dom.coffee'
          ]
        }
      }
    },

    uglify: {
      options: {
        banner: '/*! Vtree (v0.1.0),\n' +
                'simple library for creating complicated architectures,\n' +
                'by Sergey Shishkalov <sergeyshishkalov@gmail.com>\n' +
                '<%= grunt.template.today("yyyy-mm-dd") %> */\n'
      },
      my_target: {
        files: {
          'build/vtree.min.js': ['build/vtree.js']
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-karma');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.registerTask('default', ['coffee', 'uglify']);
};
