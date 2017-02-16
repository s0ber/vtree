const path = require('path')
const webpack = require('webpack')
const UnminifiedWebpackPlugin = require('unminified-webpack-plugin')
const isProduction = process.env.NODE_ENV === 'production'

const plugins = []
const externals = []
if (isProduction) {
  plugins.push(
    new webpack.optimize.UglifyJsPlugin({minimize: true}),
    new UnminifiedWebpackPlugin()
  )
  plugins.push(new webpack.DefinePlugin({
    'process.env': {
      DEPRECATED_JQUERY: process.env.DEPRECATED_JQUERY ? 'true' : 'false'
    }
  }))
  externals.push('jquery')
}

const isDeprecated = process.env.DEPRECATED_JQUERY

module.exports = {
  devtool: 'source-map',
  entry: ['./src/vtree'],
  output: {
    path: path.resolve('./build'),
    filename: isDeprecated ? 'vtree.deprecated.min.js' : 'vtree.min.js',
    library: 'Vtree',
    libraryTarget: 'umd'
  },
  resolve: {
    root: process.cwd(),
    modulesDirectories: ['node_modules'],
    extensions: ['', '.js', '.coffee', '.ejs']
  },
  module: {
    loaders: [
      {
        test: /\.coffee$/,
        loaders: ['coffee']
      },
      {
        test: /\.ejs$/,
        loaders: ['ejs']
      }
    ]
  },
  plugins: plugins,
  externals: externals,
  devServer: {
    stats: 'errors-only'
  }
}
