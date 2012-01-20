(function() {
  var Stream, channel, force, getChannel, getName, get_input, help, honsdb, name, save, sequelize, step;

  sequelize = require('sequelize');

  honsdb = require('../database');

  Stream = honsdb.define('Stream', {
    channel: {
      type: sequelize.STRING,
      primaryKey: true,
      allowNull: false
    },
    name: {
      type: sequelize.STRING,
      allowNull: false,
      unique: true
    },
    custom_url: {
      type: sequelize.STRING,
      allowNull: true,
      validate: {
        isUrl: true
      }
    },
    online: {
      type: sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false
    },
    viewers: {
      type: sequelize.INTEGER,
      allowNull: false,
      defaultValue: 0
    },
    clicks: {
      type: sequelize.INTEGER,
      allowNull: false,
      defaultValue: 0
    }
  });

  module.exports = Stream;

  if (!process.parent) {
    help = function() {
      return console.log("\nUSAGE: Stream command\n\nWhere command is one of the following\n  syncdb  Run syncdb on the Stream model\n  new     Insert a new Stream row\n");
    };
    if (!process.argv[2]) help();
    if (process.argv[2] === 'syncdb') {
      force = process.argv[3] === 'force' ? true : false;
      Stream.sync({
        force: force
      }).success(function() {
        return console.log('Stream table synchronized' + (force ? ' forcefully' : ''));
      }).error(function(error) {
        console.log('Sync failed');
        return console.log(error);
      });
    }
    if (process.argv[2] === 'new') {
      get_input = require('../get_input');
      step = require('../../vendor/step');
      channel = null;
      name = null;
      getChannel = function() {
        return get_input('channel', function(data) {
          channel = data;
          return getName();
        });
      };
      getName = function() {
        return get_input('name', function(data) {
          name = data;
          return save();
        });
      };
      save = function() {
        var newStream;
        newStream = Stream.build({
          channel: channel,
          name: name
        });
        return newStream.save().success(function() {
          return console.log('Stream saved');
        }).error(function(error) {
          console.log('An error occurred');
          return console.log(error);
        });
      };
      console.log('Input the data for new Stream row');
      getChannel();
    }
  }

}).call(this);
