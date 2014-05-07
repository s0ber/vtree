gulp = require('gulp')
gutil = require('gulp-util')
coffee = require('gulp-coffee')
concat = require('gulp-concat')
header = require('gulp-header')
uglify = require('gulp-uglify')
rename = require('gulp-rename')

projectHeader = '/*! Vtree (v0.1.2),\n
                simple library for creating complicated architectures,\n
                by Sergey Shishkalov <sergeyshishkalov@gmail.com>\n
                <%= new Date().toDateString() %> */\n'

gulp.task 'build', ->
  gulp
    .src([
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
    ])
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
