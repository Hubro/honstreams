
self = module.exports

# Fetch the live streams
self.fetchLiveStreams = (callback)->
	url = 'http://chu.avestaweb.no:1337/live_streams'

	$.ajax
		url: url
		type: 'GET'
		datatype: 'json'
		success: (data, status)->
			# For some reason FireFox gets data as a string here, while Chrome
			# gets an object, so convert to object if it's a string
			if typeof data == 'string' then data = JSON.parse data

			callback data
		error: (req, status, error)->
			console.log 'dataloader: fetchLiveStreams: error: ' + status
			console.log error

# Get the setting, either from config or cookie. fallback overrides undefined
self.getSetting = (name, fallback)->
	memory = self.getSettings()

	if memory
		value = memory[name] or fallback
		return value
	else return fallback

# Save a setting in a cookie
self.putSetting = (name, value)->
	# Fetch or create the memory
	memory = self.getSettings()
	if !memory then memory = {}

	memory[name] = value

	self.putSettings memory

# Get the entire memory cookie
self.getSettings = ->
	memory = $.cookie 'honsapp-memory'

	if memory
		memory = JSON.parse memory

		return memory
	else return null

# Set the entire memory cookie
self.putSettings = (memory)->
	$.cookie 'honsapp-memory', JSON.stringify(memory), 365
