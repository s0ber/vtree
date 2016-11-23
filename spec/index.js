testsContext = require.context('./', true, /.*_spec\.coffee$/)
testsContext.keys().forEach(testsContext)
