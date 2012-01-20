(function() {
  var config, express, fs, hons_server;

  express = require('express');

  fs = require('fs');

  config = require('./config');

  hons_server = express.createServer();

  require('./serverconfig').init(hons_server);

  hons_server.get('/pow', function(req, res) {
    return res.exit('pow');
  });

  hons_server.listen(config.port);

  console.log('Listening to port ' + config.port);

}).call(this);
