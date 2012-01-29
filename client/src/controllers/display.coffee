
honsapp = require '../honsapp'
hashpath = require '../hashpath'
display_stream_view = require '../views/display_stream'
display_page_view = require '../views/display_page'

class Display

	# Static factory function
	@create: ->
		return new Display()
	
	defaultPath: ['pages', 'home']
	
	# Constructor
	constructor: ->
		# Set up the controller
		self = @self = this
		@el = $('<div>').addClass 'display'

		# Create a markdown parser object
		converter = new Showdown.converter()
		@markdown = converter.makeHtml

	# Decide what to do according to the input path array
	processPath: (path)->
		if !path.length
			return hashpath.setPath @defaultPath
		
		if path[0] == "pages"
			@displayPage path[1]

		if path[0] == "stream"
			@displayStream path[1]

	# Takes a channel name as input and displays it's stream
	displayStream: (channel)->
		@el.html display_stream_view
			channel: channel
			showChat: true
	
	# Takes a page path and displays it using markdown
	displayPage: (page)->
		pagetext = """
			# Welcome to Honstreams.com!

			This is the **home** page!

			Look, it even supports pure HTML:

			<object type="application/x-shockwave-flash" id="live_embed_player_flash" 
			data="http://www.justin.tv/widgets/live_embed_player.swf?channel=milkfat&auto_play=false" 
			bgcolor="#000000" width="640" height="480">
				<param name="allowFullScreen" value="true" />
				<param name="allowScriptAccess" value="always" />
				<param name="allowNetworking" value="all" />
				<param name="movie" value="http://www.justin.tv/widgets/live_embed_player.swf" />
				<param name="flashvars" value="channel=milkfat&auto_play=false" />
			</object>

			So I can embed **donate boxes** and stuff
		"""

		@el.html display_page_view content: @markdown pagetext

module.exports = Display
