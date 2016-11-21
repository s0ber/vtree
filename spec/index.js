require('src/modula.coffee')
require('src/vtree.coffee')

window.$ = require('jquery/dist/jquery.js')
window._ = require('underscore/underscore.js')
require('async_fn/build/async_fn.js')

testsContext = require.context('./', true, /.*_spec\.coffee$/)
testsContext.keys().forEach(testsContext)
