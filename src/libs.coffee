if process.env.DEPRECATED_JQUERY
  AsyncFn = require('async_fn/build/async_fn.deprecated.min')
  module.exports = {$: window.$, AsyncFn}
else
  jquery = require 'jquery'
  AsyncFn = require 'async_fn'
  module.exports = {$: jquery, AsyncFn}
