
# Dependencies
express = require 'express'

# Always run this config
all = (server)->
	server.use express.static(__dirname + '/../../client/public')

# Run this when developing
development = (server)->
	server.use express.errorHandler
		dumpExceptions: true
		showStack: true

# Run this when developing
production = (server)->
	server.use express.errorHandler {}

# Export function for setting config
module.exports.apply = (server)->

	# Set regular config
	server.configure -> all server
	
	# Set development config
	server.configure 'development', -> development server
	
	# Set production config
	server.configure 'production', -> production server
