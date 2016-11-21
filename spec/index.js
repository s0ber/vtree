require('src/modula.coffee')
require('src/configuration.coffee')
require('src/vtree.coffee')
require('src/vtree_src/hooks.coffee')
require('src/vtree_src/vtree_nodes_cache.coffee')
require('src/vtree_src/node.coffee')
require('src/vtree_src/node_data.coffee')
require('src/vtree_src/node_wrapper.coffee')
require('src/vtree_src/tree_manager.coffee')
require('src/vtree_src/launcher.coffee')
require('src/vtree_src/dom.coffee')

window.$ = require('jquery/dist/jquery.js')
window._ = require('underscore/underscore.js')
require('async_fn/build/async_fn.js')

testsContext = require.context('./', true, /.*_spec\.coffee$/)
testsContext.keys().forEach(testsContext)
