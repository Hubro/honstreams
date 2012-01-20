
# Dependencies
sequelize = require 'sequelize'
config = require './config'

# Create the main database object
honsdb = new sequelize \
	config.mysql.database, \
	config.mysql.username, \
	config.mysql.password,
		host: config.mysql.host
		port: config.mysql.port
		dialect: 'mysql'
		logging: config.mysql.logging

# Export honsdb
module.exports = honsdb
