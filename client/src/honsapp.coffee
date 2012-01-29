
self = module.exports

# Dependencies
Sidebar = require 'controllers/sidebar'
Display = require 'controllers/display'

dataloader = require 'dataloader'
hashpath = require 'hashpath'

_events = {}

# Function for triggering an event
triggerEvent = self.triggerEvent = (event, env)->
	# Set env to an empty object if none is given
	if !env then env = {}

	# If any handlers are set, call them
	if _events[event]
		$.each _events[event], (i, e)->
			e.call env

# Function for adding a handler for an event
addEventHandler = self.addEventHandler = (event, cb)->
	# Create the callback array for this event if it doesn't exist
	if !Boolean(_events[event])
		_event[event] = []
	
	# Add the callback to it
	_event[event].push cb

# Initiates the honstreams app
self.init = (selector)->
	# Tie the creation to window.ready just to be sure
	$ ->
		# Set class to honsapp
		self.el = $(selector).addClass 'honsapp'

		# Add the sidebar
		sidebar = Sidebar.create()

		self.el.append sidebar.el

		# Fetch live streams and repeat every minute
		fetchLiveStreams = ->
			dataloader.fetchLiveStreams (streams)->
				# Sort streams by status
				streams.sort (a, b)->
					return -1 if a.viewers > b.viewers
					return 1
				
				sidebar.setStreams streams

		setInterval fetchLiveStreams, 60000
		fetchLiveStreams()

		# Add the display
		display = Display.create()
		self.el.append display.el

		# Listen to the hash path changing
		hashpath.addChangeListener (path)=>
			# Tell the Display to update it's content
			display.processPath path
		
		# Run the hash change once to initiate the site
		$(window).hashchange()
