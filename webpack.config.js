const path = require('path')
const webpack = require('webpack')
const UnminifiedWebpackPlugin = require('unminified-webpack-plugin')

module.exports = {
  devtool: 'source-map',
  entry: [
    './src/vtree'
  ],
  output: {
    path: path.resolve('./build'),
    filename: 'vtree.min.js',
    library: 'Vtree',
    libraryTarget: 'this'
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
  plugins: [
    new webpack.optimize.UglifyJsPlugin({minimize: true}),
    new UnminifiedWebpackPlugin()
  ],
  devServer: {
    stats: 'errors-only'
  }
}
