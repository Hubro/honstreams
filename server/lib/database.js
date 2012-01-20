(function() {
  var config, honsdb, sequelize;

  sequelize = require('sequelize');

  config = require('./config');

  honsdb = new sequelize(config.mysql.database, config.mysql.username, config.mysql.password, {
    host: config.mysql.host,
    port: config.mysql.port,
    dialect: 'mysql',
    logging: config.mysql.logging
  });

  module.exports = honsdb;

}).call(this);
