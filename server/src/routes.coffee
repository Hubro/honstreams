
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

	Stream.fetchWithPersistentData 'live = 1', (err, data)->
		# Format an error response on error
		if err
			response =
				error: "A database error has occurred"
				message: err

			res.end JSON.stringify response
			return

		# Otherwise return the data
		res.end JSON.stringify data

competitive_monitor = (req, res)->
	res.setHeader 'Content-Type', 'text/html; charset=UTF-8'

	Stream = require './models/stream'
	Stream.fetchWithPersistentData 'competitive=1', (err, data)->
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
						footer {
							position: absolute;
							right: 0px;
							bottom: 5px;
							left: 0px;
							text-align: center;
						}
						footer a {
							display: inline-block;
							padding: 3px;
							margin: 1px;
							text-decoration: underline;

							/*
							border: 1px solid rgba(255, 255, 255, 0.3);
							border-radius: 2px;
							*/
						}
						footer a:hover {
							color: #4f4;
						}
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
							background-color: #111111;
						}
						.stream h1 {
							margin: 0;
							font-size: 1em;
							color: #f44;
						}
						.stream.live h1 {
							margin: 0;
							font-size: 1.4em;
							color: #4f4;
						}
					</style>
					<script type="text/javascript">

					  var _gaq = _gaq || [];
					  _gaq.push(['_setAccount', 'UA-26013152-2']);
					  _gaq.push(['_trackPageview']);

					  (function() {
					    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
					    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
					    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
					  })();

					</script>
				</head>
				<body><!--
		"""

		for stream in data
			stream_title = stream.custom_name or stream.title

			if stream.live
				stream_title += " (#{stream.viewers})"
				cls = 'class="stream live"'
			else
				cls = 'class="stream"'

			res.write """
				--><a href="http://www.twitch.tv/#{stream.channel}"><!--
					--><div #{cls}>
						<h1>#{stream_title}</h1>
					</div><!--
				--></a><!--
			"""

		res.end """
				-->

					<footer>
						Courtesy of <a href="http://honstreams.com" target="new">
						honstreams.com</a>
					</footer>
				</body>
			</html>
		"""

# Function for applying all the views to a express server instance
exports.apply = (server)->
	# server.get '/', index
	server.all '/streams', streams
	server.all '/live_streams', live_streams
	server.all '/competitive_monitor', competitive_monitor
