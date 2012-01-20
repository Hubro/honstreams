
# Dependencies
express = require 'express'

# Always run this config
all = (server)->
	server.use express.static(__dirname + '/../public')

# Run this when developing
development = (server)->
	server.use express.errorHandler
		dumpExceptions: true
		showStack: true

# Export function for setting config
module.exports.init = (server)->

	# Set regular config
	server.configure ->
		all server
	
	# Set development config
	server.configure 'development', ->
		development server
