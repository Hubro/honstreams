
# Dependencies
express = require 'express'
fs = require 'fs'
config = require './config'
serverconfig = require './serverconfig'
routes = require './routes'

# Create hons server
hons_server = express.createServer()

# Configure it
serverconfig.apply hons_server

# Set up routes
routes.apply hons_server

# Start server
hons_server.listen config.port
console.log 'Listening to port ' + config.port
