if process.env.DEPRECATED_JQUERY
  module.exports = {$: window.$}
else
  jquery = require 'jquery'
  module.exports = {$: jquery}
