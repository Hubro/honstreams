
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

competitive_monitor = (req, res)->
	Stream = require './models/stream'
	Stream.findAll(where: live: true)
	.success (result)->
		res.write """
			<!DOCTYPE html>
			<html>
				<head>
					<title>Honstreams competitive streams monitor</title>
					<style>
						body { 
							background-color: black; 
							color: white;
							font-family: "Verdana", "Trebuchet", "Helvetica"; 
							font-size: 12px;
						}
						h1 { margin: 0; font-size: 1.25em; }
						a { color: inherit; text-decoration: inherit; }
						.stream { 
							display: inline-block; 
							margin: 3px;
							padding: 3px;
							border: 1px solid rgba(255, 255, 255, 0.3);
							border-radius: 2px;
							text-align: center;
						}
						.stream:hover {
							border-color: rgba(255, 255, 255, 0.5);
						}
						.live { color: #4f4; }
						.offline { color: #f44; }
					</style>
				</head>
				<body><!--
		"""

		for stream in result
			if stream.live
				statusText =
					"<span class=\"live\">Live (#{stream.viewers})</span>"
			else
				statusText = "<span class=\"offline\">Offline</span>"

			res.write """
				--><a href="http://www.twitch.tv/#{stream.channel}"><!--
					--><div class="stream">
						<h1>#{stream.title}</h1>
						#{statusText}
					</div><!--
				--></a><!--
			"""
	
		res.end """
				--></body>
			</html>
		"""
		
# Function for applying all the views to a express server instance
exports.apply = (server)->
	# server.get '/', index
	server.all '/streams', streams
	server.all '/live_streams', live_streams
	server.all '/competitive_monitor', competitive_monitor
