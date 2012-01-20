(function() {
  var all, development, express;

  express = require('express');

  all = function(server) {
    return server.use(express.static(__dirname + '/../public'));
  };

  development = function(server) {
    return server.use(express.errorHandler({
      dumpExceptions: true,
      showStack: true
    }));
  };

  module.exports.init = function(server) {
    server.configure(function() {
      return all(server);
    });
    return server.configure('development', function() {
      return development(server);
    });
  };

}).call(this);
