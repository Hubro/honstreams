
honsapp = require '../honsapp'
hashpath = require '../hashpath'
display_stream_view = require '../views/display_stream'

class Display

	# Static factory function
	@create: ->
		return new Display()
	
	# Constructor
	constructor: ->
		self = @self = this

		@el = $('<div>').addClass 'display'

		# Process the current path and listen for changes
		@processPath hashpath.path

		hashpath.addChangeListener (path)=>
			@processPath path

	# Decide what to do according to the input path array
	processPath: (path)->
		return if path.length < 2

		if path[0] == "stream"
			@displayStream path[1]

	# Takes a channel name as input and displays it's stream
	displayStream: (channel)->
		@el.html display_stream_view channel: channel

module.exports = Display
