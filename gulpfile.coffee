gulp = require('gulp')
gutil = require('gulp-util')
coffee = require('gulp-coffee')
concat = require('gulp-concat')
header = require('gulp-header')
uglify = require('gulp-uglify')
rename = require('gulp-rename')
karma = require('gulp-karma')

p = require('./package.json')

projectHeader = "/*! #{p.name} (v#{p.version}),\n
                Simple library for creating complicated architectures,\n
                by #{p.author}\n
                #{new Date().toDateString()} */\n"

sourceFiles = [
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

gulp.task 'build', ['karma:ci'], ->
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

gulp.task 'karma:ci', ->
  gulp.src('')
    .pipe(karma(
      configFile: 'karma.conf.coffee'
      sourceFiles: sourceFiles
    ))

gulp.task 'karma:dev', ->
  gulp.src('')
    .pipe(karma(
      configFile: 'karma.conf.coffee'
      reporters: ['dots']
      action: 'watch'
      sourceFiles: sourceFiles
    ))

gulp.task 'release', ['karma:ci', 'build', 'minify']
