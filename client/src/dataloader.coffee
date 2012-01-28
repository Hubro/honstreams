
self = module.exports

# Fetch the live streams
self.fetchLiveStreams = (callback)->
	url = 'http://chu.avestaweb.no:1337/live_streams'

	$.getJSON url, (data)->
		callback data
