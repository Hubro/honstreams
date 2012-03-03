
# Dependencies
express = require 'express'
fs = require 'fs'
config = require './config'
serverconfig = require './serverconfig'
routes = require './routes'

# Create hons server
hons_server = express.createServer()

# Listen to errors
hons_server.on 'error', (err)->
    # Handle the error
    switch err.code
        when 'EADDRINUSE'
            console.error ("Couldn't start server, port #{config.port} is " +
                          "already in use").red
        else
            console.error String(err).red

    # Exit the process
    process.exit 1

# Configure the server
serverconfig.apply hons_server

# Set up routes
routes.apply hons_server

# Export the server
module.exports = hons_server

# If this module is executed
if !module.parent
    hons_server.listen config.port
    console.log "Listening to port #{config.port}"
