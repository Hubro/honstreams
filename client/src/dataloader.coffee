
self = module.exports

# Fetch the live streams
self.fetchLiveStreams = (callback)->
	url = 'http://chu.avestaweb.no:1337/live_streams'

	#$.getJSON url, (data)->
	#	callback data

	$.ajax
		url: url
		type: 'GET'
		datatype: 'json'
		success: (data, status)->
			console.log 'dataloader: fetchLiveStreams: success: ' + status

			# For some reason FireFox gets data as a string here, while Chrome
			# gets an object, so convert to object if it's a string
			if typeof data == 'string' then data = JSON.parse data
			callback data
		complete: (req, status)->
			console.log 'dataloader: fetchLiveStreams: complete: ' + status
		error: (req, status, error)->
			console.log 'dataloader: fetchLiveStreams: error: ' + status
			console.log error
