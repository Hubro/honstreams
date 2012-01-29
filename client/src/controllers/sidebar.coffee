
honsapp = require '../honsapp'
sidebarview = require '../views/sidebar'
hashpath = require '../hashpath'

class Sidebar

	# Static factory function
	@create: ->
		return new Sidebar()
	
	# Constructor
	constructor: ->
		self = @self = this

		@el = $('<div>').addClass 'sidebar'

		# On stream click
		@el.on 'click', '.stream', (e)->
			# Fetch the stream index from the html
			index = $('input[name=index]', this).val()

			# Set the hash path to stream/<channel>
			hashpath.setPath ['stream', self.streams[index].channel]
		
		# On header click
		@el.on 'click', '.header', (e)->
			hashpath.setPath ['pages', 'home']
		
		# Listen for streams refresh
		honsapp.addEventListener 'streams-refreshed', ->
			self.setStreams this
		
		@render()
	
	# Function for setting the streams
	setStreams: (streams)->
		@streams = streams
		@render()
		@resetRefreshCountdown()
	
	# Reset the stream refresh interval
	resetRefreshCountdown: ->
		# Clear the timer if it is set
		if @timer
			clearInterval @timer
		
		# Reset the countdown to 60
		@refreshCountdown = 60

		# Write the countdown to HTML and start a new countdown interval
		@el_refresh_countdown.html @refreshCountdown--
		@timer = setInterval =>
			@el_refresh_countdown.html @refreshCountdown--
		, 1000
	
	# Function for rendering the streams into HTML and updating the element
	render: ->
		@el.html sidebarview
			streams: @streams
		
		@el_refresh_countdown = 
			$('.streams-info > .refresh-countdown span', @el)


module.exports = Sidebar
