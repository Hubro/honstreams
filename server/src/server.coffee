
# Dependencies
express = require 'express'
fs = require 'fs'
config = require './config'

# Create hons server
hons_server = express.createServer()

# Configure it
require('./serverconfig').init hons_server

hons_server.get '/pow', (req, res)->
	res.exit('pow');

# Start server
hons_server.listen config.port
console.log 'Listening to port ' + config.port
