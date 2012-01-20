(function() {
  var config, fs, minifyjson, path, raw_config;

  fs = require('fs');

  path = require('path');

  minifyjson = require('../vendor/minify.json.js');

  raw_config = fs.readFileSync(__dirname + '/../config.json', 'UTF-8');

  config = JSON.parse(minifyjson(raw_config));

  config.root = path.join(__dirname, '/../');

  module.exports = config;

}).call(this);
