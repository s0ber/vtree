window.$ = require('jquery/dist/jquery.js')
require('async_fn/build/async_fn.js')

testsContext = require.context('./', true, /.*_spec\.coffee$/)
testsContext.keys().forEach(testsContext)
