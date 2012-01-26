
# Dependencies
config = require './config'
oauth = require 'oauth'
util = require 'util'

# Locals
jc = config.jtv

# Create an OAuth handle for the justin.tv API
jtvhandle = new oauth.OAuth jc.req_token_url, jc.acc_token_url, jc.key,
							jc.secret, '1.0', null, 'HMAC-SHA1'

# Performs a request to the API and passes the resulting data object to the
# callback
apiRequest = (path, callback)->
	# Ensure path starts with /
	path = if path.indexOf('/') == 0 then path else path = '/' + path
	
	# Attempt to run a request to the API
	jtvhandle.get jc.api_root + path, jc.key, jc.secret, (error, result)->
		info_object = JSON.parse result

		# Run callback with the result
		callback info_object

# Checks if the input stream name is live. Passes true of false to the callback,
# representing online or offline respectively. Can throw exceptions.
fetchStreamStatus = exports.fetchStreamStatus = (channel, callback)->
	request = "/channel/show/#{channel}.json"

	apiRequest request, (result)->
		# Return false on empty response
		if result.length < 1
			callback false
		# Return the fetched object
		else callback result[0]

# Fetches all live streams featuring Heroes of Newerth and passes them to the
# callback
fetchLiveStreams = exports.fetchLiveStreams = (callback)->
	request = "/stream/list.json?meta_game=Heroes%20of%20Newerth"

	apiRequest request, (result)->
		# Run the callback with the result
		callback result

###########################
##### STANDALONE CODE #####
###########################

# Execute if module is run directly
if !module.parent
	fetchLiveStreams (streams)->
		console.log streams[0]
