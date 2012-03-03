
# Dependencies
sequelize = require 'sequelize'
config = require './config'

# Create the main database object
honsdb = new sequelize config.mysql_database, config.mysql_username,
    config.mysql_password,
        host: config.mysql_host
        port: config.mysql_port
        dialect: 'mysql'
        logging: config.mysql_logging

# Export honsdb
module.exports = honsdb
