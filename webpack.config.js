const path = require('path')
const webpack = require('webpack')

module.exports = {
  devtool: 'eval',
  entry: [
    './src/vtree'
  ],
  output: {
    path: path.resolve('./build'),
    filename: 'vtree.js',
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
  devServer: {
    stats: 'errors-only'
  }
}
