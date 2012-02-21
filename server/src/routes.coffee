
#index = (req, res)->
#	res.contentType 'text/html'
#
#	
# View for retrieving all streams in json format
streams = (req, res)->
	res.contentType 'application/json'

	Stream = require './models/stream'

	Stream.all()
	.success (result)->
		res.end JSON.stringify result
	.error (msg)->
		res.end msg
		debugger

# View for fetching all live streams in json format
live_streams = (req, res)->
	res.contentType 'application/json'

	Stream = require './models/stream'

	Stream.findAll(where: live: true)
	.success (result)->
		res.end JSON.stringify result
	.error (msg)->
		res.end msg
		debugger
		
# Function for applying all the views to a express server instance
exports.apply = (server)->
	# server.get '/', index
	server.all '/streams', streams
	server.all '/live_streams', live_streams
