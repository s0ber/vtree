gulp = require('gulp')
gutil = require('gulp-util')
coffee = require('gulp-coffee')
concat = require('gulp-concat')
header = require('gulp-header')
uglify = require('gulp-uglify')
rename = require('gulp-rename')
karma = require('gulp-karma')

projectHeader = '/*! Vtree (v0.1.2),\n
                simple library for creating complicated architectures,\n
                by Sergey Shishkalov <sergeyshishkalov@gmail.com>\n
                <%= new Date().toDateString() %> */\n'

fixtureFiles = [
  'spec/fixtures/**/*.html'
]

vendorFiles = [
  'bower_components/jquery/dist/jquery.js'
  'bower_components/underscore/underscore.js'
]

sourceFiles = [
  'src/modula.coffee'
  'src/configuration.coffee'
  'src/vtree.coffee'
  'src/vtree_src/hooks.coffee'
  'src/vtree_src/vtree_nodes_cache.coffee'
  'src/vtree_src/node.coffee'
  'src/vtree_src/node_data.coffee'
  'src/vtree_src/node_wrapper.coffee'
  'src/vtree_src/tree_manager.coffee'
  'src/vtree_src/launcher.coffee'
  'src/vtree_src/dom.coffee'
]

specFiles = fixtureFiles
  .concat(vendorFiles)
  .concat(sourceFiles)
  .concat(['spec/**/*_spec.coffee'])

gulp.task 'build', ->
  gulp.src(sourceFiles)
    .pipe(coffee(bare: false).on('error', gutil.log))
    .pipe(concat('vtree.js'))
    .pipe(header(projectHeader))
    .pipe(gulp.dest('build/'))

gulp.task 'minify', ['build'], ->
  gulp.src('build/vtree.js')
    .pipe(uglify(outSourceMap: false))
    .pipe(rename(suffix: '.min'))
    .pipe(header(projectHeader))
    .pipe(gulp.dest('build/'))

gulp.task 'prepare', ['minify']

gulp.task 'karma:release', ->
  gulp.src(specFiles)
    .pipe(karma(
      configFile: 'karma.conf.coffee'
    ))

gulp.task 'karma:ci', ->
  gulp.src(specFiles)
    .pipe(karma(
      configFile: 'karma.conf.coffee'
      browsers: ['PhantomJS']
    ))

gulp.task 'karma:dev', ->
  gulp.src(specFiles)
    .pipe(karma(
      configFile: 'karma.conf.coffee'
      reporters: ['dots']
      action: 'watch'
    ))
