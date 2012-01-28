
# View for retrieving all streams in json format
streams = (req, res)->
	Stream = require './models/stream'

	res.charset = 'UTF-8'
	res.contentType 'application/json'

	Stream.all()
	.success (result)->
		res.end JSON.stringify result
	.error (msg)->
		res.end msg
		debugger

# View for fetching all live streams in json format
live_streams = (req, res)->
	Stream = require './models/stream'

	res.charset = 'UTF-8'
	res.contentType 'application/json'

	Stream.findAll(where: live: true)
	.success (result)->
		res.end JSON.stringify result
	.error (msg)->
		res.end msg
		debugger
		
# Function for applying all the views to a express server instance
exports.apply = (server)->
	server.get '/streams', streams
	server.get '/live_streams', live_streams
