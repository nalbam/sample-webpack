const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

const path = require('path');

module.exports = {
  entry: './src/app.js',
  output: {
    filename: '[name].bundle.js?[fullhash]',
    assetModuleFilename: '[name][ext]?[hash]',
    path: path.resolve(__dirname, 'dist'),
    clean: true
  },
  module: {
    rules: [{
        test: /\.css$/i,
        use: [MiniCssExtractPlugin.loader, 'css-loader'],
      },
      {
        test: /\.(png|svg|jpg|gif|ico)$/,
        type: 'asset',
        parser: {
          dataUrlCondition: {
            maxSize: 10000 // 10kb
          }
        }
      }
    ]
  },
  devServer: {
    static: './dist',
    client: {
      overlay: true
    },
    hot: true
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: path.resolve(__dirname, 'src/index.html'),
      filename: 'index.html',
      inject: 'body'
    }),
    new MiniCssExtractPlugin({
      filename: '[name].bundle.css?[fullhash]',
      chunkFilename: '[id].css',
    }),
  ]
};
